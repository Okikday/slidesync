import 'dart:async';
import 'dart:collection';
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
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content_metadata.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/file_path.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/shared/allowed_file_extensions.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/add_content/content_thumbnail_creator.dart';
import 'package:slidesync/features/browse/shared/usecases/types/add_content_result.dart';
import 'package:slidesync/features/browse/shared/usecases/types/store_content_args.dart';

Module collectionFromJson(String source) => Module.fromJson(source);

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

        final List<ModuleContent> contentsToAdd = [];
        final Set<String> seenHashesSet = <String>{};

        Module? collection = await ModuleRepo.getById(args.collectionId);
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

          final ModuleContentType contentType = AllowedFileExtensions.checkContentType(fileName);
          final uuid = args.uuids[i];
          final newFileName = "$hash${p.extension(filePath)}";

          final Result<String?> addContentResult = await Result.tryRunAsync(() async {
            final ModuleContent? sameHashedContent = await ModuleContentRepo.getByHash(hash);
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
                type: contentType,
                dirToStoreAt: AppPaths.contentsThumbnailsFolder,
                filename: p.basenameWithoutExtension(newFileName),
              );
              log("previewPath: $previewPath");

              final ModuleContent content = ModuleContent.create(
                xxh3Hash: hash,
                contentId: uuid,
                title: fileNameWithoutExt,
                parentId: collection.uid,
                path: FilePath(local: storedAt.path),
                fileSizeInBytes: fileSize,
                type: contentType,
                metadata: ModuleContentMetadata.create(
                  originalFileName: p.basename(filePath),
                  contentOrigin: ContentOrigin.local,
                  thumbnails: FilePath(local: previewPath ?? ''),
                ),
              );

              contentsToAdd.add(content);
              seenHashesSet.add(hash);
              return content.uid;
            } else {
              final ModuleContent? sameHashedContentInColl = await ModuleContentRepo.findFirstDuplicateContentByHash(
                collection,
                hash,
              );
              if (sameHashedContentInColl == null) {
                final metadata = sameHashedContent.metadata;
                final ModuleContent content = ModuleContent.create(
                  contentId: uuid,
                  xxh3Hash: hash,
                  title: fileNameWithoutExt,
                  parentId: collection.uid,
                  path: sameHashedContent.path,
                  fileSizeInBytes: fileSize,
                  type: contentType,
                  metadata: metadata.copyWith(originalFileName: fileName),
                );
                contentsToAdd.add(content);
                seenHashesSet.add(hash);
                return content.uid;
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
          try {
            // Future.microtask(() => aggregateFileSizeToStorage(fileSize));
            final completer = Completer<void>();
            _storageSizeUpdateQueue.add(completer);
            aggregateFileSizeToStorage(fileSize).then((_) {
              _storageSizeUpdateQueue.removeFirst();
              completer.complete();
            });
          } catch (e) {
            log("Error updating storage usage: $e");
          }
        }

        if (contentsToAdd.isNotEmpty) {
          await ModuleContentRepo.addMultipleContents(collection.uid, contentsToAdd);
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

final Queue<Completer> _storageSizeUpdateQueue = Queue<Completer>();
Future<Result> aggregateFileSizeToStorage(int addSize) async => Result.tryRunAsync(() async {
  final file = File(p.join(AppPaths.rootFolder, "storage_usage.json"));
  int totalSize = 0;

  if (file.existsSync()) {
    final content = file.readAsStringSync();
    if (content.isNotEmpty) {
      final data = jsonDecode(content);
      if (data != null && data is Map<String, dynamic> && data.containsKey("totalSize")) {
        totalSize = data["totalSize"] as int? ?? 0;
      }
    }
  } else {
    await file.create(recursive: true);
  }

  totalSize += addSize;
  final updatedData = {"totalSize": totalSize};
  await file.writeAsString(jsonEncode(updatedData));
});

Future<int> getTotalStorageUsed() async {
  final file = File(p.join(AppPaths.rootFolder, "storage_usage.json"));
  if (file.existsSync()) {
    final content = file.readAsStringSync();
    if (content.isNotEmpty) {
      final data = jsonDecode(content);
      if (data != null && data is Map<String, dynamic> && data.containsKey("totalSize")) {
        final totalSize = data["totalSize"] as int? ?? 0;
        return totalSize;
      }
    }
  }
  return 0;
}
