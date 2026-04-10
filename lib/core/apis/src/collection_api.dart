part of '../api.dart';

class _CollectionApi {
  Query<CollectionEntity> query(String courseId) =>
      ApiPaths.collections(courseId).orderBy('order');

  Future<Result<CollectionEntity?>> get(
          String courseId, String collectionId) =>
      Result.tryRunAsync(() async {
        final doc = await ApiPaths.collection(courseId, collectionId).get();
        return doc.data();
      });

  Stream<CollectionEntity?> stream(String courseId, String collectionId) =>
      ApiPaths.collection(courseId, collectionId)
          .snapshots()
          .map((s) => s.data());

  /// Collections inside a course are ordered — pagination still supported.
  Future<Result<PageResult<CollectionEntity>?>> list({
    required String courseId,
    int limit = 50, // collections per course are bounded, so higher default
    DocumentSnapshot<CollectionEntity>? startAfter,
  }) =>
      Result.tryRunAsync(() async {
        Query<CollectionEntity> q =
            ApiPaths.collections(courseId).orderBy('order').limit(limit);
        if (startAfter != null) q = q.startAfterDocument(startAfter);
        final snapshot = await q.get();
        return PageResult(
          items: snapshot.docs.map((d) => d.data()).toList(),
          lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
          hasMore: snapshot.docs.length == limit,
        );
      });

  Future<Result<String?>> create(
          String courseId, CreateCollectionInput input) =>
      Result.tryRunAsync(() async {
        final ref = ApiPaths.collections(courseId).doc();
        await ref.set(CollectionEntity(
          collectionId: ref.id,
          collectionTitle: input.collectionTitle,
          description: input.description,
          order: input.order,
          createdBy: input.createdBy,
          forkedFrom: input.forkedFrom,
          flagCount: 0,
          createdAt: DateTime.now(),
          metadata: input.metadata,
        ));
        await ref.update({'createdAt': FieldValue.serverTimestamp()});
        return ref.id;
      });

  Future<Result<String?>> fork({
    required String targetCourseId,
    required String originalCollectionId,
    required CreateCollectionInput input,
  }) =>
      create(
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

  Future<Result<void>> update(String courseId, String collectionId,
          UpdateCollectionInput input) =>
      Result.tryRunAsync(() =>
          ApiPaths.collection(courseId, collectionId).update(input.toMap()));

  Future<Result<void>> delete(String courseId, String collectionId) =>
      Result.tryRunAsync(
          () => ApiPaths.collection(courseId, collectionId).delete());

  // ── Private variants ───────────────────────────────────────────────────────

  Query<CollectionEntity> privateQuery(String uid, String courseId) =>
      ApiPaths.privateCollections(uid, courseId).orderBy('order');

  Future<Result<String?>> createPrivate(
          String uid, String courseId, CreateCollectionInput input) =>
      Result.tryRunAsync(() async {
        final ref = ApiPaths.privateCollections(uid, courseId).doc();
        await ref.set(CollectionEntity(
          collectionId: ref.id,
          collectionTitle: input.collectionTitle,
          description: input.description,
          order: input.order,
          createdBy: input.createdBy,
          forkedFrom: input.forkedFrom,
          flagCount: 0,
          createdAt: DateTime.now(),
          metadata: input.metadata,
        ));
        await ref.update({'createdAt': FieldValue.serverTimestamp()});
        return ref.id;
      });

  Future<Result<void>> updatePrivate(String uid, String courseId,
          String collectionId, UpdateCollectionInput input) =>
      Result.tryRunAsync(() => ApiPaths.privateCollection(uid, courseId, collectionId)
          .update(input.toMap()));

  Future<Result<void>> deletePrivate(
          String uid, String courseId, String collectionId) =>
      Result.tryRunAsync(
          () => ApiPaths.privateCollection(uid, courseId, collectionId).delete());
}
