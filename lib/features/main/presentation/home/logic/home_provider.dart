import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';

// final Provider<HomeTabController> homeTabControllerProvider = Provider((ref) {
//   final htc = HomeTabController();
//   ref.onDispose(() => htc.dispose());
//   return htc;
// }, isAutoDispose: true);

class HomeProvider {
  ///|
  ///|
  /// ===================================================================================================
  /// STATE
  /// ===================================================================================================

  ///|
  ///|
  /// ===================================================================================================
  /// OTHERS
  /// ===================================================================================================
  static final recentContentsTrackProvider = StreamProvider.autoDispose.family<List<ContentTrack>, int>((
    ref,
    arg,
  ) async* {
    yield* (await ContentTrackRepo.filter)
        .lastReadIsNotNull()
        .sortByLastReadDesc()
        .limit(arg)
        .watch(fireImmediately: true);
  });
}
