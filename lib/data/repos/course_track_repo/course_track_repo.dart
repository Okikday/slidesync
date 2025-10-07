import 'package:isar/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';

class CourseTrackRepo {
  static final IsarData<CourseTrack> _isarData = IsarData.instance<CourseTrack>();
  static Future<Isar> get _isar async => await IsarData.isarFuture;
  static Future<Isar> get isar async => await _isar;
  static IsarData<CourseTrack> get isarData => _isarData;

  static Future<QueryBuilder<CourseTrack, CourseTrack, QFilterCondition>> get filter async =>
      (await _isar).courseTracks.filter();

  // static Future<QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>> _queryByCourseId(String courseId) async {
  //   return (await _isarData.query<CourseTrack>((q) => q.idGreaterThan(0))).filter().courseIdEqualTo(courseId);
  // }

  static Future<CourseTrack?> getByCourseId(String courseId) async {
    return await (await _isar).courseTracks.filter().courseIdEqualTo(courseId).findFirst();
  }

  static Stream<CourseTrack?> watchByCourseId(String courseId) async* {
    yield* (await _isar).courseTracks
        .filter()
        .courseIdEqualTo(courseId)
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  // static Future<CourseTrack?> deleteByCourseId(String courseId) async {
  //   final isar = await _isar;
  //   final CourseTrack? course = await getByCourseId(courseId);
  //   return await isar.writeTxn<CourseTrack?>(() async {
  //     if (course != null) {
  //       final idQuery = await _queryByCourseId(courseId);
  //       await idQuery.deleteFirst();
  //     }
  //     return course;
  //   });
  // }
}
