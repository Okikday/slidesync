import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/progress_track_models/course_track.dart';
import 'package:slidesync/domain/repos/course_track_repo/course_track_repo.dart';

class CourseRepo {
  static final IsarData<Course> _isarData = IsarData.instance<Course>();
  static Future<Isar> get _isar async => await IsarData.isarFuture;
  static Future<Isar> get isar async => await _isar;
  static IsarData<Course> get isarData => _isarData;

  static Future<QueryBuilder<Course, Course, QFilterCondition>> get filter async => (await _isar).courses.filter();

  // static Future<QueryBuilder<Course, Course, QAfterFilterCondition>> _queryById(String courseId) async {
  //   return (await _isarData.query<Course>((q) => q.idGreaterThan(0))).filter().courseIdEqualTo(courseId);
  // }

  // static Future<void> deleteCourseByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<Course?> getCourseByDbId(int dbId) => _isarData.getById(dbId);

  static Stream<Course?> watchCourseByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> addCourse(Course course) async {
    final existingCourseTrack = await (await CourseTrackRepo.filter).courseIdEqualTo(course.courseId).findFirst();
    if (existingCourseTrack == null) {
      final newCourseTrack = CourseTrack.create(
        courseId: course.courseId,
        title: course.courseTitle,
        description: course.description,
      );
      await CourseTrackRepo.isarData.store(newCourseTrack);
    }

    return await _isarData.store(course);
  }

  static Future<List<int>> addMultipleCourses(List<Course> courses) async => await _isarData.storeAll(courses);

  static Future<List<Course>> getAllCourses() async => _isarData.getAll();

  static Stream<List<Course>> watchAllCourses() => _isarData.watchAll();

  static Future<Stream<List<Course>>> watchAllCoursesLazily() async => await _isarData.watchAllLazily();

  static Future<Course?> getCourseById(String courseId) async {
    return await (await _isar).courses.filter().courseIdEqualTo(courseId).findFirst();
  }

  static Stream<Course?> watchCourseById(String courseId) async* {
    yield* (await _isar).courses
        .filter()
        .courseIdEqualTo(courseId)
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  static Future<Course?> deleteCourseById(String courseId) async {
    final isar = await _isar;
    final Course? course = await getCourseById(courseId);
    return await isar.writeTxn<Course?>(() async {
      if (course != null) {
        final idQuery = (await filter).courseIdEqualTo(courseId);
        await idQuery.deleteFirst();
        await (await CourseTrackRepo.filter).courseIdEqualTo(courseId).deleteFirst();
      }
      return course;
    });
  }
}
