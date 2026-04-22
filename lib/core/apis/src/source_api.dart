part of '../api.dart';

class _SourceApi {
  Future<Result<void>> add({required String xxh3Hash, required String userId, required CreateSourceInput input}) =>
      Result.tryRunAsync(
        () => FirebaseFirestore.instance
            .collection('content-lookup')
            .doc(xxh3Hash)
            .collection('sources')
            .doc(userId)
            .set(SourceEntity.createMap(input)),
      );

  Future<Result<void>> update({required String xxh3Hash, required String userId, required UpdateSourceInput input}) =>
      Result.tryRunAsync(() => ApiPaths.source(xxh3Hash, userId).update(input.toMap()));

  Future<Result<void>> delete({required String xxh3Hash, required String userId}) =>
      Result.tryRunAsync(() => ApiPaths.source(xxh3Hash, userId).delete());

  Future<Result<SourceEntity?>> get({required String xxh3Hash, required String userId}) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.source(xxh3Hash, userId).get();
    return doc.data();
  });

  /// Returns all non-flagged sources for a hash (paginated).
  Future<Result<PageResult<SourceEntity>?>> list({
    required String xxh3Hash,
    int limit = 20,
    DocumentSnapshot<SourceEntity>? startAfter,
  }) => Result.tryRunAsync(() async {
    Query<SourceEntity> q = ApiPaths.sources(
      xxh3Hash,
    ).where('flagged', isEqualTo: false).orderBy('createdAt').limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snapshot = await q.get();
    return PageResult(
      items: snapshot.docs.map((d) => d.data()).toList(),
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  });

  /// Source resolution logic:
  /// 1. Most votes → 2. Earliest createdAt → 3. null (unavailable)
  Future<Result<ResolvedSource?>> resolve(String xxh3Hash) => Result.tryRunAsync(() async {
    final snapshot = await ApiPaths.sources(xxh3Hash).where('flagged', isEqualTo: false).get();

    if (snapshot.docs.isEmpty) return null;

    final sources = snapshot.docs.map((d) => d.data()).toList();

    final resolved = await Future.wait(
      sources.map((src) async {
        final votesSnap = await FirebaseFirestore.instance
            .collection('content-lookup')
            .doc(xxh3Hash)
            .collection('sources')
            .doc(src.userId)
            .collection('votes')
            .count()
            .get();
        return ResolvedSource(source: src, voteCount: votesSnap.count ?? 0);
      }),
    );

    resolved.sort((a, b) {
      final v = b.voteCount.compareTo(a.voteCount);
      if (v != 0) return v;
      return a.source.createdAt.compareTo(b.source.createdAt);
    });

    return resolved.first;
  });

  // ── Private variants ───────────────────────────────────────────────────────

  Future<Result<void>> addPrivate({
    required String xxh3Hash,
    required String userId,
    required CreateSourceInput input,
  }) => Result.tryRunAsync(
    () => FirebaseFirestore.instance
        .collection('content-lookup')
        .doc(xxh3Hash)
        .collection('privateSources')
        .doc(userId)
        .set(SourceEntity.createMap(input)),
  );

  Future<Result<void>> deletePrivate({required String xxh3Hash, required String userId}) =>
      Result.tryRunAsync(() => ApiPaths.privateSource(xxh3Hash, userId).delete());
}
