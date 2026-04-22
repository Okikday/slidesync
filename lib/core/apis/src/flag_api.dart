part of '../api.dart';

class _FlagApi {
  Future<Result<void>> flagCourse({required String courseId, required String userId, required String reason}) =>
      Result.tryRunAsync(
        () => ApiPaths.courseFlag(courseId, userId).set({'reason': reason, 'createdAt': FieldValue.serverTimestamp()}),
      );

  Future<Result<void>> unflagCourse({required String courseId, required String userId}) =>
      Result.tryRunAsync(() => ApiPaths.courseFlag(courseId, userId).delete());

  Future<Result<void>> flagCollection({
    required String courseId,
    required String collectionId,
    required String userId,
    required String reason,
  }) => Result.tryRunAsync(
    () => ApiPaths.collectionFlag(
      courseId,
      collectionId,
      userId,
    ).set({'reason': reason, 'createdAt': FieldValue.serverTimestamp()}),
  );

  Future<Result<void>> unflagCollection({
    required String courseId,
    required String collectionId,
    required String userId,
  }) => Result.tryRunAsync(() => ApiPaths.collectionFlag(courseId, collectionId, userId).delete());

  Future<Result<void>> flagSource({
    required String xxh3Hash,
    required String sourceOwnerId,
    required String flaggerId,
    required String reason,
  }) => Result.tryRunAsync(
    () => ApiPaths.sourceFlag(
      xxh3Hash,
      sourceOwnerId,
      flaggerId,
    ).set({'reason': reason, 'createdAt': FieldValue.serverTimestamp()}),
  );

  Future<Result<void>> unflagSource({
    required String xxh3Hash,
    required String sourceOwnerId,
    required String flaggerId,
  }) => Result.tryRunAsync(() => ApiPaths.sourceFlag(xxh3Hash, sourceOwnerId, flaggerId).delete());
}
