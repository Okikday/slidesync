import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/main/providers/entities/home_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  // Getters for providers

  /// Provides the list of recently accessed content tracks, limited by [arg].
  final recentContentsTrack = _recentContentsTrackProvider;

  void setIsScrolled(bool isScrolled) => state = state.copyWith(isScrolled: isScrolled);
}

/// ------------------------------------------------------------------
/// Declarations of private providers used within HomeNotifier
/// ------------------------------------------------------------------
final _recentContentsTrackProvider = StreamNotifierProvider.autoDispose.family(
  (int arg) => StreamedNotifier<List<ContentTrack>>(() async* {
    yield* ContentTrackRepo.filter.uidIsNotEmpty().sortByLastReadDesc().limit(arg).watch(fireImmediately: true);
  }),
);
