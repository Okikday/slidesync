import 'package:isar_community/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class ContentTrackRepo {
  static final IsarData<ContentTrack> _isarData = IsarData<ContentTrack>();
  static IsarData<ContentTrack> get isarData => _isarData;
  static Isar get _isar => _isarData.isarInstance;
  static Isar get isar => _isar;

  static QueryBuilder<ContentTrack, ContentTrack, QFilterCondition> get filter => _isar.contentTracks.filter();

  static Future<QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>> _queryByContentId(
    String contentId,
  ) async {
    return (await _isarData.query<ContentTrack>((q) => q.idGreaterThan(0))).filter().uidEqualTo(contentId);
  }

  static Future<int> add(ContentTrack contentTrack) async {
    final existingContentTrack = await (ContentTrackRepo.filter).uidEqualTo(contentTrack.uid).findFirst();
    if (existingContentTrack == null) {
      final courseTrack = await (CourseTrackRepo.filter).uidEqualTo(contentTrack.courseId).findFirst();
      if (courseTrack == null) return -1;
      await courseTrack.contentTracks.load();
      courseTrack.contentTracks.add(contentTrack);
      final isar = _isar;
      return isar.writeTxn(() async {
        await isar.courseTracks.put(courseTrack);
        return await isar.contentTracks.put(contentTrack);
      });
    } else {
      return ContentTrackRepo.isarData.store(contentTrack);
    }
  }

  static Future<ContentTrack?> getByContentId(String contentId) async {
    return await _isar.contentTracks.filter().uidEqualTo(contentId).findFirst();
  }

  static Stream<ContentTrack?> watchByContentId(String contentId) async* {
    yield* _isar.contentTracks
        .filter()
        .uidEqualTo(contentId)
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  static Stream<ContentTrack?> watchById(int id) async* {
    yield* _isarData.watchById(id, fireImmediately: true);
  }

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<ContentTrack?> deleteByContentId(String contentId) async {
    final ContentTrack? course = await getByContentId(contentId);
    return await isar.writeTxn<ContentTrack?>(() async {
      if (course != null) {
        final idQuery = await _queryByContentId(contentId);
        await idQuery.deleteFirst();
      }
      return course;
    });
  }

  static Future<ContentTrack?> clearLastRead(String contentId) async {
    final track = await getByContentId(contentId);
    if (track == null) return null;

    track.lastRead = null;

    return await isar.writeTxn<ContentTrack?>(() async {
      await isar.contentTracks.put(track);
      return track;
    });
  }

  static Future<int> clearAllLastRead() async {
    final tracks = await _isar.contentTracks.filter().lastReadIsNotNull().findAll();
    if (tracks.isEmpty) return 0;

    for (final track in tracks) {
      track.lastRead = null;
    }

    return await _isar.writeTxn(() async {
      await _isar.contentTracks.putAll(tracks);
      return tracks.length;
    });
  }

  static double computeProgressForMultiple(IsarLinks<ContentTrack> contentTracks) {
    final totalProgress = contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress));
    return totalProgress / contentTracks.length;
  }
}
