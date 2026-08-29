part of '../api.dart';

class _CourseApi {
  // ── Queries (expose typed Query for FirestoreListView / manual pagination) ─

  /// Typed query for all public courses. Caller applies filters, limit, cursor.
  /// e.g. Api.instance.courses.query()
  ///         .where('institutionId', isEqualTo: id)
  ///         .orderBy('createdAt', descending: true)
  ///         .limit(20)
  Query<CourseEntity> query() => ApiPaths.courses();

  /// Convenience: pre-filtered query by institution and/or catalog.
  Query<CourseEntity> queryBy({String? institutionId, String? catalogId, bool descending = true, int limit = 20}) {
    Query<CourseEntity> q = ApiPaths.courses().orderBy('createdAt', descending: descending);
    if (institutionId != null) {
      q = q.where('institutionId', isEqualTo: institutionId);
    }
    if (catalogId != null) {
      q = q.where('catalogId', isEqualTo: catalogId);
    }
    return q.limit(limit);
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<Result<CourseEntity?>> get(String courseId) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.course(courseId).get();
    return doc.data(); // withConverter handles mapping
  });

  Stream<CourseEntity?> stream(String courseId) => ApiPaths.course(courseId).snapshots().map((s) => s.data());

  /// Paginated fetch — pass [startAfter] doc snapshot for next page.
  Future<Result<PageResult<CourseEntity>?>> list({
    String? institutionId,
    String? catalogId,
    int limit = 20,
    DocumentSnapshot<CourseEntity>? startAfter,
  }) => Result.tryRunAsync(() async {
    Query<CourseEntity> q = queryBy(institutionId: institutionId, catalogId: catalogId, limit: limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snapshot = await q.get();
    return PageResult(
      items: snapshot.docs.map((d) => d.data()).toList(),
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  });

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<Result<String?>> create(CreateCourseInput input) => Result.tryRunAsync(() async {
    final ref = ApiPaths.courses().doc(); // UUID auto-generated
    await ref.set(
      // We bypass withConverter for create to use FieldValue.serverTimestamp()
      // by casting back to raw ref. The converter's toFirestore won't
      // accept FieldValue — this is the correct pattern for server timestamps.
      CourseEntity(
        courseId: ref.id,
        courseTitle: input.courseTitle,
        description: input.description,
        institutionId: input.institutionId,
        catalogId: input.catalogId,
        createdBy: input.createdBy,
        forkedFrom: input.forkedFrom,
        verified: false,
        flagCount: 0,
        createdAt: DateTime.now(), // placeholder; overridden below
        metadata: input.metadata,
      ),
    );
    // Patch createdAt with server timestamp after initial set
    await ref.update({'createdAt': FieldValue.serverTimestamp()});
    return ref.id;
  });

  Future<Result<String?>> fork({required String originalCourseId, required CreateCourseInput input}) => create(
    CreateCourseInput(
      courseTitle: input.courseTitle,
      description: input.description,
      institutionId: input.institutionId,
      catalogId: input.catalogId,
      createdBy: input.createdBy,
      forkedFrom: originalCourseId,
      metadata: input.metadata,
    ),
  );

  Future<Result<void>> update(String courseId, UpdateCourseInput input) =>
      Result.tryRunAsync(() => ApiPaths.course(courseId).update(input.toMap()));

  Future<Result<void>> delete(String courseId) => Result.tryRunAsync(() => ApiPaths.course(courseId).delete());

  // ── Private variants ──────────────────────────────────────────────────────

  Query<CourseEntity> privateQuery() => ApiPaths.privateCourses();

  Future<Result<CourseEntity?>> getPrivate(String courseId) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.privateCourse(courseId).get();
    return doc.data();
  });

  Future<Result<String?>> createPrivate(CreateCourseInput input) => Result.tryRunAsync(() async {
    final ref = ApiPaths.privateCourses().doc();
    await ref.set(
      CourseEntity(
        courseId: ref.id,
        courseTitle: input.courseTitle,
        description: input.description,
        institutionId: input.institutionId,
        catalogId: input.catalogId,
        createdBy: input.createdBy,
        forkedFrom: input.forkedFrom,
        verified: false,
        flagCount: 0,
        createdAt: DateTime.now(),
        metadata: input.metadata,
      ),
    );
    await ref.update({'createdAt': FieldValue.serverTimestamp()});
    return ref.id;
  });

  Future<Result<void>> updatePrivate(String courseId, UpdateCourseInput input) =>
      Result.tryRunAsync(() => ApiPaths.privateCourse(courseId).update(input.toMap()));

  Future<Result<void>> deletePrivate(String courseId) =>
      Result.tryRunAsync(() => ApiPaths.privateCourse(courseId).delete());
}
