import 'package:isar/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class ContentTrackRepo {
  static final IsarData<ContentTrack> _isarData = IsarData.instance<ContentTrack>();
  static Future<Isar> get _isar async => await IsarData.isarFuture;
  static Future<Isar> get isar async => await _isar;
  static IsarData<ContentTrack> get isarData => _isarData;

  static Future<QueryBuilder<ContentTrack, ContentTrack, QFilterCondition>> get filter async =>
      (await _isar).contentTracks.filter();

  static Future<QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>> _queryByContentId(
    String contentId,
  ) async {
    return (await _isarData.query<ContentTrack>((q) => q.idGreaterThan(0))).filter().contentIdEqualTo(contentId);
  }

  static Future<int> add(ContentTrack contentTrack) async {
    final existingContentTrack = await (await ContentTrackRepo.filter)
        .contentIdEqualTo(contentTrack.contentId)
        .findFirst();
    if (existingContentTrack == null) {
      final courseTrack = await (await CourseTrackRepo.filter).courseIdEqualTo(contentTrack.parentId).findFirst();
      if (courseTrack == null) return -1;
      await courseTrack.contentTracks.load();
      courseTrack.contentTracks.add(contentTrack);
      final isar = (await _isar);
      return isar.writeTxn(() async {
        await isar.courseTracks.put(courseTrack);
        return await isar.contentTracks.put(contentTrack);
      });
    } else {
      return ContentTrackRepo.isarData.store(contentTrack);
    }
  }

  static Future<ContentTrack?> getByContentId(String contentId) async {
    return await (await _isar).contentTracks.filter().contentIdEqualTo(contentId).findFirst();
  }

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<ContentTrack?> deleteByContentId(String contentId) async {
    final isar = await _isar;
    final ContentTrack? course = await getByContentId(contentId);
    return await isar.writeTxn<ContentTrack?>(() async {
      if (course != null) {
        final idQuery = await _queryByContentId(contentId);
        await idQuery.deleteFirst();
      }
      return course;
    });
  }
}
