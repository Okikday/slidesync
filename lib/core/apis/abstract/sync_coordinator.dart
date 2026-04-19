import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/apis/abstract/upload_download_base.dart';
import 'package:slidesync/core/sync/gdrive_manager.dart';
import 'package:slidesync/core/sync/entities/drive_progress.dart';
import 'package:slidesync/core/apis/api.dart';
import 'package:slidesync/core/apis/entities/vault_entity.dart';
import 'package:slidesync/core/apis/entities/source_entity.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/result.dart';

/// Upload sync result tracking
class SyncResult {
  final int totalContents;
  final int uploadedCount;
  final int skippedCount;
  final int failedCount;
  final List<String> failedContentIds;
  final String? error;

  const SyncResult({
    required this.totalContents,
    required this.uploadedCount,
    required this.skippedCount,
    required this.failedCount,
    required this.failedContentIds,
    this.error,
  });

  bool get success => failedCount == 0 && error == null;

  @override
  String toString() =>
      'SyncResult(uploaded: $uploadedCount, skipped: $skippedCount, '
      'failed: $failedCount/$totalContents, error: $error)';
}

/// Coordinates sync operations between local Isar and Firebase Firestore.
/// Handles:
/// - File uploads to storage vault (with retry)
/// - Firebase document creation
/// - Content origin checking (skip non-file origins)
/// - Empty course/collection handling
/// - Resumable operations
class SyncCoordinator {
  static final SyncCoordinator _instance = SyncCoordinator._();
  factory SyncCoordinator() => _instance;
  SyncCoordinator._();

  final _driveManager = GDriveManager.instance;

  /// Sync course and its collections to Firebase.
  ///
  /// Returns [SyncResult] with details about uploaded/skipped/failed content.
  /// Does NOT upload empty courses.
  Future<Result<SyncResult?>> syncCourse({
    required Course course,
    required String userId,
    required List<String> vaultLinks,
    OnUploadProgress? onProgress,
  }) => Result.tryRunAsync(() async {
    final courseId = course.courseId;

    SyncLogger.info('Syncing course: $courseId', operation: userId);

    try {
      // Fetch collections for this course (parentId = courseId)
      final isar = await IsarData.isarFuture;
      final collections = await isar.collection<CourseCollection>().where().parentIdEqualTo(courseId).findAll();

      if (collections.isEmpty) {
        SyncLogger.warn('Course is empty (no collections), skipping upload', operation: userId);
        return const SyncResult(
          totalContents: 0,
          uploadedCount: 0,
          skippedCount: 0,
          failedCount: 0,
          failedContentIds: [],
        );
      }

      // Sync each collection
      int totalUploaded = 0;
      int totalSkipped = 0;
      int totalFailed = 0;
      final failedIds = <String>[];

      for (final collection in collections) {
        try {
          final result = await _syncCollection(
            courseId: courseId,
            collection: collection,
            userId: userId,
            vaultLinks: vaultLinks,
            onProgress: onProgress,
          );

          totalUploaded += result.uploadedCount;
          totalSkipped += result.skippedCount;
          totalFailed += result.failedCount;
          failedIds.addAll(result.failedContentIds);
        } catch (e) {
          SyncLogger.error('Collection ${collection.collectionId} sync failed', e, operation: userId);
          totalFailed += 1;
          failedIds.add(collection.collectionId);
        }
      }

      final totalContents = totalUploaded + totalSkipped + totalFailed;
      SyncLogger.info(
        'Course sync complete: uploaded=$totalUploaded, '
        'skipped=$totalSkipped, failed=$totalFailed',
        operation: userId,
      );

      return SyncResult(
        totalContents: totalContents,
        uploadedCount: totalUploaded,
        skippedCount: totalSkipped,
        failedCount: totalFailed,
        failedContentIds: failedIds,
      );
    } catch (e) {
      SyncLogger.error('Course sync failed', e, operation: userId);
      rethrow;
    }
  });

  /// Sync a single collection and its contents.
  /// Does NOT upload empty collections.
  Future<SyncResult> _syncCollection({
    required String courseId,
    required CourseCollection collection,
    required String userId,
    required List<String> vaultLinks,
    OnUploadProgress? onProgress,
  }) async {
    final collectionId = collection.collectionId;

    SyncLogger.info('Syncing collection: $collectionId', operation: userId);

    // Fetch contents
    final isar = await IsarData.isarFuture;
    final contents = await isar.collection<CourseContent>().where().parentIdEqualTo(collectionId).findAll();

    if (contents.isEmpty) {
      SyncLogger.info('Collection is empty, skipping', operation: userId);
      return const SyncResult(
        totalContents: 0,
        uploadedCount: 0,
        skippedCount: 0,
        failedCount: 0,
        failedContentIds: [],
      );
    }

    int uploadedCount = 0;
    int skippedCount = 0;
    int failedCount = 0;
    final failedIds = <String>[];

    for (final content in contents) {
      try {
        final uploaded = await _uploadContentIfNeeded(
          content: content,
          courseId: courseId,
          collectionId: collectionId,
          userId: userId,
          vaultLinks: vaultLinks,
          onProgress: onProgress,
        );

        if (uploaded == null) {
          skippedCount++;
        } else if (uploaded) {
          uploadedCount++;
        } else {
          failedCount++;
          failedIds.add(content.contentId);
        }
      } catch (e) {
        SyncLogger.error('Content ${content.contentId} sync failed', e, operation: userId);
        failedCount++;
        failedIds.add(content.contentId);
      }
    }

    return SyncResult(
      totalContents: contents.length,
      uploadedCount: uploadedCount,
      skippedCount: skippedCount,
      failedCount: failedCount,
      failedContentIds: failedIds,
    );
  }

  /// Upload content if needed, then write to Firebase.
  ///
  /// Returns:
  /// - `true` if uploaded successfully
  /// - `false` if upload failed
  /// - `null` if skipped (not a file or already exists)
  Future<bool?> _uploadContentIfNeeded({
    required CourseContent content,
    required String courseId,
    required String collectionId,
    required String userId,
    required List<String> vaultLinks,
    OnUploadProgress? onProgress,
  }) async {
    final metadata = content.metadata;

    // Skip if not uploadable: only upload local files or links
    // Links (type=link) should be uploaded regardless of origin
    if (content.courseContentType != CourseContentType.link && metadata.contentOrigin != ContentOrigin.local) {
      SyncLogger.info(
        'Content ${content.contentId} is not local or link (type=${content.courseContentType}, origin=${metadata.contentOrigin}), skipping upload',
        operation: userId,
      );
      return null;
    }

    // Check if content already in Firebase
    final existing = await Api.instance.content.get(content.contentHash);

    if (existing.isSuccess && existing.data != null) {
      SyncLogger.info('Content ${content.contentId} already in Firebase, skipping', operation: userId);
      return null;
    }

    // Validate file - parse content.path as FileDetails (it's stored as JSON)
    final fileDetails = content.path.fileDetails;
    final file = File(fileDetails.filePath.replaceFirst(RegExp(r'^(file|link):'), ''));
    if (!await file.exists()) {
      SyncLogger.warn('File not found: ${file.path}', operation: userId);
      return false;
    }

    // Upload file using Google Drive resumable upload protocol
    try {
      SyncLogger.info('Uploading file: ${content.title}', operation: userId);

      // Stream upload progress from GDriveManager
      String? driveFileId;
      await for (final progress in _driveManager.public.upload(
        file: file,
        institutionId: 'default', // Use default institution
        courseId: courseId, // Organize by course
        uploadedBy: userId,
        operationId: content.contentId,
        fileName: content.title,
      )) {
        // Emit progress updates
        if (onProgress != null) {
          onProgress(progress.bytesTransferred, progress.totalBytes);
        }

        // Log progress
        if (progress.isDone) {
          driveFileId = progress.driveFileId;
          SyncLogger.info('Upload complete: ${progress.formattedProgress} → $driveFileId', operation: userId);
        } else if (progress.isFailed) {
          throw Exception(progress.error ?? 'Upload failed');
        } else if (progress.progressPercent % 10 == 0) {
          SyncLogger.info('Upload progress: ${progress.formattedProgress}', operation: userId);
        }
      }

      if (driveFileId == null) {
        throw Exception('Upload completed but no file ID returned');
      }

      // Log upload to vault
      await Api.instance.vault.logUploadWithSource(
        linkId: driveFileId, // Use Drive file ID as link
        uploadInput: LogUploadInput(
          uploadedBy: userId,
          contentHash: content.contentHash,
          fileName: content.title,
          fileSize: content.fileSize,
        ),
        sourceInput: CreateSourceInput(
          url: 'https://drive.google.com/file/d/$driveFileId/view',
          title: content.title,
          type: 'file',
          uploadedBy: userId,
        ),
      );

      SyncLogger.info('File uploaded successfully', operation: userId);

      return true;
    } catch (e) {
      SyncLogger.error('File upload failed', e, operation: userId);
      return false;
    }
  }
}
