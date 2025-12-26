import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/add_content/content_thumbnail_creator.dart';
import 'package:slidesync/shared/helpers/formatter.dart';

class CreateCourseUc {
  Future<Result<Course>> createCourseAction({
    String courseCode = '',
    required String courseName,
    String? courseImagePath,
  }) async {
    final Result<Course?> createCourseOutcome = await Result.tryRunAsync<Course>(() async {
      Course course = Course.create(courseTitle: Formatter.joinCodeToTitle(courseCode, courseName));

      if (courseImagePath != null) {
        await ContentThumbnailCreator.createThumbnailForCourse(courseImagePath, filename: course.courseId);
      }
      final author = (await UserDataFunctions().getUserDetails()).data?.userID;
      course = course.copyWith(metadataJson: (course.metadata.copyWith(author: author)).toJson());

      final createdId = await CourseRepo.addCourse(course);
      final Course? getCourse = await CourseRepo.getCourseByDbId(createdId);
      if (getCourse == null) return null;
      return getCourse;
    });

    if (createCourseOutcome.isSuccess) {
      return Result.success(createCourseOutcome.data!);
    }
    return Result.error("Unable to create course");
  }
}
