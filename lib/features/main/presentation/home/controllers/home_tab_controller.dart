import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/utils/leak_prevention.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';

// final Provider<HomeTabController> homeTabControllerProvider = Provider((ref) {
//   final htc = HomeTabController();
//   ref.onDispose(() => htc.dispose());
//   return htc;
// }, isAutoDispose: true);

final _recentContentsTrackProvider = StreamProvider<List<ContentTrack>>((ref) async* {
  yield* (await ContentTrackRepo.filter)
      .lastReadIsNotNull()
      .sortByLastReadDesc()
      .limit(10)
      .watch(fireImmediately: true);
}, isAutoDispose: true);

class HomeTabController extends LeakPrevention {
  /// Recent contents
  static StreamProvider<List<ContentTrack>> get recentContentsTrackProvider => _recentContentsTrackProvider;

  @override
  void onDispose() {}
}
