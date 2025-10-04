import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_schemas.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/basic_utils.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/manage/data/models/allowed_file_extensions.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_contents_uc/create_content_preview_image.dart';
import 'package:uuid/uuid.dart';

class StoreContentsUc {
  static CourseCollection collectionFromJson(String source) => CourseCollection.fromJson(source);

  /// Returns a List of Map containing...[..duplicate, ..success, ..fileName, ..contentId]
  static Future<List<Map<String, dynamic>>> storeCourseContents(Map<String, dynamic> args) async {
    List<Map<String, dynamic>> addContentResultList = [];
    final Result<dynamic> outcome = await Result.tryRunAsync(() async {
      final List<String> selectedContentPaths = args['selectedContentsPaths'];
      log("$selectedContentPaths");
      final RootIsolateToken rootIsolateToken = args['rootIsolateToken'] as RootIsolateToken;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);

      CourseCollection? collection = await CourseCollectionRepo.getById(args['collectionId']);
      if (collection == null) return "Unable to load collection";

      final String dirToStoreAt = collection.absolutePath;
      for (var filePath in selectedContentPaths) {
        log(filePath);
        log("${File(filePath)}");
        final file = File(filePath);
        // potentialPurgePaths.add(file.path);
        final fileName = p.basename(file.path);
        final fileNameWithoutExt = p.basenameWithoutExtension(fileName);
        final hash = await BasicUtils.calculateFileHash(file.path);
        final CourseContent? sameHashedContent = await CourseContentRepo.getByHash(hash);
        final CourseContentType contentType = checkContentType(fileName);

        final Result<String?> addContentResult = await Result.tryRunAsync(() async {
          //
          if (sameHashedContent == null) {
            final String contentId = const Uuid().v4();
            final File storedAt = File(
              await FileUtils.storeFile(
                file: file,
                folderPath: dirToStoreAt,
                newFileName: p.setExtension(contentId, p.extension(file.path)),
              ),
            );

            final CourseContent content = CourseContent.create(
              contentHash: hash,
              contentId: contentId,
              title: fileNameWithoutExt,
              parentId: collection.collectionId,
              path: FileDetails(filePath: storedAt.path),
              courseContentType: contentType,
              metadataJson: jsonEncode(<String, dynamic>{'filename': p.basenameWithoutExtension(fileName)}),
            );
            await CreateContentPreviewImage.createPreviewImageForContent(
              storedAt.path,
              courseContentType: contentType,
              genPreviewPathRecord: CreateContentPreviewImage.genPreviewImagePathRecord(filePath: storedAt.path),
            );
            await CourseContentRepo.addContent(content);
            return content.contentId;
          } else {
            final CourseContent? sameHashedContentInColl = await CourseContentRepo.findFirstDuplicateContentByHash(
              collection,
              hash,
            );
            if (sameHashedContentInColl == null) {
              final CourseContent content = CourseContent.create(
                contentHash: hash,
                title: fileNameWithoutExt,
                parentId: collection.collectionId,
                path: sameHashedContent.path.fileDetails,
                courseContentType: contentType,
              );
              await CourseContentRepo.addContent(content);
              return content.contentId;
            } else {
              log("A duplicate exists!");
              return '';
            }
          }
          //
        });
        final String? contentId = addContentResult.data;

        if (addContentResult.isSuccess && (addContentResult.data != null && addContentResult.data!.isNotEmpty)) {
          addContentResultList.add({'success': true, 'fileName': p.basename(filePath), 'contentId': contentId});
        } else {
          addContentResultList.add({
            'success': false,
            'fileName': p.basename(filePath),
            'duplicate': (contentId != null && contentId.isEmpty) ? true : null,
          });
        }
      }
      return addContentResultList;
    });
    if (!outcome.isSuccess) {
      log("${outcome.message}");
    }
    return addContentResultList;
  }

  /// Returns the CourseContentType for a file extension or path.
  /// E.g. `.md`, `file.txt`, `/path/to/image.jpg`
  static CourseContentType checkContentType(String pathOrExt) {
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
    } else if (AllowedFileExtensions.allowedVideoExtensions.contains(ext)) {
      return CourseContentType.video;
    } else if (AllowedFileExtensions.allowedDocumentExtensions.contains(ext)) {
      return CourseContentType.document;
    } else if (AllowedFileExtensions.allowedAudioExtensions.contains(ext)) {
      return CourseContentType.audio;
    } else if (['txt', 'md'].contains(ext)) {
      return CourseContentType.note;
    } else {
      return CourseContentType.unknown;
    }
  }
}
