import 'dart:developer';

import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/content_thumbnail_creator.dart';

class CreateCourseUc {
  Future<Result<Course>> createCourseAction({
    String courseCode = '',
    required String courseName,
    String? courseImagePath,
  }) async {
    final Result<Course?> createCourseOutcome = await Result.tryRunAsync<Course>(() async {
      final tempCourse = Course.create(
        title: courseName,
        metadata: CourseMetadata.create(
          courseCode: courseCode.trim().isNotEmpty ? courseCode.trim() : null,
          thumbnail: FilePath(local: courseImagePath),
        ),
      );
      log("Created course with title: ${tempCourse.title}, code: $courseCode");

      if (courseImagePath != null) {
        await ContentThumbnailCreator.createThumbnailForCourse(courseImagePath, filename: tempCourse.uid);
      }
      final author = (await UserDataFunctions().getUserDetails()).data?.userID;
      log("   Author ID: $author");
      final course = tempCourse.copyWith(
        metadata: (tempCourse.metadata.copyWith(author: author)),
        lastModified: DateTime.now(),
      );

      log(
        "Course after setting metadata - title: ${course.title}, author: ${course.metadata.author}, color: ${course.metadata.color}",
      );

      final createdId = await CourseRepo.addCourse(course);
      log(" Course added to repo with ID: $createdId");
      final getCourse = await CourseRepo.getCourseById(createdId);
      log(
        "Fetched course from repo: ${getCourse != null ? 'title: ${getCourse.title}, author: ${getCourse.metadata.author}, color: ${getCourse.metadata.color}' : 'Course not found'}",
      );
      return getCourse;
    });

    if (createCourseOutcome.isSuccess) {
      return Result.success(createCourseOutcome.data!);
    }
    return Result.error("Unable to create course");
  }
}
