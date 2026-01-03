import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_schemas.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/smart_isolate.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/string_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/course_content/content_metadata.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/shared/allowed_file_extensions.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/add_content/content_thumbnail_creator.dart';
import 'package:slidesync/features/sync/logic/file_packaging.dart';
import 'package:slidesync/features/sync/logic/firebase_storage_service.dart';
import 'package:slidesync/features/sync/logic/firebase_sync_repository.dart';
import 'package:slidesync/features/sync/logic/models/sync_model.dart';

class DownloadManager {
  final FirebaseSyncRepository _firebaseRepo = FirebaseSyncRepository();
  final FirebaseStorageService _storageService = FirebaseStorageService(baseStoragePath: 'contents');

  final Map<String, bool> _pausedDownloads = {};
  final Map<String, bool> _cancelledDownloads = {};

  // Download course with optional merge
  Future<Result<Course>> downloadCourse({
    required String remoteCourseId,
    String? targetCourseId, // If provided, merge into existing
    required RootIsolateToken token,
    void Function(double progress, String message)? onProgress,
  }) async {
    try {
      onProgress?.call(0.0, 'Fetching course metadata...');

      // Fetch remote course metadata
      final courseResult = await _firebaseRepo.getCourseMetadata(remoteCourseId);
      if (!courseResult.isSuccess) {
        return Result.error('Failed to fetch course: ${courseResult.message}');
      }

      final remoteCourse = courseResult.data!;
      onProgress?.call(0.1, 'Fetching ${remoteCourse.collectionsCount} collections...');

      // Fetch all collections
      final collectionsResult = await _firebaseRepo.listCollections(remoteCourseId);
      if (!collectionsResult.isSuccess) {
        return Result.error('Failed to fetch collections: ${collectionsResult.message}');
      }

      final remoteCollections = collectionsResult.data!;
      onProgress?.call(0.2, 'Fetching content metadata...');

      // Fetch all content metadata
      final allContentHashes = <String>{};
      for (final collection in remoteCollections) {
        allContentHashes.addAll(collection.contentHashes);
      }

      final contentsResult = await _firebaseRepo.getContentMetadataByHashes(allContentHashes.toList());
      if (!contentsResult.isSuccess) {
        return Result.error('Failed to fetch contents: ${contentsResult.message}');
      }

      final remoteContents = contentsResult.data!;
      onProgress?.call(0.3, 'Starting download...');

      // Download in isolate
      final result = await SmartIsolate.run<_DownloadCourseArgs, double, Map<String, dynamic>>(
        _downloadCourseInIsolate,
        _DownloadCourseArgs(
          remoteCourse: remoteCourse.toMap(),
          remoteCollections: remoteCollections.map((c) => c.toMap()).toList(),
          remoteContents: remoteContents.map((c) => c.toMap()).toList(),
          targetCourseId: targetCourseId,
          token: token,
        ),
        onProgress: (progress) {
          // Scale progress from 0.3 to 1.0
          final scaledProgress = 0.3 + (progress * 0.7);
          onProgress?.call(scaledProgress, 'Downloading... ${(progress * 100).toInt()}%');
        },
      );

      if (result['success'] == true) {
        final courseId = result['courseId'] as String;
        final localCourse = await CourseRepo.getCourseById(courseId);
        if (localCourse != null) {
          return Result.success(localCourse);
        }
        return Result.error('Downloaded but failed to retrieve course');
      } else {
        return Result.error(result['error'] ?? 'Download failed');
      }
    } catch (e, st) {
      return Result.error('Download failed: $e', st);
    }
  }

  // Download collection
  Future<Result<CourseCollection>> downloadCollection({
    required String remoteCollectionId,
    required String targetCourseId,
    required RootIsolateToken token,
    void Function(double progress, String message)? onProgress,
  }) async {
    // Similar pattern to downloadCourse
    // Implementation here...
    return Result.error('Not implemented');
  }

  // Download contents
  Future<Result<List<CourseContent>>> downloadContents({
    required List<String> remoteContentHashes,
    required String targetCollectionId,
    required RootIsolateToken token,
    void Function(double progress, String message)? onProgress,
  }) async {
    // Similar pattern to downloadCourse
    // Implementation here...
    return Result.error('Not implemented');
  }

  // Control methods
  Future<void> pause(String id) async {
    _pausedDownloads[id] = true;
  }

  Future<void> resume(String id) async {
    _pausedDownloads[id] = false;
  }

  Future<void> cancel(String id) async {
    _cancelledDownloads[id] = true;
  }

  void pauseAll() {
    _pausedDownloads.clear();
  }

  void resumeAll() {
    _pausedDownloads.clear();
  }

  void dispose() {
    _pausedDownloads.clear();
    _cancelledDownloads.clear();
  }

  // ISOLATE WORKER
  static Future<Map<String, dynamic>> _downloadCourseInIsolate(
    _DownloadCourseArgs args,
    void Function(double) emitProgress,
  ) async {
    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(args.token);
      await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);

      final remoteCourse = RemoteCourse.fromMap(args.remoteCourse);
      final remoteCollections = args.remoteCollections.map((m) => RemoteCollection.fromMap(m)).toList();
      final remoteContents = args.remoteContents.map((m) => RemoteContent.fromMap(m)).toList();

      // Check if merging or creating new
      Course? targetCourse;
      if (args.targetCourseId != null) {
        targetCourse = await CourseRepo.getCourseById(args.targetCourseId!);
      }

      final isNewCourse = targetCourse == null;
      final courseId = targetCourse?.courseId ?? remoteCourse.courseId;

      // Create/update course
      if (isNewCourse) {
        targetCourse = Course.create(
          courseId: courseId,
          courseTitle: remoteCourse.courseTitle,
          description: remoteCourse.description,
          createdAt: remoteCourse.createdAt,
          metadataJson: remoteCourse.metadataJson,
        );
        await CourseRepo.addCourse(targetCourse);
      }

      emitProgress(0.1);

      // Step 1: Download and unpack all content files (50% of progress)
      final storageService = FirebaseStorageService(baseStoragePath: 'contents');
      final downloadedContentPaths = <String, String>{}; // hash -> local path

      for (int i = 0; i < remoteContents.length; i++) {
        final remoteContent = remoteContents[i];

        // Check if already exists locally
        final existingContent = await CourseContentRepo.getByHash(remoteContent.contentHash);
        if (existingContent != null) {
          downloadedContentPaths[remoteContent.contentHash] = existingContent.path.filePath;
          emitProgress(0.1 + (0.5 * ((i + 1) / remoteContents.length)));
          continue;
        }

        // Extract filename from storage URL
        final fileName = '${remoteContent.contentHash}.ss';

        // Download .ss file
        final downloadResult = await storageService.downloadFiles(
          [fileName],
          outputPath: AppPaths.operationsCacheFolder,
          overwriteExisting: false,
        );

        if (downloadResult.isEmpty) {
          log('Failed to download: $fileName');
          continue;
        }

        final packagedPath = downloadResult.values.first;

        // Unpack the file
        final unpackedPath = await FilePackageManager.unpackFile(
          File(packagedPath),
          outputPath: AppPaths.operationsCacheFolder,
        );

        if (unpackedPath == null) {
          log('Failed to unpack: $packagedPath');
          continue;
        }

        // Store file in proper location with hash-based path
        final hash = await CryptoUtils.calculateFileHashXXH3(unpackedPath);
        final dirToStoreAt = p.join(AppPaths.materialsFolder, StringUtils.getHashPrefixAsDir(hash));
        final ext = p.extension(unpackedPath);
        final newFileName = '$hash$ext';

        final storedPath = await FileUtils.storeFile(
          file: File(unpackedPath),
          folderPath: dirToStoreAt,
          newFileName: newFileName,
          overwrite: false,
        );

        downloadedContentPaths[remoteContent.contentHash] = storedPath;

        // Cleanup temp files
        await File(packagedPath).delete();
        await File(unpackedPath).delete();

        emitProgress(0.1 + (0.5 * ((i + 1) / remoteContents.length)));
      }

      // Step 2: Create collections and contents in database (40% of progress)
      emitProgress(0.6);

      for (int i = 0; i < remoteCollections.length; i++) {
        final remoteCollection = remoteCollections[i];

        // Check if collection already exists in target course
        final existingCollection = await CourseCollectionRepo.getById(remoteCollection.collectionId);

        CourseCollection targetCollection;
        if (existingCollection != null && existingCollection.parentId == courseId) {
          // Collection exists in target course - merge contents
          targetCollection = existingCollection;
        } else {
          // Create new collection
          targetCollection = CourseCollection.create(
            parentId: courseId,
            collectionId: remoteCollection.collectionId,
            collectionTitle: remoteCollection.collectionTitle,
            description: remoteCollection.description,
            createdAt: remoteCollection.createdAt,
            metadataJson: remoteCollection.metadataJson,
          );
          await CourseCollectionRepo.addCollection(targetCollection);
        }

        // Add contents to collection
        final contentsToAdd = <CourseContent>[];
        for (final contentHash in remoteCollection.contentHashes) {
          // Check if content already exists in this collection
          final existingContent = await CourseContentRepo.findFirstDuplicateContentByHash(
            targetCollection,
            contentHash,
          );
          if (existingContent != null) continue;

          final remoteContent = remoteContents.firstWhere((c) => c.contentHash == contentHash);
          final localPath = downloadedContentPaths[contentHash];
          if (localPath == null) continue;

          // Create thumbnail
          final contentType = AllowedFileExtensions.checkContentType(localPath);
          final previewPath = await ContentThumbnailCreator.createThumbnailForContent(
            localPath,
            courseContentType: contentType,
            dirToStoreAt: AppPaths.contentsThumbnailsFolder,
            filename: p.basenameWithoutExtension(localPath),
          );

          // Parse metadata and set thumbnail URL
          final metadata = ContentMetadata.fromJson(remoteContent.metadataJson);
          final updatedMetadata = metadata.copyWith(
            thumbnails: FileDetails(filePath: previewPath ?? '', urlPath: remoteContent.storageUrl),
          );

          final content = CourseContent.create(
            contentHash: contentHash,
            parentId: targetCollection.collectionId,
            title: remoteContent.title,
            path: FileDetails(filePath: localPath),
            fileSize: remoteContent.fileSize,
            courseContentType: contentType,
            description: remoteContent.description,
            metadata: updatedMetadata,
          );

          contentsToAdd.add(content);
        }

        if (contentsToAdd.isNotEmpty) {
          await CourseContentRepo.addMultipleContents(targetCollection.collectionId, contentsToAdd);
        }

        emitProgress(0.6 + (0.4 * ((i + 1) / remoteCollections.length)));
      }

      emitProgress(1.0);

      return {'success': true, 'courseId': courseId, 'isNew': isNewCourse};
    } catch (e, st) {
      log('Download error in isolate: $e\n$st');
      return {'success': false, 'error': e.toString()};
    }
  }
}

// Argument classes
class _DownloadCourseArgs {
  final Map<String, dynamic> remoteCourse;
  final List<Map<String, dynamic>> remoteCollections;
  final List<Map<String, dynamic>> remoteContents;
  final String? targetCourseId;
  final RootIsolateToken token;

  _DownloadCourseArgs({
    required this.remoteCourse,
    required this.remoteCollections,
    required this.remoteContents,
    this.targetCourseId,
    required this.token,
  });
}
