part of '../api.dart';

class _CollectionApi {
  Query<CollectionEntity> query(String courseId) =>
      ApiPaths.collections().where('courseId', isEqualTo: courseId).orderBy('order');

  Future<Result<CollectionEntity?>> get(String collectionId) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.collection(collectionId).get();
    return doc.data();
  });

  Stream<CollectionEntity?> stream(String collectionId) =>
      ApiPaths.collection(collectionId).snapshots().map((s) => s.data());

  /// Collections filtered by courseId — pagination still supported.
  Future<Result<PageResult<CollectionEntity>?>> list({
    required String courseId,
    int limit = 50, // collections per course are bounded, so higher default
    DocumentSnapshot<CollectionEntity>? startAfter,
  }) => Result.tryRunAsync(() async {
    Query<CollectionEntity> q = ApiPaths.collections()
        .where('courseId', isEqualTo: courseId)
        .orderBy('courseId')
        .orderBy('order')
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snapshot = await q.get();
    return PageResult(
      items: snapshot.docs.map((d) => d.data()).toList(),
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  });

  Future<Result<String?>> create(String courseId, CreateCollectionInput input) => Result.tryRunAsync(() async {
    final ref = ApiPaths.collections().doc();
    await ref.set(
      CollectionEntity(
        collectionId: ref.id,
        courseId: courseId,
        collectionTitle: input.collectionTitle,
        description: input.description,
        order: input.order,
        createdBy: input.createdBy,
        forkedFrom: input.forkedFrom,
        flagCount: 0,
        createdAt: DateTime.now(),
        metadata: input.metadata,
      ),
    );
    await ref.update({'createdAt': FieldValue.serverTimestamp()});
    return ref.id;
  });

  Future<Result<String?>> fork({
    required String targetCourseId,
    required String originalCollectionId,
    required CreateCollectionInput input,
  }) => create(
    targetCourseId,
    CreateCollectionInput(
      collectionTitle: input.collectionTitle,
      description: input.description,
      order: input.order,
      createdBy: input.createdBy,
      forkedFrom: originalCollectionId,
      metadata: input.metadata,
    ),
  );

  Future<Result<void>> update(String collectionId, UpdateCollectionInput input) =>
      Result.tryRunAsync(() => ApiPaths.collection(collectionId).update(input.toMap()));

  Future<Result<void>> delete(String collectionId) =>
      Result.tryRunAsync(() => ApiPaths.collection(collectionId).delete());

  // ── Private variants ───────────────────────────────────────────────────────

  Query<CollectionEntity> privateQuery(String courseId) =>
      ApiPaths.privateCollections().where('courseId', isEqualTo: courseId).orderBy('order');

  Future<Result<String?>> createPrivate(String courseId, CreateCollectionInput input) => Result.tryRunAsync(() async {
    final ref = ApiPaths.privateCollections().doc();
    await ref.set(
      CollectionEntity(
        collectionId: ref.id,
        courseId: courseId,
        collectionTitle: input.collectionTitle,
        description: input.description,
        order: input.order,
        createdBy: input.createdBy,
        forkedFrom: input.forkedFrom,
        flagCount: 0,
        createdAt: DateTime.now(),
        metadata: input.metadata,
      ),
    );
    await ref.update({'createdAt': FieldValue.serverTimestamp()});
    return ref.id;
  });

  Future<Result<void>> updatePrivate(String collectionId, UpdateCollectionInput input) =>
      Result.tryRunAsync(() => ApiPaths.privateCollection(collectionId).update(input.toMap()));

  Future<Result<void>> deletePrivate(String collectionId) =>
      Result.tryRunAsync(() => ApiPaths.privateCollection(collectionId).delete());
}
