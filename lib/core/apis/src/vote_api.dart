part of '../api.dart';

class _VoteApi {
  // ── Course votes ───────────────────────────────────────────────────────────

  Future<Result<void>> voteCourse(
          {required String courseId, required String userId}) =>
      Result.tryRunAsync(() => ApiPaths.courseVote(courseId, userId).set({
            'value': 1,
            'createdAt': FieldValue.serverTimestamp(),
          }));

  Future<Result<void>> unvoteCourse(
          {required String courseId, required String userId}) =>
      Result.tryRunAsync(
          () => ApiPaths.courseVote(courseId, userId).delete());

  Future<Result<bool?>> hasVotedCourse(
          {required String courseId, required String userId}) =>
      Result.tryRunAsync(() async =>
          (await ApiPaths.courseVote(courseId, userId).get()).exists);

  /// Stream for real-time vote state on a course (e.g. to toggle heart icon).
  Stream<bool> streamCourseVote(
          {required String courseId, required String userId}) =>
      ApiPaths.courseVote(courseId, userId)
          .snapshots()
          .map((s) => s.exists);

  // ── Source votes ───────────────────────────────────────────────────────────

  Future<Result<void>> voteSource({
    required String contentHash,
    required String sourceOwnerId,
    required String voterId,
  }) =>
      Result.tryRunAsync(() =>
          ApiPaths.sourceVote(contentHash, sourceOwnerId, voterId).set({
            'value': 1,
            'createdAt': FieldValue.serverTimestamp(),
          }));

  Future<Result<void>> unvoteSource({
    required String contentHash,
    required String sourceOwnerId,
    required String voterId,
  }) =>
      Result.tryRunAsync(() =>
          ApiPaths.sourceVote(contentHash, sourceOwnerId, voterId).delete());

  Future<Result<bool?>> hasVotedSource({
    required String contentHash,
    required String sourceOwnerId,
    required String voterId,
  }) =>
      Result.tryRunAsync(() async =>
          (await ApiPaths.sourceVote(contentHash, sourceOwnerId, voterId).get())
              .exists);
}
