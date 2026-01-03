import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/sync/logic/models/sync_model.dart';

/// ============================================================================
/// FIREBASE SYNC REPOSITORY
/// ============================================================================
///
/// Handles all Firebase Firestore operations for sync.
///
/// Database Structure:
/// - /courses/{courseId} - Course metadata
/// - /collections/{collectionId} - Collection metadata
/// - /contents/{contentHash} - Global content references
///
/// Note: Firebase Storage operations are handled separately via
/// FirebaseStorageService
/// ============================================================================

class FirebaseSyncRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _coursesRef => _firestore.collection('courses');
  CollectionReference get _collectionsRef => _firestore.collection('collections');
  CollectionReference get _contentsRef => _firestore.collection('contents');

  // =========================================================================
  // COURSE OPERATIONS
  // =========================================================================

  /// Stores course metadata in Firestore
  Future<Result<void>> storeCourseMetadata(RemoteCourse course) async {
    try {
      await _coursesRef.doc(course.courseId).set(course.toMap());
      log('Stored course metadata: ${course.courseId}');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to store course metadata: $e', st);
    }
  }

  /// Retrieves course metadata from Firestore
  Future<Result<RemoteCourse>> getCourseMetadata(String courseId) async {
    try {
      final doc = await _coursesRef.doc(courseId).get();
      if (!doc.exists) {
        return Result.error('Course not found: $courseId');
      }

      final data = doc.data() as Map<String, dynamic>;
      return Result.success(RemoteCourse.fromMap(data));
    } catch (e, st) {
      return Result.error('Failed to get course metadata: $e', st);
    }
  }

  /// Lists all available courses
  Future<Result<List<RemoteCourse>>> listCourses({int limit = 100}) async {
    try {
      final snapshot = await _coursesRef.orderBy('lastUpdated', descending: true).limit(limit).get();

      final courses = snapshot.docs.map((doc) => RemoteCourse.fromMap(doc.data() as Map<String, dynamic>)).toList();

      log('Listed ${courses.length} courses');
      return Result.success(courses);
    } catch (e, st) {
      return Result.error('Failed to list courses: $e', st);
    }
  }

  /// Searches courses by title
  Future<Result<List<RemoteCourse>>> searchCourses(String query) async {
    try {
      // Firestore doesn't support full-text search, so we use a simple contains check
      // For production, consider using Algolia or similar
      final snapshot = await _coursesRef.get();

      final courses = snapshot.docs
          .map((doc) => RemoteCourse.fromMap(doc.data() as Map<String, dynamic>))
          .where((course) => course.courseTitle.toLowerCase().contains(query.toLowerCase()))
          .toList();

      log('Found ${courses.length} courses matching "$query"');
      return Result.success(courses);
    } catch (e, st) {
      return Result.error('Failed to search courses: $e', st);
    }
  }

  /// Deletes course metadata
  Future<Result<void>> deleteCourseMetadata(String courseId) async {
    try {
      await _coursesRef.doc(courseId).delete();
      log('Deleted course metadata: $courseId');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to delete course metadata: $e', st);
    }
  }

  // =========================================================================
  // COLLECTION OPERATIONS
  // =========================================================================

  /// Stores collection metadata in Firestore
  Future<Result<void>> storeCollectionMetadata(RemoteCollection collection) async {
    try {
      await _collectionsRef.doc(collection.collectionId).set(collection.toMap());
      log('Stored collection metadata: ${collection.collectionId}');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to store collection metadata: $e', st);
    }
  }

  /// Retrieves collection metadata from Firestore
  Future<Result<RemoteCollection>> getCollectionMetadata(String collectionId) async {
    try {
      final doc = await _collectionsRef.doc(collectionId).get();
      if (!doc.exists) {
        return Result.error('Collection not found: $collectionId');
      }

      final data = doc.data() as Map<String, dynamic>;
      return Result.success(RemoteCollection.fromMap(data));
    } catch (e, st) {
      return Result.error('Failed to get collection metadata: $e', st);
    }
  }

  /// Lists all collections in a course
  Future<Result<List<RemoteCollection>>> listCollections(String courseId) async {
    try {
      final snapshot = await _collectionsRef
          .where('parentId', isEqualTo: courseId)
          .orderBy('createdAt', descending: true)
          .get();

      final collections = snapshot.docs
          .map((doc) => RemoteCollection.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      log('Listed ${collections.length} collections for course $courseId');
      return Result.success(collections);
    } catch (e, st) {
      return Result.error('Failed to list collections: $e', st);
    }
  }

  /// Deletes collection metadata
  Future<Result<void>> deleteCollectionMetadata(String collectionId) async {
    try {
      await _collectionsRef.doc(collectionId).delete();
      log('Deleted collection metadata: $collectionId');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to delete collection metadata: $e', st);
    }
  }

  // =========================================================================
  // CONTENT OPERATIONS
  // =========================================================================

  /// Stores content metadata in Firestore (global reference)
  Future<Result<void>> storeContentMetadata(RemoteContent content) async {
    try {
      // Check if content already exists (deduplicated by hash)
      final existing = await _contentsRef.doc(content.contentHash).get();
      if (existing.exists) {
        log('Content already exists: ${content.contentHash}');
        return Result.success(null);
      }

      await _contentsRef.doc(content.contentHash).set(content.toMap());
      log('Stored content metadata: ${content.contentHash}');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to store content metadata: $e', st);
    }
  }

  /// Retrieves content metadata from Firestore
  Future<Result<RemoteContent>> getContentMetadata(String contentHash) async {
    try {
      final doc = await _contentsRef.doc(contentHash).get();
      if (!doc.exists) {
        return Result.error('Content not found: $contentHash');
      }

      final data = doc.data() as Map<String, dynamic>;
      return Result.success(RemoteContent.fromMap(data));
    } catch (e, st) {
      return Result.error('Failed to get content metadata: $e', st);
    }
  }

  /// Retrieves multiple content metadata by hashes
  Future<Result<List<RemoteContent>>> getContentMetadataByHashes(List<String> hashes) async {
    try {
      final List<RemoteContent> contents = [];

      // Firestore 'in' queries are limited to 30 items, so batch them
      const batchSize = 30;
      for (int i = 0; i < hashes.length; i += batchSize) {
        final batch = hashes.skip(i).take(batchSize).toList();
        final snapshot = await _contentsRef.where(FieldPath.documentId, whereIn: batch).get();

        contents.addAll(snapshot.docs.map((doc) => RemoteContent.fromMap(doc.data() as Map<String, dynamic>)));
      }

      log('Retrieved ${contents.length}/${hashes.length} content metadata');
      return Result.success(contents);
    } catch (e, st) {
      return Result.error('Failed to get content metadata: $e', st);
    }
  }

  /// Lists contents in a collection
  Future<Result<List<RemoteContent>>> listContents(String collectionId) async {
    try {
      // First get the collection to get content hashes
      final collectionResult = await getCollectionMetadata(collectionId);
      if (!collectionResult.isSuccess) {
        return Result.error('Failed to get collection: ${collectionResult.message}');
      }

      final collection = collectionResult.data!;
      if (collection.contentHashes.isEmpty) {
        return Result.success([]);
      }

      // Get content metadata for all hashes
      return await getContentMetadataByHashes(collection.contentHashes);
    } catch (e, st) {
      return Result.error('Failed to list contents: $e', st);
    }
  }

  /// Checks if content exists by hash
  Future<Result<bool>> contentExists(String contentHash) async {
    try {
      final doc = await _contentsRef.doc(contentHash).get();
      return Result.success(doc.exists);
    } catch (e, st) {
      return Result.error('Failed to check content existence: $e', st);
    }
  }

  /// Deletes content metadata (use with caution - global reference)
  Future<Result<void>> deleteContentMetadata(String contentHash) async {
    try {
      await _contentsRef.doc(contentHash).delete();
      log('Deleted content metadata: $contentHash');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to delete content metadata: $e', st);
    }
  }

  // =========================================================================
  // BATCH OPERATIONS
  // =========================================================================

  /// Stores multiple metadata records in a batch
  Future<Result<void>> storeBatchMetadata({
    RemoteCourse? course,
    List<RemoteCollection>? collections,
    List<RemoteContent>? contents,
  }) async {
    try {
      final batch = _firestore.batch();

      if (course != null) {
        batch.set(_coursesRef.doc(course.courseId), course.toMap());
      }

      if (collections != null) {
        for (final collection in collections) {
          batch.set(_collectionsRef.doc(collection.collectionId), collection.toMap());
        }
      }

      if (contents != null) {
        for (final content in contents) {
          // Only set if doesn't exist (deduplication)
          final contentRef = _contentsRef.doc(content.contentHash);
          final exists = await contentRef.get();
          if (!exists.exists) {
            batch.set(contentRef, content.toMap());
          }
        }
      }

      await batch.commit();
      log('Batch metadata stored successfully');
      return Result.success(null);
    } catch (e, st) {
      return Result.error('Failed to store batch metadata: $e', st);
    }
  }

  // =========================================================================
  // STATISTICS
  // =========================================================================

  /// Gets total counts for dashboard
  Future<Result<Map<String, int>>> getStatistics() async {
    try {
      final coursesCount = await _coursesRef.count().get();
      final collectionsCount = await _collectionsRef.count().get();
      final contentsCount = await _contentsRef.count().get();

      return Result.success({
        'courses': coursesCount.count ?? 0,
        'collections': collectionsCount.count ?? 0,
        'contents': contentsCount.count ?? 0,
      });
    } catch (e, st) {
      return Result.error('Failed to get statistics: $e', st);
    }
  }
}
