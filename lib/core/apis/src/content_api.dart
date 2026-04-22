part of '../api.dart';

class _ContentApi {
  Query<ContentEntity> query(String collectionId) =>
      ApiPaths.contents().where('collectionId', isEqualTo: collectionId).orderBy('createdAt', descending: false);

  Future<Result<ContentEntity?>> get(String contentId) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.content(contentId).get();
    return doc.data();
  });

  Future<Result<PageResult<ContentEntity>?>> list({
    required String collectionId,
    int limit = 30,
    DocumentSnapshot<ContentEntity>? startAfter,
  }) => Result.tryRunAsync(() async {
    Query<ContentEntity> q = ApiPaths.contents()
        .where('collectionId', isEqualTo: collectionId)
        .orderBy('collectionId')
        .orderBy('createdAt')
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snapshot = await q.get();
    return PageResult(
      items: snapshot.docs.map((d) => d.data()).toList(),
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  });

  /// Doc ID = xxh3Hash → deduplication at DB level.
  /// Uses raw ref to safely write FieldValue.serverTimestamp.
  Future<Result<void>> add({required String collectionId, required String xxh3Hash, required AddContentInput input}) =>
      Result.tryRunAsync(() async {
        final ref = ApiPaths.content(xxh3Hash);
        // Use raw (non-converter) ref for the write to support FieldValue
        await FirebaseFirestore.instance
            .collection('contents')
            .doc(xxh3Hash)
            .set(ContentEntity.createMap(xxh3Hash, collectionId, input), SetOptions(merge: false));
        // If the doc already existed (same hash already in this collection),
        // the above is a no-op conflict — the merge:false ensures idempotency.
        ref;
      });

  /// Content pointers are immutable — no update method exposed.
  Future<Result<void>> delete({required String contentId}) =>
      Result.tryRunAsync(() => ApiPaths.content(contentId).delete());

  // ── Global content-lookup registry ────────────────────────────────────────

  /// Register hash in the global registry. Immutable after first write.
  /// Rules enforce no update/delete — safe to call without checking existence.
  Future<Result<void>> registerHash(String xxh3Hash) => Result.tryRunAsync(
    () => ApiPaths.contentLookupEntry(
      xxh3Hash,
    ).set({'xxh3Hash': xxh3Hash, 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: false)),
  );

  // ── Private variants ──────────────────────────────────────────────────────

  Query<ContentEntity> privateQuery(String collectionId) =>
      ApiPaths.privateContents().where('collectionId', isEqualTo: collectionId).orderBy('createdAt');

  Future<Result<void>> addPrivate({
    required String collectionId,
    required String xxh3Hash,
    required AddContentInput input,
  }) => Result.tryRunAsync(
    () => FirebaseFirestore.instance
        .collection('privateContents')
        .doc(xxh3Hash)
        .set(ContentEntity.createMap(xxh3Hash, collectionId, input), SetOptions(merge: false)),
  );

  Future<Result<void>> deletePrivate({required String contentId}) =>
      Result.tryRunAsync(() => ApiPaths.privateContent(contentId).delete());
}
