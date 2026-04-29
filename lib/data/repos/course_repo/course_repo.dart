import 'package:isar_community/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';

class CourseRepo {
  static final IsarData<Course> _isarData = IsarData<Course>();
  static IsarData<Course> get isarData => _isarData;
  static Isar get _isar => _isarData.isarInstance;
  static Isar get isar => _isar;

  static QueryBuilder<Course, Course, QFilterCondition> get filter => _isar.courses.filter();

  // static Future<QueryBuilder<Course, Course, QAfterFilterCondition>> _queryById(String courseId) async {
  //   return (await _isarData.query<Course>((q) => q.idGreaterThan(0))).filter().uidEqualTo(courseId);
  // }

  static Future<Course?> getCourseById(int dbId) async => _isarData.getById(dbId);

  static Stream<Course?> watchCourseByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> addCourse(Course course) async {
    if (course.uid.trim().isEmpty || course.uid == "_") return -1;

    final existingCourseTrack = await _isar.courseTracks.filter().uidEqualTo(course.uid).findFirst();

    final newCourseTrack = existingCourseTrack == null
        ? CourseTrack.create(courseId: course.uid, title: course.title, description: course.description)
        : null;

    return await _isar.writeTxn(() async {
      if (newCourseTrack != null) await _isar.courseTracks.put(newCourseTrack);
      return await _isar.courses.put(course);
    });
  }

  // static Future<List<int>> addMultipleCourses(List<Course> courses) async => await _isarData.storeAll(courses);

  static Future<List<Course>> getAllCourses() async => _isarData.getAll();

  static Stream<List<Course>> watchAllCourses() => _isarData.watchAll();

  // static Future<Stream<List<Course>>> watchAllCoursesLazily() async => await _isarData.watchAllLazily();

  static Future<Course?> getByUid(String courseId) => _isar.courses.filter().uidEqualTo(courseId).findFirst();

  static Future<Course?> get(Id id) => _isarData.get(id);

  static Stream<Course?> watchCourseById(String courseId) async* {
    yield* _isar.courses.filter().uidEqualTo(courseId).watch(fireImmediately: true).map((list) => list.firstOrNull);
  }

  static Future<bool> delete(int id) => _isarData.delete(id);

  // static Future<Course?> deleteCourseById(String courseId) async {
  //   final Course? course = await getCourseByUid(courseId);
  //   if (course == null) return course;
  //   final idQuery = (filter).uidEqualTo(courseId);
  //   return await _isar.writeTxn<Course?>(() async {
  //     await idQuery.deleteFirst();
  //     await (CourseTrackRepo.filter).uidEqualTo(courseId).deleteFirst();
  //     return course;
  //   });
  // }
}
