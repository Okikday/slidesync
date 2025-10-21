import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

final defaultCourseTrack = CourseTrack.create(courseId: "_");

final _courseTrackById = StreamProvider.autoDispose.family<CourseTrack, String>((ref, courseId) async* {
  yield* CourseTrackRepo.watchByCourseId(courseId).map((e) => defaultCourseTrack);
});

final _courseTrackProgress = StreamProvider.autoDispose.family<double, String>((ref, courseId) async* {
  yield* CourseTrackRepo.watchByCourseId(courseId).map((e) => e?.progress ?? 0.0);
});

class CourseTrackProviders {
  static StreamProvider<CourseTrack> courseTrack(String courseId) => _courseTrackById(courseId);
  static StreamProvider<double> courseTrackProgress(String courseId) => _courseTrackProgress(courseId);
}
