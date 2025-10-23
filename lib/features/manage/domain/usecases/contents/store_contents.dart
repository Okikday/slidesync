import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_schemas.dart';
import 'package:slidesync/core/utils/smart_isolate.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/basic_utils.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/manage/data/models/allowed_file_extensions.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/features/manage/domain/usecases/types/add_content_result.dart';
import 'package:slidesync/features/manage/domain/usecases/types/store_content_args.dart';

CourseCollection collectionFromJson(String source) => CourseCollection.fromJson(source);

Future<List<Map<String, dynamic>>> storeContents(
  Map<String, dynamic> arg, [
  ValueNotifier<String>? valueNotifier,
]) async {
  final result = await SmartIsolate.run<Map<String, dynamic>, double, List<Map<String, dynamic>>>(
    (arg, emitProgress) async {
      final args = StoreContentArgs.fromMap(arg);
      log("Inside Store contents method");
      List<AddContentResult> addContentResultList = [];
      final Result outcome = await Result.tryRunAsync(() async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(args.token);
        await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);

        final List<CourseContent> contentsToAdd = [];
        final Set<String> seenHashesSet = <String>{};

        CourseCollection? collection = await CourseCollectionRepo.getById(args.collectionId);
        if (collection == null) return "Unable to load collection";

        final String dirToStoreAt = collection.absolutePath;
        final contentPathsLength = args.filePaths.length;
        int totalFilesSizeSum = 0;

        for (int i = 0; i < contentPathsLength; i++) {
          final filePath = args.filePaths[i];
          final file = File(filePath);
          if (!(await file.exists())) continue;
          final fileName = p.basename(file.path);
          final fileNameWithoutExt = p.basenameWithoutExtension(fileName);
          final hash = await BasicUtils.calculateFileHashXXH3(file.path);
          final fileSize = await FileUtils.getFileSize(file.path);

          if (seenHashesSet.contains(hash)) {
            addContentResultList.add(AddContentResult(hasDuplicate: true, isSuccess: false, fileName: fileName));
            emitProgress(((i + 1) / contentPathsLength));
            continue;
          }

          final CourseContentType contentType = checkContentType(fileName);
          final uuid = args.uuids[i];
          final newFileName = "$uuid${p.extension(filePath)}";

          final Result<String?> addContentResult = await Result.tryRunAsync(() async {
            final CourseContent? sameHashedContent = await CourseContentRepo.getByHash(hash);
            if (sameHashedContent == null) {
              final File storedAt = File(
                await FileUtils.storeFile(
                  file: file,
                  folderPath: dirToStoreAt,
                  newFileName: newFileName,
                  overwrite: true,
                ),
              );
              totalFilesSizeSum += fileSize;
              final previewPath = await CreateContentPreviewImage.createPreviewImageForContent(
                storedAt.path,
                courseContentType: contentType,
                filePath: storedAt.path,
              );

              final CourseContent content = CourseContent.create(
                contentHash: hash,
                contentId: uuid,
                title: fileNameWithoutExt,
                parentId: collection.collectionId,
                path: FileDetails(filePath: storedAt.path),
                fileSize: fileSize,
                courseContentType: contentType,
                metadataJson: jsonEncode(<String, dynamic>{
                  'originalFilename': p.basename(filePath),
                  'previewPath': previewPath,
                  'fileSize': fileSize,
                }),
              );

              contentsToAdd.add(content);
              seenHashesSet.add(hash);
              return content.contentId;
            } else {
              final CourseContent? sameHashedContentInColl = await CourseContentRepo.findFirstDuplicateContentByHash(
                collection,
                hash,
              );
              if (sameHashedContentInColl == null) {
                final metadataJson = jsonDecode(sameHashedContent.metadataJson);
                final CourseContent content = CourseContent.create(
                  contentId: uuid,
                  contentHash: hash,
                  title: fileNameWithoutExt,
                  parentId: collection.collectionId,
                  path: sameHashedContent.path.fileDetails,
                  fileSize: fileSize,
                  courseContentType: contentType,
                  metadataJson: jsonEncode(<String, dynamic>{
                    'originalFilename': metadataJson['originalFilename'],
                    'previewPath': metadataJson['previewPath'],
                    'fileSize': fileSize,
                  }),
                );
                contentsToAdd.add(content);
                seenHashesSet.add(hash);
                return content.contentId;
              } else {
                log("A duplicate exists!");
                return '';
              }
            }
          });

          final String? contentId = addContentResult.data;

          if (addContentResult.isSuccess && (addContentResult.data != null && addContentResult.data!.isNotEmpty)) {
            emitProgress(((i + 1) / contentPathsLength));
            addContentResultList.add(AddContentResult(isSuccess: true, fileName: fileName, contentId: contentId));
          } else {
            emitProgress(((i + 1) / contentPathsLength));
            addContentResultList.add(
              AddContentResult(
                isSuccess: false,
                fileName: fileName,
                contentId: contentId,
                hasDuplicate: (contentId != null && contentId.isEmpty),
              ),
            );
          }
        }

        if (contentsToAdd.isNotEmpty) {
          await CourseContentRepo.addMultipleContents(collection.collectionId, contentsToAdd);
          final prevFileSum = (await AppHiveData.instance.getData(key: HiveDataPathKey.globalFileSizeSum.name)) as int?;
          if (prevFileSum == null) {
            await AppHiveData.instance.setData(key: HiveDataPathKey.globalFileSizeSum.name, value: totalFilesSizeSum);
          } else {
            await AppHiveData.instance.setData(
              key: HiveDataPathKey.globalFileSizeSum.name,
              value: prevFileSum + totalFilesSizeSum,
            );
          }
        }
        if (args.deleteCache) await FileUtils.deleteFiles(args.filePaths); // Delete the cache

        return addContentResultList;
      });
      if (!outcome.isSuccess) {
        log("${outcome.message}");
      }
      return addContentResultList.map((e) => e.toMap()).toList();
    },
    arg,
    onProgress: (msg) {
      valueNotifier?.value = "Progress...${(msg * 100).toInt()}%";
      return;
    },
  );
  return result;
}

/// Returns the CourseContentType for a file extension or path.
/// E.g. `.md`, `file.txt`, `/path/to/image.jpg`
CourseContentType checkContentType(String pathOrExt) {
  // Remove any leading dots and path parts
  String ext = pathOrExt.trim().toLowerCase();

  if (ext.contains(Platform.pathSeparator)) {
    ext = ext.split(Platform.pathSeparator).last;
  }
  if (ext.contains('.')) {
    ext = ext.split('.').last;
  }

  if (AllowedFileExtensions.allowedImageExtensions.contains(ext)) {
    return CourseContentType.image;
  }
  // else if (AllowedFileExtensions.allowedVideoExtensions.contains(ext)) {
  //   return CourseContentType.video;
  // }
  else if (AllowedFileExtensions.allowedDocumentExtensions.contains(ext)) {
    return CourseContentType.document;
  }
  // else if (AllowedFileExtensions.allowedAudioExtensions.contains(ext)) {
  //   return CourseContentType.audio;
  // }
  else if (['txt', 'md'].contains(ext)) {
    return CourseContentType.note;
  } else {
    return CourseContentType.unknown;
  }
}
