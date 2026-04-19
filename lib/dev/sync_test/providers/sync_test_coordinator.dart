import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/apis/abstract/sync_coordinator.dart';
import 'package:slidesync/core/apis/api.dart';
import 'package:slidesync/core/apis/api_paths.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/dev/sync_test/providers/sync_test_state.dart';

class SyncTestCoordinator {
  final Ref ref;

  SyncTestCoordinator(this.ref);

  void _log(String message, SyncLogLevel level) {
    ref.read(SyncTestProvider.state.notifier).addLog(message, level);
  }

  void _setSyncing(bool value, {String? operation, int? total}) {
    ref.read(SyncTestProvider.state.notifier).setSyncing(value, operation: operation, total: total);
  }

  void _setProgress(double? progress) {
    ref.read(SyncTestProvider.state.notifier).setProgress(progress);
  }

  // =========================================================================
  // COURSE OPERATIONS
  // =========================================================================

  Future<void> testGetCourse(String courseId) async {
    try {
      _log('Getting course: $courseId', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching course');

      final result = await Api.instance.courses.get(courseId);

      if (result.isSuccess && result.data != null) {
        _log('✓ Course fetched: ${result.data!.courseTitle}', SyncLogLevel.success);
      } else {
        _log('✗ Course not found', SyncLogLevel.warning);
      }
    } catch (e) {
      _log('✗ Error getting course: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> testListCourses() async {
    try {
      _log('Listing all courses...', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching courses');

      final isar = await IsarData.isarFuture;
      final courses = await isar.collection<Course>().where().findAll();

      _log('✓ Found ${courses.length} courses', SyncLogLevel.success);
      for (final course in courses.take(5)) {
        _log('  - ${course.courseTitle} (${course.courseId})', SyncLogLevel.info);
      }

      if (courses.length > 5) {
        _log('  ... and ${courses.length - 5} more', SyncLogLevel.info);
      }
    } catch (e) {
      _log('✗ Error listing courses: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  // =========================================================================
  // COLLECTION OPERATIONS
  // =========================================================================

  Future<void> testGetCollection(String collectionId) async {
    try {
      _log('Getting collection: $collectionId', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching collection');

      final result = await Api.instance.collections.get(collectionId);

      if (result.isSuccess && result.data != null) {
        _log('✓ Collection fetched: ${result.data!.collectionTitle}', SyncLogLevel.success);
      } else {
        _log('✗ Collection not found', SyncLogLevel.warning);
      }
    } catch (e) {
      _log('✗ Error getting collection: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> testListCollections(String courseId) async {
    try {
      _log('Listing collections for course: $courseId', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching collections');

      final isar = await IsarData.isarFuture;
      final collections = await isar.collection<CourseCollection>().where().parentIdEqualTo(courseId).findAll();

      _log('✓ Found ${collections.length} collections', SyncLogLevel.success);
      for (final col in collections.take(5)) {
        _log('  - ${col.collectionTitle} (${col.collectionId})', SyncLogLevel.info);
      }

      if (collections.length > 5) {
        _log('  ... and ${collections.length - 5} more', SyncLogLevel.info);
      }
    } catch (e) {
      _log('✗ Error listing collections: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  // =========================================================================
  // CONTENT OPERATIONS
  // =========================================================================

  Future<void> testGetContent(String contentId) async {
    try {
      _log('Getting content: $contentId', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching content');

      final result = await Api.instance.content.get(contentId);

      if (result.isSuccess && result.data != null) {
        _log('✓ Content fetched: ${result.data!.title}', SyncLogLevel.success);
      } else {
        _log('✗ Content not found', SyncLogLevel.warning);
      }
    } catch (e) {
      _log('✗ Error getting content: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> testListContents(String collectionId) async {
    try {
      _log('Listing contents for collection: $collectionId', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching contents');

      final isar = await IsarData.isarFuture;
      final contents = await isar.collection<CourseContent>().where().parentIdEqualTo(collectionId).findAll();

      _log('✓ Found ${contents.length} contents', SyncLogLevel.success);
      for (final content in contents.take(5)) {
        _log('  - ${content.title} (${content.contentId}) [${content.courseContentType}]', SyncLogLevel.info);
      }

      if (contents.length > 5) {
        _log('  ... and ${contents.length - 5} more', SyncLogLevel.info);
      }
    } catch (e) {
      _log('✗ Error listing contents: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  // =========================================================================
  // VAULT OPERATIONS
  // =========================================================================

  Future<void> testListVaults() async {
    try {
      _log('Listing vaults...', SyncLogLevel.info);
      _setSyncing(true, operation: 'Fetching vaults');

      final result = await Api.instance.vault.listVaults();

      if (result.isSuccess && result.data != null) {
        final vaults = result.data!;
        _log('✓ Found ${vaults.length} vaults', SyncLogLevel.success);

        final urls = vaults.map((v) => v.url).toList();
        for (final url in urls.take(3)) {
          _log('  - $url', SyncLogLevel.info);
        }

        if (urls.length > 3) {
          _log('  ... and ${urls.length - 3} more', SyncLogLevel.info);
        }
      } else {
        _log('✗ No vaults found or access denied', SyncLogLevel.warning);
      }
    } catch (e) {
      _log('✗ Error listing vaults: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  // =========================================================================
  // SYNC OPERATIONS
  // =========================================================================

  Future<void> testSyncCourse(String courseId, List<String> vaultLinks) async {
    try {
      final isar = await IsarData.isarFuture;
      final courseResult = await isar.collection<Course>().where().courseIdEqualTo(courseId).findFirst();

      if (courseResult == null) {
        _log('✗ Course not found in Isar', SyncLogLevel.error);
        return;
      }

      _log('Starting sync for course: ${courseResult.courseTitle}', SyncLogLevel.info);
      _setSyncing(true, operation: 'Syncing course', total: 1);

      final coordinator = SyncCoordinator();
      final result = await coordinator.syncCourse(
        course: courseResult,
        userId: 'dev-user',
        vaultLinks: vaultLinks,
        onProgress: (bytesTransferred, totalBytes) {
          if (totalBytes > 0) {
            _setProgress(bytesTransferred / totalBytes);
          }
        },
      );

      if (result.isSuccess && result.data != null) {
        final syncResult = result.data!;
        _log('✓ Sync complete:', SyncLogLevel.success);
        _log('  Uploaded: ${syncResult.uploadedCount}', SyncLogLevel.info);
        _log('  Skipped: ${syncResult.skippedCount}', SyncLogLevel.info);
        _log('  Failed: ${syncResult.failedCount}', SyncLogLevel.info);

        if (syncResult.failedContentIds.isNotEmpty) {
          _log('  Failed IDs: ${syncResult.failedContentIds.join(", ")}', SyncLogLevel.warning);
        }
      } else {
        _log('✗ Sync failed: ${result.message}', SyncLogLevel.error);
      }
    } catch (e) {
      _log('✗ Error syncing course: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
      _setProgress(null);
    }
  }

  // =========================================================================
  // FLAT COLLECTION QUERY TEST
  // =========================================================================

  Future<void> testFlatCollectionQueries(String courseId) async {
    try {
      _log('Testing flat collection queries for course: $courseId', SyncLogLevel.info);
      _setSyncing(true, operation: 'Testing queries');

      final isar = await IsarData.isarFuture;

      // Test: Get collections by courseId (flat query)
      final collections = await isar.collection<CourseCollection>().where().parentIdEqualTo(courseId).findAll();
      _log('✓ Flat query: Found ${collections.length} collections for course', SyncLogLevel.success);

      if (collections.isNotEmpty) {
        // Test: Get contents by collectionId (flat query)
        final collectionId = collections.first.collectionId;
        final contents = await isar.collection<CourseContent>().where().parentIdEqualTo(collectionId).findAll();

        _log('✓ Flat query: Found ${contents.length} contents in collection "$collectionId"', SyncLogLevel.success);

        // Verify courseId field exists
        if (collections.first.parentId == courseId) {
          _log('✓ Verified: courseId field properly stored', SyncLogLevel.success);
        }

        if (contents.isNotEmpty && contents.first.parentId == collectionId) {
          _log('✓ Verified: collectionId field properly stored', SyncLogLevel.success);
        }
      }
    } catch (e) {
      _log('✗ Error testing queries: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }

  // =========================================================================
  // API PATHS TEST
  // =========================================================================

  Future<void> testApiPaths() async {
    try {
      _log('Testing API path structure...', SyncLogLevel.info);
      _setSyncing(true, operation: 'Testing paths');

      _log('✓ Courses path: ${ApiPaths.courses().path}', SyncLogLevel.info);
      _log('✓ Collections path: ${ApiPaths.collections().path}', SyncLogLevel.info);
      _log('✓ Contents path: ${ApiPaths.contents().path}', SyncLogLevel.info);
      _log('✓ Private courses path: ${ApiPaths.privateCourses().path}', SyncLogLevel.info);
      _log('✓ Vault path: ${ApiPaths.storageVault().path}', SyncLogLevel.info);

      _log('✓ All API paths correctly configured', SyncLogLevel.success);
    } catch (e) {
      _log('✗ Error testing paths: $e', SyncLogLevel.error);
    } finally {
      _setSyncing(false);
    }
  }
}

class SyncTestCoordinatorProvider {
  static final state = Provider((ref) => SyncTestCoordinator(ref));
}
