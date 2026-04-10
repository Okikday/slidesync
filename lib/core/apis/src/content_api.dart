part of '../api.dart';

class _ContentApi {
  Query<ContentEntity> query(String courseId, String collectionId) =>
      ApiPaths.contents(courseId, collectionId).orderBy('createdAt', descending: false);

  Future<Result<ContentEntity?>> get({
    required String courseId,
    required String collectionId,
    required String contentHash,
  }) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.content(courseId, collectionId, contentHash).get();
    return doc.data();
  });

  Future<Result<PageResult<ContentEntity>?>> list({
    required String courseId,
    required String collectionId,
    int limit = 30,
    DocumentSnapshot<ContentEntity>? startAfter,
  }) => Result.tryRunAsync(() async {
    Query<ContentEntity> q = ApiPaths.contents(courseId, collectionId).orderBy('createdAt').limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snapshot = await q.get();
    return PageResult(
      items: snapshot.docs.map((d) => d.data()).toList(),
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  });

  /// Doc ID = contentHash → deduplication at DB level.
  /// Uses raw ref to safely write FieldValue.serverTimestamp.
  Future<Result<void>> add({
    required String courseId,
    required String collectionId,
    required String contentHash,
    required AddContentInput input,
  }) => Result.tryRunAsync(() async {
    final ref = ApiPaths.content(courseId, collectionId, contentHash);
    // Use raw (non-converter) ref for the write to support FieldValue
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('collections')
        .doc(collectionId)
        .collection('contents')
        .doc(contentHash)
        .set(ContentEntity.createMap(contentHash, input), SetOptions(merge: false));
    // If the doc already existed (same hash already in this collection),
    // the above is a no-op conflict — the merge:false ensures idempotency.
    ref;
  });

  /// Content pointers are immutable — no update method exposed.
  Future<Result<void>> delete({required String courseId, required String collectionId, required String contentHash}) =>
      Result.tryRunAsync(() => ApiPaths.content(courseId, collectionId, contentHash).delete());

  // ── Global content-lookup registry ────────────────────────────────────────

  /// Register hash in the global registry. Immutable after first write.
  /// Rules enforce no update/delete — safe to call without checking existence.
  Future<Result<void>> registerHash(String contentHash) => Result.tryRunAsync(
    () => ApiPaths.contentLookupEntry(
      contentHash,
    ).set({'contentHash': contentHash, 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: false)),
  );

  // ── Private variants ───────────────────────────────────────────────────────

  Query<ContentEntity> privateQuery(String uid, String courseId, String collectionId) =>
      ApiPaths.privateContents(uid, courseId, collectionId).orderBy('createdAt');

  Future<Result<void>> addPrivate({
    required String uid,
    required String courseId,
    required String collectionId,
    required String contentHash,
    required AddContentInput input,
  }) => Result.tryRunAsync(
    () => FirebaseFirestore.instance
        .collection('private')
        .doc(uid)
        .collection('courses')
        .doc(courseId)
        .collection('collections')
        .doc(collectionId)
        .collection('contents')
        .doc(contentHash)
        .set(ContentEntity.createMap(contentHash, input), SetOptions(merge: false)),
  );

  Future<Result<void>> deletePrivate({
    required String uid,
    required String courseId,
    required String collectionId,
    required String contentHash,
  }) => Result.tryRunAsync(() => ApiPaths.privateContent(uid, courseId, collectionId, contentHash).delete());
}
