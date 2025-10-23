// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/auth/domain/usecases/auth_uc/user_data_functions.dart';

/// Service for managing course repository and backups in Firebase
class FirebaseCourseService {
  final FirebaseFirestore _firestore;
  final UserDataFunctions _userDataFunctions;

  FirebaseCourseService({FirebaseFirestore? firestore, UserDataFunctions? userDataFunctions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _userDataFunctions = userDataFunctions ?? UserDataFunctions();

  // ==================== BACKUP OPERATIONS ====================

  /// Upload user's complete course backup to Firebase
  Future<Result<void>> uploadBackup({
    required List<Course> courses,
    required List<CourseCollection> collections,
    required List<CourseContent> contents,
  }) async {
    return Result.tryRunAsync(() async {
      // Validate content limit
      if (contents.length >= 1000) {
        throw Exception('Content limit exceeded. Maximum 1000 contents allowed (current: ${contents.length})');
      }

      final userResult = await _userDataFunctions.getUserDetails();
      if (userResult.isError || userResult.data == null) {
        throw Exception('Failed to get user details: ${userResult.message}');
      }

      final user = userResult.data!;
      final userId = user.userID;

      final backupData = _BackupData(
        courses: courses.map((c) => c.toMap()).toList(),
        collections: collections.map((c) => c.toMap()).toList(),
        contents: contents.map((c) => c.toMap()).toList(),
        timestamp: DateTime.now(),
        userId: userId,
        userName: user.userName ?? user.displayName,
        displayName: user.displayName,
      );

      await _firestore.collection('users').doc(userId).collection('backup').doc('data').set(backupData.toMap());
    });
  }

  /// Download user's backup from Firebase
  Future<Future<Result<BackupResult?>>> downloadBackup({String? userId}) async {
    return Result.tryRunAsync(() async {
      final targetUserId = userId ?? await _getUserId();

      final doc = await _firestore.collection('users').doc(targetUserId).collection('backup').doc('data').get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('No backup found for user');
      }

      final backupData = _BackupData.fromMap(doc.data()!);

      return BackupResult(
        courses: backupData.courses.map((m) => Course.fromMap(m)).toList(),
        collections: backupData.collections.map((m) => CourseCollection.fromMap(m)).toList(),
        contents: backupData.contents.map((m) => CourseContent.fromMap(m)).toList(),
        timestamp: backupData.timestamp,
        userId: backupData.userId,
        userName: backupData.userName,
        displayName: backupData.displayName,
      );
    });
  }

  /// Stream user's backup changes
  Stream<Result<BackupResult?>> streamBackup({String? userId}) async* {
    try {
      final targetUserId = userId ?? await _getUserId();

      yield* _firestore.collection('users').doc(targetUserId).collection('backup').doc('data').snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return Result.success(null);
        }

        try {
          final backupData = _BackupData.fromMap(doc.data()!);
          return Result.success(
            BackupResult(
              courses: backupData.courses.map((m) => Course.fromMap(m)).toList(),
              collections: backupData.collections.map((m) => CourseCollection.fromMap(m)).toList(),
              contents: backupData.contents.map((m) => CourseContent.fromMap(m)).toList(),
              timestamp: backupData.timestamp,
              userId: backupData.userId,
              userName: backupData.userName,
              displayName: backupData.displayName,
            ),
          );
        } catch (e, st) {
          return Result<BackupResult?>.error(e.toString(), st);
        }
      });
    } catch (e, st) {
      yield Result.error(e.toString(), st);
    }
  }

  /// Delete user's backup
  Future<Result<void>> deleteBackup() async {
    return Result.tryRunAsync(() async {
      final userId = await _getUserId();
      await _firestore.collection('users').doc(userId).collection('backup').doc('data').delete();
    });
  }

  /// Check if user has a backup
  Future<Future<Result<bool?>>> hasBackup({String? userId}) async {
    return Result.tryRunAsync(() async {
      final targetUserId = userId ?? await _getUserId();
      final doc = await _firestore.collection('users').doc(targetUserId).collection('backup').doc('data').get();
      return doc.exists;
    });
  }

  // ==================== REPOSITORY OPERATIONS ====================

  /// Upload a course to the public repository
  Future<Result<void>> uploadCourseToRepo({
    required Course course,
    required List<CourseCollection> collections,
    required List<CourseContent> contents,
  }) async {
    return Result.tryRunAsync(() async {
      final userResult = await _userDataFunctions.getUserDetails();
      if (userResult.isError || userResult.data == null) {
        throw Exception('Failed to get user details: ${userResult.message}');
      }

      final user = userResult.data!;
      final batch = _firestore.batch();

      // Upload course
      final courseRef = _firestore.collection('repo').doc('courses').collection('courses').doc(course.courseId);
      final courseData = {
        ...course.toMap(),
        'verified': false,
        'submittedBy': user.userID,
        'userName': user.userName ?? user.displayName,
        'displayName': user.displayName,
      };
      batch.set(courseRef, courseData);

      // Upload collections
      for (final collection in collections.where((c) => c.parentId == course.courseId)) {
        final collectionRef = courseRef.collection('collections').doc(collection.collectionId);
        final collectionData = {...collection.toMap(), 'submittedBy': user.userID};
        batch.set(collectionRef, collectionData);

        // Upload contents for this collection
        final collectionContents = contents.where((c) => c.parentId == collection.collectionId);
        for (final content in collectionContents) {
          final contentRef = collectionRef.collection('contents').doc(content.contentHash);
          final contentData = {...content.toMap(), 'submittedBy': user.userID};
          batch.set(contentRef, contentData);

          // Update content lookup index
          await _updateContentLookup(
            contentHash: content.contentHash,
            courseId: course.courseId,
            title: content.title,
            fileSize: content.fileSize,
          );
        }
      }

      await batch.commit();
    });
  }

  /// Upload multiple courses to repository
  Future<Result<void>> uploadMultipleCoursesToRepo({
    required List<Course> courses,
    required List<CourseCollection> collections,
    required List<CourseContent> contents,
  }) async {
    return Result.tryRunAsync(() async {
      for (final course in courses) {
        final courseColl = collections.where((c) => c.parentId == course.courseId).toList();
        final courseConts = contents.where((c) {
          final collIds = courseColl.map((col) => col.collectionId).toSet();
          return collIds.contains(c.parentId);
        }).toList();

        final result = await uploadCourseToRepo(course: course, collections: courseColl, contents: courseConts);

        if (result.isError) {
          throw Exception('Failed to upload course ${course.courseTitle}: ${result.message}');
        }
      }
    });
  }

  /// Get courses from repository with pagination
  Future<Future<Result<List<RepoCourse>?>>> getRepoCourses({
    int limit = 100,
    DocumentSnapshot? startAfter,
    bool verifiedOnly = false,
  }) async {
    return Result.tryRunAsync(() async {
      Query query = _firestore
          .collection('repo')
          .doc('courses')
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (verifiedOnly) {
        query = query.where('verified', isEqualTo: true);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RepoCourse(
          course: Course.fromMap(data),
          verified: data['verified'] as bool? ?? false,
          submittedBy: data['submittedBy'] as String? ?? '',
          userName: data['userName'] as String? ?? '',
          displayName: data['displayName'] as String? ?? '',
          lastDoc: doc,
        );
      }).toList();
    });
  }

  /// Stream courses from repository
  Stream<Result<List<RepoCourse>>> streamRepoCourses({int limit = 100, bool verifiedOnly = false}) {
    try {
      Query query = _firestore
          .collection('repo')
          .doc('courses')
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (verifiedOnly) {
        query = query.where('verified', isEqualTo: true);
      }

      return query.snapshots().map((snapshot) {
        try {
          final courses = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return RepoCourse(
              course: Course.fromMap(data),
              verified: data['verified'] as bool? ?? false,
              submittedBy: data['submittedBy'] as String? ?? '',
              userName: data['userName'] as String? ?? '',
              displayName: data['displayName'] as String? ?? '',
              lastDoc: doc,
            );
          }).toList();
          return Result.success(courses);
        } catch (e, st) {
          return Result<List<RepoCourse>>.error(e.toString(), st);
        }
      });
    } catch (e, st) {
      return Stream.value(Result.error(e.toString(), st));
    }
  }

  /// Search courses by title
  Future<Future<Result<List<RepoCourse>?>>> searchCourses({
    required String searchTerm,
    int limit = 50,
    bool verifiedOnly = false,
  }) async {
    return Result.tryRunAsync(() async {
      Query query = _firestore
          .collection('repo')
          .doc('courses')
          .collection('courses')
          .orderBy('courseTitle')
          .startAt([searchTerm])
          .endAt(['$searchTerm\uf8ff'])
          .limit(limit);

      if (verifiedOnly) {
        query = query.where('verified', isEqualTo: true);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RepoCourse(
          course: Course.fromMap(data),
          verified: data['verified'] as bool? ?? false,
          submittedBy: data['submittedBy'] as String? ?? '',
          userName: data['userName'] as String? ?? '',
          displayName: data['displayName'] as String? ?? '',
          lastDoc: doc,
        );
      }).toList();
    });
  }

  /// Get a specific course with its collections and contents
  Future<Future<Result<CourseDetails?>>> getCourseDetails(String courseId) async {
    return Result.tryRunAsync(() async {
      final courseDoc = await _firestore.collection('repo').doc('courses').collection('courses').doc(courseId).get();

      if (!courseDoc.exists || courseDoc.data() == null) {
        throw Exception('Course not found');
      }

      final courseData = courseDoc.data()!;
      final course = Course.fromMap(courseData);

      // Get collections
      final collectionsSnapshot = await courseDoc.reference.collection('collections').get();
      final collections = <CourseCollection>[];
      final contents = <CourseContent>[];

      for (final collectionDoc in collectionsSnapshot.docs) {
        final collection = CourseCollection.fromMap(collectionDoc.data());
        collections.add(collection);

        // Get contents for this collection
        final contentsSnapshot = await collectionDoc.reference.collection('contents').get();
        for (final contentDoc in contentsSnapshot.docs) {
          contents.add(CourseContent.fromMap(contentDoc.data()));
        }
      }

      return CourseDetails(
        course: course,
        collections: collections,
        contents: contents,
        verified: courseData['verified'] as bool? ?? false,
        submittedBy: courseData['submittedBy'] as String? ?? '',
      );
    });
  }

  /// Stream a specific course details
  Stream<Result<CourseDetails>> streamCourseDetails(String courseId) async* {
    try {
      final courseStream = _firestore.collection('repo').doc('courses').collection('courses').doc(courseId).snapshots();

      await for (final courseDoc in courseStream) {
        if (!courseDoc.exists || courseDoc.data() == null) {
          yield Result.error('Course not found');
          continue;
        }

        try {
          final courseData = courseDoc.data()!;
          final course = Course.fromMap(courseData);

          // Get collections
          final collectionsSnapshot = await courseDoc.reference.collection('collections').get();
          final collections = <CourseCollection>[];
          final contents = <CourseContent>[];

          for (final collectionDoc in collectionsSnapshot.docs) {
            final collection = CourseCollection.fromMap(collectionDoc.data());
            collections.add(collection);

            // Get contents
            final contentsSnapshot = await collectionDoc.reference.collection('contents').get();
            for (final contentDoc in contentsSnapshot.docs) {
              contents.add(CourseContent.fromMap(contentDoc.data()));
            }
          }

          yield Result.success(
            CourseDetails(
              course: course,
              collections: collections,
              contents: contents,
              verified: courseData['verified'] as bool? ?? false,
              submittedBy: courseData['submittedBy'] as String? ?? '',
            ),
          );
        } catch (e, st) {
          yield Result.error(e.toString(), st);
        }
      }
    } catch (e, st) {
      yield Result.error(e.toString(), st);
    }
  }

  /// Delete a course from repository (admin or owner only)
  Future<Result<void>> deleteCourseFromRepo(String courseId) async {
    return Result.tryRunAsync(() async {
      final courseRef = _firestore.collection('repo').doc('courses').collection('courses').doc(courseId);

      // Delete all subcollections first
      final collections = await courseRef.collection('collections').get();
      final batch = _firestore.batch();

      for (final collectionDoc in collections.docs) {
        // Delete contents
        final contents = await collectionDoc.reference.collection('contents').get();
        for (final contentDoc in contents.docs) {
          batch.delete(contentDoc.reference);
        }
        batch.delete(collectionDoc.reference);
      }

      batch.delete(courseRef);
      await batch.commit();
    });
  }

  // ==================== CONTENT LOOKUP OPERATIONS ====================

  /// Find content by hash
  Future<Result<ContentLookupResult?>> findContentByHash(String contentHash) async {
    return Result.tryRunAsync(() async {
      final doc = await _firestore.collection('content-lookup').doc(contentHash).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      return ContentLookupResult(
        contentHash: contentHash,
        topTitle: data['topTitle'] as String? ?? '',
        fileSize: data['fileSize'] as int? ?? 0,
        courseIds: List<String>.from(data['courseIds'] ?? []),
        lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
        titleVotes: Map<String, int>.from(data['titleVotes'] ?? {}),
        totalSubmissions: data['totalSubmissions'] as int? ?? 0,
      );
    });
  }

  /// Stream content lookup by hash
  Stream<Result<ContentLookupResult?>> streamContentByHash(String contentHash) {
    try {
      return _firestore.collection('content-lookup').doc(contentHash).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return Result.success(null);
        }

        try {
          final data = doc.data()!;
          return Result.success(
            ContentLookupResult(
              contentHash: contentHash,
              topTitle: data['topTitle'] as String? ?? '',
              fileSize: data['fileSize'] as int? ?? 0,
              courseIds: List<String>.from(data['courseIds'] ?? []),
              lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
              titleVotes: Map<String, int>.from(data['titleVotes'] ?? {}),
              totalSubmissions: data['totalSubmissions'] as int? ?? 0,
            ),
          );
        } catch (e, st) {
          return Result<ContentLookupResult?>.error(e.toString(), st);
        }
      });
    } catch (e, st) {
      return Stream.value(Result.error(e.toString(), st));
    }
  }

  /// Get suggested title for a content hash
  Future<Future<Result<String?>>> getSuggestedTitle(String contentHash) async {
    return Result.tryRunAsync(() async {
      final result = await findContentByHash(contentHash);
      if (result.isError || result.data == null) {
        throw Exception('Content not found');
      }
      return result.data!.topTitle;
    });
  }

  /// Batch lookup multiple content hashes
  Future<Future<Result<Map<String, ContentLookupResult>?>>> batchFindContentByHash(List<String> contentHashes) async {
    return Result.tryRunAsync(() async {
      final results = <String, ContentLookupResult>{};

      // Firestore has a limit of 10 docs per getAll, so batch them
      for (var i = 0; i < contentHashes.length; i += 10) {
        final batchHashes = contentHashes.skip(i).take(10).toList();
        final refs = batchHashes.map((hash) => _firestore.collection('content-lookup').doc(hash)).toList();

        final docs = await Future.wait(refs.map((ref) => ref.get()));

        for (var j = 0; j < docs.length; j++) {
          final doc = docs[j];
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            results[batchHashes[j]] = ContentLookupResult(
              contentHash: batchHashes[j],
              topTitle: data['topTitle'] as String? ?? '',
              fileSize: data['fileSize'] as int? ?? 0,
              courseIds: List<String>.from(data['courseIds'] ?? []),
              lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
              titleVotes: Map<String, int>.from(data['titleVotes'] ?? {}),
              totalSubmissions: data['totalSubmissions'] as int? ?? 0,
            );
          }
        }
      }

      return results;
    });
  }

  /// Find all courses containing a specific content hash
  Future<Future<Result<List<RepoCourse>?>>> findCoursesWithContent(String contentHash) async {
    return Result.tryRunAsync(() async {
      final lookupResult = await findContentByHash(contentHash);
      if (lookupResult.isError || lookupResult.data == null) {
        return <RepoCourse>[];
      }

      final courseIds = lookupResult.data!.courseIds;
      final courses = <RepoCourse>[];

      for (final courseId in courseIds) {
        final courseDoc = await _firestore.collection('repo').doc('courses').collection('courses').doc(courseId).get();

        if (courseDoc.exists && courseDoc.data() != null) {
          final data = courseDoc.data()!;
          courses.add(
            RepoCourse(
              course: Course.fromMap(data),
              verified: data['verified'] as bool? ?? false,
              submittedBy: data['submittedBy'] as String? ?? '',
              userName: data['userName'] as String? ?? '',
              displayName: data['displayName'] as String? ?? '',
              lastDoc: courseDoc,
            ),
          );
        }
      }

      return courses;
    });
  }

  // ==================== ADMIN OPERATIONS ====================

  /// Check if current user is admin
  Future<Future<Result<bool?>>> isCurrentUserAdmin() async {
    return Result.tryRunAsync(() async {
      final userId = await _getUserId();
      final doc = await _firestore.collection('admins').doc(userId).get();
      return doc.exists;
    });
  }

  /// Verify a course (admin only)
  Future<Result<void>> verifyCourse(String courseId) async {
    return Result.tryRunAsync(() async {
      final userId = await _getUserId();
      await _firestore.collection('repo').doc('courses').collection('courses').doc(courseId).update({
        'verified': true,
        'verifiedBy': userId,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Unverify a course (admin only)
  Future<Result<void>> unverifyCourse(String courseId) async {
    return Result.tryRunAsync(() async {
      await _firestore.collection('repo').doc('courses').collection('courses').doc(courseId).update({
        'verified': false,
        'verifiedBy': FieldValue.delete(),
        'verifiedAt': FieldValue.delete(),
      });
    });
  }

  /// Update content title (admin can override voting)
  Future<Result<void>> overrideTitleForContent({required String contentHash, required String newTitle}) async {
    return Result.tryRunAsync(() async {
      await _firestore.collection('content-lookup').doc(contentHash).update({
        'topTitle': newTitle,
        'adminOverride': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  // ==================== STATISTICS OPERATIONS ====================

  /// Get repository statistics
  Future<Future<Result<RepoStats?>>> getRepoStats() async {
    return Result.tryRunAsync(() async {
      final coursesSnapshot = await _firestore.collection('repo').doc('courses').collection('courses').get();

      final verifiedCount = coursesSnapshot.docs.where((doc) => (doc.data()['verified'] as bool?) ?? false).length;

      // Count total collections and contents
      int totalCollections = 0;
      int totalContents = 0;

      for (final courseDoc in coursesSnapshot.docs) {
        final collectionsSnapshot = await courseDoc.reference.collection('collections').get();
        totalCollections += collectionsSnapshot.docs.length;

        for (final collectionDoc in collectionsSnapshot.docs) {
          final contentsSnapshot = await collectionDoc.reference.collection('contents').get();
          totalContents += contentsSnapshot.docs.length;
        }
      }

      return RepoStats(
        totalCourses: coursesSnapshot.docs.length,
        verifiedCourses: verifiedCount,
        totalCollections: totalCollections,
        totalContents: totalContents,
      );
    });
  }

  /// Get user's contribution stats
  Future<Future<Result<UserStats?>>> getUserStats({String? userId}) async {
    return Result.tryRunAsync(() async {
      final targetUserId = userId ?? await _getUserId();

      final coursesSnapshot = await _firestore
          .collection('repo')
          .doc('courses')
          .collection('courses')
          .where('submittedBy', isEqualTo: targetUserId)
          .get();

      return UserStats(coursesUploaded: coursesSnapshot.docs.length, userId: targetUserId);
    });
  }

  // ==================== HELPER METHODS ====================

  /// Update content lookup index with title crowdsourcing
  Future<void> _updateContentLookup({
    required String contentHash,
    required String courseId,
    required String title,
    required int fileSize,
  }) async {
    final docRef = _firestore.collection('content-lookup').doc(contentHash);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;

      // Skip update if admin has overridden the title
      if (data['adminOverride'] == true) {
        // Still update course IDs though
        final courseIds = List<String>.from(data['courseIds'] ?? []);
        if (!courseIds.contains(courseId)) {
          await docRef.update({
            'courseIds': FieldValue.arrayUnion([courseId]),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        return;
      }

      final courseIds = List<String>.from(data['courseIds'] ?? []);
      if (!courseIds.contains(courseId)) {
        courseIds.add(courseId);
      }

      // Title voting/crowdsourcing logic
      final titleVotes = Map<String, int>.from(data['titleVotes'] ?? {});
      titleVotes[title] = (titleVotes[title] ?? 0) + 1;

      // Find most popular title
      String mostPopularTitle = title;
      int maxVotes = 0;
      titleVotes.forEach((t, votes) {
        if (votes > maxVotes) {
          maxVotes = votes;
          mostPopularTitle = t;
        }
      });

      await docRef.update({
        'courseIds': courseIds,
        'lastUpdated': FieldValue.serverTimestamp(),
        'topTitle': mostPopularTitle,
        'titleVotes': titleVotes,
        'totalSubmissions': FieldValue.increment(1),
      });
    } else {
      await docRef.set({
        'contentHash': contentHash,
        'topTitle': title,
        'fileSize': fileSize,
        'courseIds': [courseId],
        'titleVotes': {title: 1},
        'totalSubmissions': 1,
        'adminOverride': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get current user ID
  Future<String> _getUserId() async {
    final result = await _userDataFunctions.getUserDetails();
    if (result.isError || result.data == null) {
      throw Exception('Unable to get user ID');
    }
    return result.data!.userID;
  }
}

// ==================== DATA MODELS ====================

/// Internal backup data structure
class _BackupData {
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> collections;
  final List<Map<String, dynamic>> contents;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String displayName;

  _BackupData({
    required this.courses,
    required this.collections,
    required this.contents,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'courses': courses,
      'collections': collections,
      'contents': contents,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'userName': userName,
      'displayName': displayName,
    };
  }

  factory _BackupData.fromMap(Map<String, dynamic> map) {
    return _BackupData(
      courses: List<Map<String, dynamic>>.from(map['courses'] ?? []),
      collections: List<Map<String, dynamic>>.from(map['collections'] ?? []),
      contents: List<Map<String, dynamic>>.from(map['contents'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
    );
  }
}

/// Result from downloading a backup
class BackupResult {
  final List<Course> courses;
  final List<CourseCollection> collections;
  final List<CourseContent> contents;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String displayName;

  BackupResult({
    required this.courses,
    required this.collections,
    required this.contents,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.displayName,
  });

  /// Convert to JSON for isolate transfer
  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((c) => c.toMap()).toList(),
      'collections': collections.map((c) => c.toMap()).toList(),
      'contents': contents.map((c) => c.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'displayName': displayName,
    };
  }

  /// Create from JSON for isolate transfer
  factory BackupResult.fromJson(Map<String, dynamic> json) {
    return BackupResult(
      courses: (json['courses'] as List).map((m) => Course.fromMap(m)).toList(),
      collections: (json['collections'] as List).map((m) => CourseCollection.fromMap(m)).toList(),
      contents: (json['contents'] as List).map((m) => CourseContent.fromMap(m)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userName: json['userName'],
      displayName: json['displayName'],
    );
  }
}

/// Repository course with metadata
class RepoCourse {
  final Course course;
  final bool verified;
  final String submittedBy;
  final String userName;
  final String displayName;
  final DocumentSnapshot lastDoc;

  RepoCourse({
    required this.course,
    required this.verified,
    required this.submittedBy,
    required this.userName,
    required this.displayName,
    required this.lastDoc,
  });
}

/// Full course details with all nested data
class CourseDetails {
  final Course course;
  final List<CourseCollection> collections;
  final List<CourseContent> contents;
  final bool verified;
  final String submittedBy;

  CourseDetails({
    required this.course,
    required this.collections,
    required this.contents,
    required this.verified,
    required this.submittedBy,
  });

  /// Convert to JSON for isolate transfer
  Map<String, dynamic> toJson() {
    return {
      'course': course.toMap(),
      'collections': collections.map((c) => c.toMap()).toList(),
      'contents': contents.map((c) => c.toMap()).toList(),
      'verified': verified,
      'submittedBy': submittedBy,
    };
  }

  /// Create from JSON for isolate transfer
  factory CourseDetails.fromJson(Map<String, dynamic> json) {
    return CourseDetails(
      course: Course.fromMap(json['course']),
      collections: (json['collections'] as List).map((m) => CourseCollection.fromMap(m)).toList(),
      contents: (json['contents'] as List).map((m) => CourseContent.fromMap(m)).toList(),
      verified: json['verified'],
      submittedBy: json['submittedBy'],
    );
  }
}

/// Content lookup result
class ContentLookupResult {
  final String contentHash;
  final String topTitle;
  final int fileSize;
  final List<String> courseIds;
  final DateTime lastUpdated;
  final Map<String, int> titleVotes;
  final int totalSubmissions;

  ContentLookupResult({
    required this.contentHash,
    required this.topTitle,
    required this.fileSize,
    required this.courseIds,
    required this.lastUpdated,
    this.titleVotes = const {},
    this.totalSubmissions = 0,
  });

  /// Get all title suggestions sorted by votes
  List<MapEntry<String, int>> get titlesSortedByVotes {
    final entries = titleVotes.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Convert to JSON for isolate transfer
  Map<String, dynamic> toJson() {
    return {
      'contentHash': contentHash,
      'topTitle': topTitle,
      'fileSize': fileSize,
      'courseIds': courseIds,
      'lastUpdated': lastUpdated.toIso8601String(),
      'titleVotes': titleVotes,
      'totalSubmissions': totalSubmissions,
    };
  }

  /// Create from JSON for isolate transfer
  factory ContentLookupResult.fromJson(Map<String, dynamic> json) {
    return ContentLookupResult(
      contentHash: json['contentHash'],
      topTitle: json['topTitle'],
      fileSize: json['fileSize'],
      courseIds: List<String>.from(json['courseIds']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      titleVotes: Map<String, int>.from(json['titleVotes'] ?? {}),
      totalSubmissions: json['totalSubmissions'] ?? 0,
    );
  }
}

/// Repository statistics
class RepoStats {
  final int totalCourses;
  final int verifiedCourses;
  final int totalCollections;
  final int totalContents;

  RepoStats({
    required this.totalCourses,
    required this.verifiedCourses,
    required this.totalCollections,
    required this.totalContents,
  });

  /// Convert to JSON for isolate transfer
  Map<String, dynamic> toJson() {
    return {
      'totalCourses': totalCourses,
      'verifiedCourses': verifiedCourses,
      'totalCollections': totalCollections,
      'totalContents': totalContents,
    };
  }

  /// Create from JSON for isolate transfer
  factory RepoStats.fromJson(Map<String, dynamic> json) {
    return RepoStats(
      totalCourses: json['totalCourses'],
      verifiedCourses: json['verifiedCourses'],
      totalCollections: json['totalCollections'],
      totalContents: json['totalContents'],
    );
  }
}

/// User contribution statistics
class UserStats {
  final int coursesUploaded;
  final String userId;

  UserStats({required this.coursesUploaded, required this.userId});

  /// Convert to JSON for isolate transfer
  Map<String, dynamic> toJson() {
    return {'coursesUploaded': coursesUploaded, 'userId': userId};
  }

  /// Create from JSON for isolate transfer
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(coursesUploaded: json['coursesUploaded'], userId: json['userId']);
  }
}
