import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';

final defaultCourse = Course.create(courseTitle: "_", courseId: '_');
final _courseByDbId = StreamProvider.family<Course?, int>((ref, arg) {
  return CourseRepo.watchCourseByDbId(arg);
}, isAutoDispose: true);

class CourseProviders {
  static StreamProvider<Course?> courseProvider(int dbId) => _courseByDbId(dbId);
}
