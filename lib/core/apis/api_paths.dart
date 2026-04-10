import 'package:cloud_firestore/cloud_firestore.dart';

import 'entities/course_entity.dart';
import 'entities/collection_entity.dart';
import 'entities/content_entity.dart';
import 'entities/source_entity.dart';
import 'entities/misc_entities.dart';

class ApiPaths {
  ApiPaths._();

  static final _db = FirebaseFirestore.instance;

  // ── Institutions & Catalog ─────────────────────────────────────────────────

  static CollectionReference<InstitutionEntity> institutions() =>
      _db.collection('institutions').withConverter(
            fromFirestore: InstitutionEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<InstitutionEntity> institution(String id) =>
      institutions().doc(id);

  static CollectionReference<CatalogEntity> catalog() =>
      _db.collection('catalog').withConverter(
            fromFirestore: CatalogEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<CatalogEntity> catalogEntry(String id) =>
      catalog().doc(id);

  // ── Users ──────────────────────────────────────────────────────────────────

  static DocumentReference<UserEntity> user(String uid) =>
      _db.collection('users').doc(uid).withConverter(
            fromFirestore: UserEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  // ── Public Courses ─────────────────────────────────────────────────────────

  static CollectionReference<CourseEntity> courses() =>
      _db.collection('courses').withConverter(
            fromFirestore: CourseEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<CourseEntity> course(String courseId) =>
      courses().doc(courseId);

  // ── Public Collections ─────────────────────────────────────────────────────

  static CollectionReference<CollectionEntity> collections(String courseId) =>
      _db
          .collection('courses')
          .doc(courseId)
          .collection('collections')
          .withConverter(
            fromFirestore: CollectionEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<CollectionEntity> collection(
          String courseId, String collectionId) =>
      collections(courseId).doc(collectionId);

  // ── Public Contents ────────────────────────────────────────────────────────

  static CollectionReference<ContentEntity> contents(
          String courseId, String collectionId) =>
      _db
          .collection('courses')
          .doc(courseId)
          .collection('collections')
          .doc(collectionId)
          .collection('contents')
          .withConverter(
            fromFirestore: ContentEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<ContentEntity> content(
          String courseId, String collectionId, String contentHash) =>
      contents(courseId, collectionId).doc(contentHash);

  // ── Votes (raw — presence is what matters, no converter needed) ────────────

  static DocumentReference<Map<String, dynamic>> courseVote(
          String courseId, String userId) =>
      _db
          .collection('courses')
          .doc(courseId)
          .collection('votes')
          .doc(userId);

  static DocumentReference<Map<String, dynamic>> sourceVote(
          String contentHash, String sourceOwnerId, String voterId) =>
      _db
          .collection('content-lookup')
          .doc(contentHash)
          .collection('sources')
          .doc(sourceOwnerId)
          .collection('votes')
          .doc(voterId);

  // ── Flags (raw — presence + reason, no converter needed) ──────────────────

  static DocumentReference<Map<String, dynamic>> courseFlag(
          String courseId, String userId) =>
      _db
          .collection('courses')
          .doc(courseId)
          .collection('flags')
          .doc(userId);

  static DocumentReference<Map<String, dynamic>> collectionFlag(
          String courseId, String collectionId, String userId) =>
      _db
          .collection('courses')
          .doc(courseId)
          .collection('collections')
          .doc(collectionId)
          .collection('flags')
          .doc(userId);

  static DocumentReference<Map<String, dynamic>> sourceFlag(
          String contentHash, String sourceOwnerId, String flaggerId) =>
      _db
          .collection('content-lookup')
          .doc(contentHash)
          .collection('sources')
          .doc(sourceOwnerId)
          .collection('flags')
          .doc(flaggerId);

  // ── Content Lookup ─────────────────────────────────────────────────────────

  static DocumentReference<Map<String, dynamic>> contentLookupEntry(
          String contentHash) =>
      _db.collection('content-lookup').doc(contentHash);

  static CollectionReference<SourceEntity> sources(String contentHash) =>
      _db
          .collection('content-lookup')
          .doc(contentHash)
          .collection('sources')
          .withConverter(
            fromFirestore: SourceEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<SourceEntity> source(
          String contentHash, String userId) =>
      sources(contentHash).doc(userId);

  static CollectionReference<SourceEntity> privateSources(
          String contentHash) =>
      _db
          .collection('content-lookup')
          .doc(contentHash)
          .collection('privateSources')
          .withConverter(
            fromFirestore: SourceEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<SourceEntity> privateSource(
          String contentHash, String userId) =>
      privateSources(contentHash).doc(userId);

  // ── Private Courses ────────────────────────────────────────────────────────
  // Path: /private/{uid}/courses/{courseId}
  // Each user owns their own private subtree — rules lock by uid.

  static CollectionReference<CourseEntity> privateCourses(String uid) =>
      _db
          .collection('private')
          .doc(uid)
          .collection('courses')
          .withConverter(
            fromFirestore: CourseEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<CourseEntity> privateCourse(
          String uid, String courseId) =>
      privateCourses(uid).doc(courseId);

  static CollectionReference<CollectionEntity> privateCollections(
          String uid, String courseId) =>
      _db
          .collection('private')
          .doc(uid)
          .collection('courses')
          .doc(courseId)
          .collection('collections')
          .withConverter(
            fromFirestore: CollectionEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<CollectionEntity> privateCollection(
          String uid, String courseId, String collectionId) =>
      privateCollections(uid, courseId).doc(collectionId);

  static CollectionReference<ContentEntity> privateContents(
          String uid, String courseId, String collectionId) =>
      _db
          .collection('private')
          .doc(uid)
          .collection('courses')
          .doc(courseId)
          .collection('collections')
          .doc(collectionId)
          .collection('contents')
          .withConverter(
            fromFirestore: ContentEntity.fromFirestore,
            toFirestore: (e, _) => e.toMap(),
          );

  static DocumentReference<ContentEntity> privateContent(
          String uid, String courseId, String collectionId,
          String contentHash) =>
      privateContents(uid, courseId, collectionId).doc(contentHash);
}
