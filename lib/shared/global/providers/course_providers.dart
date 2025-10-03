
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';

final defaultCourse = Course.create(courseTitle: "_", courseId: '_');
final _watchCourseById = StreamNotifierProvider.family((String arg) => CourseStreamNotifier(arg), isAutoDispose: true);

class CourseProviders {
  static StreamNotifierProvider<CourseStreamNotifier, Course> courseProvider(String courseId) =>
      _watchCourseById(courseId);
}

class CourseStreamNotifier extends StreamNotifier<Course> {
  final String courseId;
  CourseStreamNotifier(this.courseId);
  @override
  Stream<Course> build() async* {
    yield* CourseRepo.watchCourseById(courseId).map((c) => c ?? defaultCourse);
  }

  @override
  bool updateShouldNotify(AsyncValue<Course> previous, AsyncValue<Course> next) {
    return true;
  }
}
