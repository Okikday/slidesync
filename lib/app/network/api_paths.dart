import 'package:cloud_firestore/cloud_firestore.dart';

import 'entities/course_entity.dart';
import 'entities/collection_entity.dart';
import 'entities/content_entity.dart';
import 'entities/source_entity.dart';
import 'entities/misc_entities.dart';
import 'entities/vault_entity.dart';

class ApiPaths {
  ApiPaths._();

  static final _db = FirebaseFirestore.instance;

  // ── Institutions & Catalog ─────────────────────────────────────────────────

  static CollectionReference<InstitutionEntity> institutions() => _db
      .collection('institutions')
      .withConverter(fromFirestore: InstitutionEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<InstitutionEntity> institution(String id) => institutions().doc(id);

  static CollectionReference<CatalogEntity> catalog() => _db
      .collection('catalog')
      .withConverter(fromFirestore: CatalogEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<CatalogEntity> catalogEntry(String id) => catalog().doc(id);

  // ── Users ──────────────────────────────────────────────────────────────────

  static DocumentReference<UserEntity> user(String uid) => _db
      .collection('users')
      .doc(uid)
      .withConverter(fromFirestore: UserEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  // ── Public Courses ─────────────────────────────────────────────────────────

  static CollectionReference<CourseEntity> courses() => _db
      .collection('courses')
      .withConverter(fromFirestore: CourseEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<CourseEntity> course(String courseId) => courses().doc(courseId);

  // ── Public Collections (FLAT) ─────────────────────────────────────────────

  static CollectionReference<CollectionEntity> collections() => _db
      .collection('collections')
      .withConverter(fromFirestore: CollectionEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<CollectionEntity> collection(String collectionId) => collections().doc(collectionId);

  // ── Public Contents (FLAT) ─────────────────────────────────────────────────

  static CollectionReference<ContentEntity> contents() => _db
      .collection('contents')
      .withConverter(fromFirestore: ContentEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<ContentEntity> content(String contentId) => contents().doc(contentId);

  // ── Course Votes (nested subcollection per rules) ─────────────────────────

  static DocumentReference<Map<String, dynamic>> courseVote(String courseId, String userId) =>
      _db.collection('courseVotes').doc(courseId).collection('votes').doc(userId);

  // ── Course Flags (nested subcollection per rules) ────────────────────────

  static DocumentReference<Map<String, dynamic>> courseFlag(String courseId, String userId) =>
      _db.collection('courseFlags').doc(courseId).collection('flags').doc(userId);

  // ── Collection Flags (for flat collections, still nested per rules) ───────
  // Note: In your rules, there's no explicit collectionFlags collection.
  // Collections are flagged via their metadata or a parallel structure.
  // For now, storing at course level tagged with collectionId.
  static DocumentReference<Map<String, dynamic>> collectionFlag(String courseId, String collectionId, String userId) =>
      _db.collection('courseFlags').doc(courseId).collection('flags').doc('collection_${collectionId}_$userId');

  // ── Content Lookup ─────────────────────────────────────────────────────────

  static DocumentReference<Map<String, dynamic>> contentLookupEntry(String xxh3Hash) =>
      _db.collection('content-lookup').doc(xxh3Hash);

  static CollectionReference<SourceEntity> sources(String xxh3Hash) => _db
      .collection('content-lookup')
      .doc(xxh3Hash)
      .collection('sources')
      .withConverter(fromFirestore: SourceEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<SourceEntity> source(String xxh3Hash, String userId) => sources(xxh3Hash).doc(userId);

  static CollectionReference<SourceEntity> privateSources(String xxh3Hash) => _db
      .collection('content-lookup')
      .doc(xxh3Hash)
      .collection('privateSources')
      .withConverter(fromFirestore: SourceEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<SourceEntity> privateSource(String xxh3Hash, String userId) =>
      privateSources(xxh3Hash).doc(userId);

  // ── Source Votes (nested under sources) ────────────────────────────────────

  static DocumentReference<Map<String, dynamic>> sourceVote(String xxh3Hash, String sourceOwnerId, String voterId) =>
      _db
          .collection('content-lookup')
          .doc(xxh3Hash)
          .collection('sources')
          .doc(sourceOwnerId)
          .collection('votes')
          .doc(voterId);

  // ── Source Flags (nested under sources) ────────────────────────────────────

  static DocumentReference<Map<String, dynamic>> sourceFlag(String xxh3Hash, String sourceOwnerId, String flaggerId) =>
      _db
          .collection('content-lookup')
          .doc(xxh3Hash)
          .collection('sources')
          .doc(sourceOwnerId)
          .collection('flags')
          .doc(flaggerId);

  // ── Private Courses (FLAT) ─────────────────────────────────────────────────

  static CollectionReference<CourseEntity> privateCourses() => _db
      .collection('privateCourses')
      .withConverter(fromFirestore: CourseEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<CourseEntity> privateCourse(String courseId) => privateCourses().doc(courseId);

  // ── Private Collections (FLAT) ─────────────────────────────────────────────

  static CollectionReference<CollectionEntity> privateCollections() => _db
      .collection('privateCollections')
      .withConverter(fromFirestore: CollectionEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<CollectionEntity> privateCollection(String collectionId) =>
      privateCollections().doc(collectionId);

  // ── Private Contents (FLAT) ────────────────────────────────────────────────

  static CollectionReference<ContentEntity> privateContents() => _db
      .collection('privateContents')
      .withConverter(fromFirestore: ContentEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<ContentEntity> privateContent(String contentId) => privateContents().doc(contentId);

  // ── Storage Vault (admin only) ─────────────────────────────────────────────

  static CollectionReference<VaultEntity> storageVault() => _db
      .collection('storageVault')
      .withConverter(fromFirestore: VaultEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<VaultEntity> vaultEntry(String linkId) => storageVault().doc(linkId);

  static CollectionReference<VaultUploadEntity> vaultUploads(String linkId) => _db
      .collection('storageVault')
      .doc(linkId)
      .collection('uploads')
      .withConverter(fromFirestore: VaultUploadEntity.fromFirestore, toFirestore: (e, _) => e.toMap());

  static DocumentReference<VaultUploadEntity> vaultUpload(String linkId, String uploadId) =>
      vaultUploads(linkId).doc(uploadId);
}
