import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/logic/download_manager.dart';
import 'package:slidesync/features/sync/logic/firebase_sync_repository.dart';
import 'package:slidesync/features/sync/logic/models/sync_model.dart';
import 'package:slidesync/features/sync/logic/upload_manager.dart';
import 'package:slidesync/features/sync/providers/sync_provider.dart';

/// ============================================================================
/// SYNC SERVICE
/// ============================================================================
///
/// Central orchestrator for upload/download operations with:
/// - Network monitoring and auto-pause/resume
/// - Progress tracking through SyncProvider
/// - Background processing with isolates
/// - Notification support
///
/// Usage:
/// ```dart
/// final syncService = SyncService.instance;
///
/// // Upload a course
/// await syncService.uploadCourse(ref, course);
///
/// // Download a course
/// await syncService.downloadCourse(ref, remoteCourseId);
/// ```
/// ============================================================================

class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();

  final FirebaseSyncRepository _firebaseRepo = FirebaseSyncRepository();
  final UploadManager _uploadManager = UploadManager();
  final DownloadManager _downloadManager = DownloadManager();

  StreamSubscription<InternetStatus>? _networkSubscription;
  bool _isNetworkAvailable = true;

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Check initial network status
    _isNetworkAvailable = await InternetConnection().hasInternetAccess;
    log('SyncService initialized. Network available: $_isNetworkAvailable');

    // Listen to network changes
    _networkSubscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      final wasAvailable = _isNetworkAvailable;
      _isNetworkAvailable = status == InternetStatus.connected;

      if (!wasAvailable && _isNetworkAvailable) {
        log('Network restored - resuming sync operations');
        _onNetworkRestored();
      } else if (wasAvailable && !_isNetworkAvailable) {
        log('Network lost - pausing sync operations');
        _onNetworkLost();
      }
    });
  }

  void dispose() {
    _networkSubscription?.cancel();
    _uploadManager.dispose();
    _downloadManager.dispose();
  }

  // =========================================================================
  // UPLOAD OPERATIONS
  // =========================================================================

  /// Uploads a complete course (collections + contents)
  Future<Result<String>> uploadCourse(
    WidgetRef ref,
    Course course, {
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    final token = RootIsolateToken.instance;
    if (token == null) {
      return Result.error('Unable to process upload in background');
    }

    try {
      // Add to uploading queue
      await ref.sync.addToUploadingQueue(ref, toUpload: {course.courseId: SyncType.course});

      onProgress?.call(0.0, 'Preparing course upload...');

      // Load course relations
      await course.collections.load();
      final collections = course.collections.toList();

      onProgress?.call(0.1, 'Loading collections and contents...');

      // Collect all contents from all collections
      final List<CourseContent> allContents = [];
      for (final collection in collections) {
        await collection.contents.load();
        allContents.addAll(collection.contents.toList());
      }

      onProgress?.call(0.2, 'Found ${allContents.length} contents to upload');

      // Upload in background
      final result = await _uploadManager.uploadCourse(
        course: course,
        collections: collections,
        contents: allContents,
        token: token,
        onProgress: (progress, message) {
          // Scale progress from 0.2 to 1.0
          final scaledProgress = 0.2 + (progress * 0.8);
          onProgress?.call(scaledProgress, message);
        },
      );

      if (result.isSuccess) {
        // Mark as done in queue
        await ref.sync.updateUploadType(ref, id: course.courseId, type: SyncType.done);
        return Result.success(result.data!);
      } else {
        await ref.sync.removeFromUploadingQueue(ref, ids: [course.courseId]);
        return Result.error(result.message ?? 'Upload failed');
      }
    } catch (e, st) {
      await ref.sync.removeFromUploadingQueue(ref, ids: [course.courseId]);
      return Result.error('Upload error: $e', st);
    }
  }

  /// Uploads a collection (and its contents)
  Future<Result<String>> uploadCollection(
    WidgetRef ref,
    CourseCollection collection, {
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    final token = RootIsolateToken.instance;
    if (token == null) {
      return Result.error('Unable to process upload in background');
    }

    try {
      await ref.sync.addToUploadingQueue(ref, toUpload: {collection.collectionId: SyncType.collection});

      onProgress?.call(0.0, 'Preparing collection upload...');

      await collection.contents.load();
      final contents = collection.contents.toList();

      onProgress?.call(0.1, 'Found ${contents.length} contents to upload');

      final result = await _uploadManager.uploadCollection(
        collection: collection,
        contents: contents,
        token: token,
        onProgress: (progress, message) {
          final scaledProgress = 0.1 + (progress * 0.9);
          onProgress?.call(scaledProgress, message);
        },
      );

      if (result.isSuccess) {
        await ref.sync.updateUploadType(ref, id: collection.collectionId, type: SyncType.done);
        return Result.success(result.data!);
      } else {
        await ref.sync.removeFromUploadingQueue(ref, ids: [collection.collectionId]);
        return Result.error(result.message ?? 'Upload failed');
      }
    } catch (e, st) {
      await ref.sync.removeFromUploadingQueue(ref, ids: [collection.collectionId]);
      return Result.error('Upload error: $e', st);
    }
  }

  /// Uploads individual contents
  Future<Result<List<String>>> uploadContents(
    WidgetRef ref,
    List<CourseContent> contents, {
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    final token = RootIsolateToken.instance;
    if (token == null) {
      return Result.error('Unable to process upload in background');
    }

    try {
      // Add all to queue
      final toUpload = {for (var c in contents) c.contentId: SyncType.content};
      await ref.sync.addToUploadingQueue(ref, toUpload: toUpload);

      onProgress?.call(0.0, 'Preparing ${contents.length} contents...');

      final result = await _uploadManager.uploadContents(contents: contents, token: token, onProgress: onProgress);

      if (result.isSuccess) {
        // Mark all as done
        for (final content in contents) {
          await ref.sync.updateUploadType(ref, id: content.contentId, type: SyncType.done);
        }
        return result;
      } else {
        await ref.sync.removeFromUploadingQueue(ref, ids: contents.map((c) => c.contentId).toList());
        return Result.error(result.message ?? 'Upload failed');
      }
    } catch (e, st) {
      await ref.sync.removeFromUploadingQueue(ref, ids: contents.map((c) => c.contentId).toList());
      return Result.error('Upload error: $e', st);
    }
  }

  // =========================================================================
  // DOWNLOAD OPERATIONS
  // =========================================================================

  /// Lists all available courses from Firebase
  Future<Result<List<RemoteCourse>>> listRemoteCourses() async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    return await _firebaseRepo.listCourses();
  }

  /// Lists collections in a remote course
  Future<Result<List<RemoteCollection>>> listRemoteCollections(String courseId) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    return await _firebaseRepo.listCollections(courseId);
  }

  /// Lists contents in a remote collection
  Future<Result<List<RemoteContent>>> listRemoteContents(String collectionId) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    return await _firebaseRepo.listContents(collectionId);
  }

  /// Downloads a complete course
  Future<Result<Course>> downloadCourse(
    WidgetRef ref,
    String remoteCourseId, {
    String? targetCourseId, // For merging into existing course
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    final token = RootIsolateToken.instance;
    if (token == null) {
      return Result.error('Unable to process download in background');
    }

    try {
      await ref.sync.addToDownloadingQueue(ref, toDownload: {remoteCourseId: SyncType.course});

      onProgress?.call(0.0, 'Fetching course metadata...');

      final result = await _downloadManager.downloadCourse(
        remoteCourseId: remoteCourseId,
        targetCourseId: targetCourseId,
        token: token,
        onProgress: onProgress,
      );

      if (result.isSuccess) {
        await ref.sync.updateDownloadType(ref, id: remoteCourseId, type: SyncType.done);
        return result;
      } else {
        await ref.sync.removeFromDownloadingQueue(ref, ids: [remoteCourseId]);
        return Result.error(result.message ?? 'Download failed');
      }
    } catch (e, st) {
      await ref.sync.removeFromDownloadingQueue(ref, ids: [remoteCourseId]);
      return Result.error('Download error: $e', st);
    }
  }

  /// Downloads a collection into a target course
  Future<Result<CourseCollection>> downloadCollection(
    WidgetRef ref,
    String remoteCollectionId,
    String targetCourseId, {
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    final token = RootIsolateToken.instance;
    if (token == null) {
      return Result.error('Unable to process download in background');
    }

    try {
      await ref.sync.addToDownloadingQueue(ref, toDownload: {remoteCollectionId: SyncType.collection});

      onProgress?.call(0.0, 'Fetching collection metadata...');

      final result = await _downloadManager.downloadCollection(
        remoteCollectionId: remoteCollectionId,
        targetCourseId: targetCourseId,
        token: token,
        onProgress: onProgress,
      );

      if (result.isSuccess) {
        await ref.sync.updateDownloadType(ref, id: remoteCollectionId, type: SyncType.done);
        return result;
      } else {
        await ref.sync.removeFromDownloadingQueue(ref, ids: [remoteCollectionId]);
        return Result.error(result.message ?? 'Download failed');
      }
    } catch (e, st) {
      await ref.sync.removeFromDownloadingQueue(ref, ids: [remoteCollectionId]);
      return Result.error('Download error: $e', st);
    }
  }

  /// Downloads contents into a target collection
  Future<Result<List<CourseContent>>> downloadContents(
    WidgetRef ref,
    List<String> remoteContentHashes,
    String targetCollectionId, {
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!_isNetworkAvailable) {
      return Result.error('No network connection available');
    }

    final token = RootIsolateToken.instance;
    if (token == null) {
      return Result.error('Unable to process download in background');
    }

    try {
      final toDownload = {for (var hash in remoteContentHashes) hash: SyncType.content};
      await ref.sync.addToDownloadingQueue(ref, toDownload: toDownload);

      onProgress?.call(0.0, 'Fetching content metadata...');

      final result = await _downloadManager.downloadContents(
        remoteContentHashes: remoteContentHashes,
        targetCollectionId: targetCollectionId,
        token: token,
        onProgress: onProgress,
      );

      if (result.isSuccess) {
        for (final hash in remoteContentHashes) {
          await ref.sync.updateDownloadType(ref, id: hash, type: SyncType.done);
        }
        return result;
      } else {
        await ref.sync.removeFromDownloadingQueue(ref, ids: remoteContentHashes);
        return Result.error(result.message ?? 'Download failed');
      }
    } catch (e, st) {
      await ref.sync.removeFromDownloadingQueue(ref, ids: remoteContentHashes);
      return Result.error('Download error: $e', st);
    }
  }

  // =========================================================================
  // NETWORK MONITORING
  // =========================================================================

  void _onNetworkLost() {
    // Pause ongoing operations
    _uploadManager.pauseAll();
    _downloadManager.pauseAll();

    // TODO: Show notification
    log('All sync operations paused due to network loss');
  }

  void _onNetworkRestored() {
    // Resume paused operations
    _uploadManager.resumeAll();
    _downloadManager.resumeAll();

    // TODO: Show notification
    log('Sync operations resumed - network restored');
  }

  // =========================================================================
  // UTILITY METHODS
  // =========================================================================

  bool get isNetworkAvailable => _isNetworkAvailable;

  /// Cancels an upload operation
  Future<void> cancelUpload(WidgetRef ref, String id) async {
    await _uploadManager.cancel(id);
    await ref.sync.removeFromUploadingQueue(ref, ids: [id]);
  }

  /// Cancels a download operation
  Future<void> cancelDownload(WidgetRef ref, String id) async {
    await _downloadManager.cancel(id);
    await ref.sync.removeFromDownloadingQueue(ref, ids: [id]);
  }

  /// Pauses an upload
  Future<void> pauseUpload(String id) async {
    await _uploadManager.pause(id);
  }

  /// Pauses a download
  Future<void> pauseDownload(String id) async {
    await _downloadManager.pause(id);
  }

  /// Resumes an upload
  Future<void> resumeUpload(String id) async {
    if (!_isNetworkAvailable) {
      log('Cannot resume upload - no network connection');
      return;
    }
    await _uploadManager.resume(id);
  }

  /// Resumes a download
  Future<void> resumeDownload(String id) async {
    if (!_isNetworkAvailable) {
      log('Cannot resume download - no network connection');
      return;
    }
    await _downloadManager.resume(id);
  }
}
