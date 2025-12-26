import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_schemas.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/core/utils/smart_isolate.dart';
import 'package:slidesync/core/utils/string_utils.dart';
import 'package:slidesync/data/models/course/course_metadata.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/course_content/content_metadata.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/shared/allowed_file_extensions.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/add_content/content_thumbnail_creator.dart';
import 'package:slidesync/features/browse/shared/usecases/types/add_content_result.dart';
import 'package:slidesync/features/browse/shared/usecases/types/store_content_args.dart';

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

        final contentPathsLength = args.filePaths.length;
        // int totalFilesSizeSum = 0;

        for (int i = 0; i < contentPathsLength; i++) {
          final filePath = args.filePaths[i];
          final file = File(filePath);
          if (!(await file.exists())) continue;
          final fileName = p.basename(file.path);
          final fileNameWithoutExt = p.basenameWithoutExtension(fileName);
          final hash = await CryptoUtils.calculateFileHashXXH3(file.path);

          final String dirToStoreAt = p.join(AppPaths.materialsFolder, StringUtils.getHashPrefixAsDir(hash));
          final fileSize = await FileUtils.getFileSize(file.path);

          if (seenHashesSet.contains(hash)) {
            addContentResultList.add(AddContentResult(hasDuplicate: true, isSuccess: false, fileName: fileName));
            emitProgress(((i + 1) / contentPathsLength));
            continue;
          }

          final CourseContentType contentType = AllowedFileExtensions.checkContentType(fileName);
          final uuid = args.uuids[i];
          final newFileName = "$hash${p.extension(filePath)}";

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
              // totalFilesSizeSum += fileSize;
              final previewPath = await ContentThumbnailCreator.createThumbnailForContent(
                storedAt.path,
                courseContentType: contentType,
                dirToStoreAt: AppPaths.contentsThumbnailsFolder,
                filename: p.basenameWithoutExtension(newFileName),
              );
              log("previewPath: $previewPath");

              final CourseContent content = CourseContent.create(
                contentHash: hash,
                contentId: uuid,
                title: fileNameWithoutExt,
                parentId: collection.collectionId,
                path: FileDetails(filePath: storedAt.path),
                fileSize: fileSize,
                courseContentType: contentType,
                metadataJson: ContentMetadata(
                  originalFileName: p.basename(filePath),
                  thumbnails: FileDetails(filePath: previewPath ?? '').toMap(),
                ).toJson(),
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
                final metadata = sameHashedContent.metadata;
                final CourseContent content = CourseContent.create(
                  contentId: uuid,
                  contentHash: hash,
                  title: fileNameWithoutExt,
                  parentId: collection.collectionId,
                  path: sameHashedContent.path.fileDetails,
                  fileSize: fileSize,
                  courseContentType: contentType,
                  metadataJson: metadata.copyWith(originalFileName: fileName).toJson(),
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
            addContentResultList.add(
              AddContentResult(isSuccess: true, fileName: fileName, contentId: contentId, fileSize: fileSize),
            );
          } else {
            emitProgress(((i + 1) / contentPathsLength));
            addContentResultList.add(
              AddContentResult(
                isSuccess: false,
                fileName: fileName,
                contentId: contentId,
                hasDuplicate: (contentId != null && contentId.isEmpty),
                fileSize: fileSize,
              ),
            );
          }
        }

        if (contentsToAdd.isNotEmpty) {
          await CourseContentRepo.addMultipleContents(collection.collectionId, contentsToAdd);
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
