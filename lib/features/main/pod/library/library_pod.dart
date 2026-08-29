import 'package:flutter/widgets.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/features/main/pod/library/courses_pagination/course_pagination_state.dart';
import 'package:slidesync/features/main/pod/library/library_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/main/pod/library/courses_pagination/courses_pagination_pod.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';

const scrollTolerance = 20;

final _libraryPod = NotifierProvider(LibraryPod.new, isAutoDispose: true);

class LibraryPod extends Notifier<LibraryState> {
  static NotifierProvider<LibraryPod, LibraryState> get me => _libraryPod;

  static final coursesPaginator = _coursesPaginationNotifier;
  static final scrollOffset = _scrollOffsetNotifier;

  ///|
  ///|
  /// ===================================================================================================
  /// DECLARATIONS
  /// ===================================================================================================

  bool isAnyCardAnimating = false;
  Offset? cardTapPositionDetails;

  // final cardViewType = _cardViewTypeProvider;

  ///|
  ///|
  /// ===================================================================================================
  /// LIFECYCLE
  /// ===================================================================================================
  @override
  LibraryState build() {
    // Keep scroll offset notifier alive as long as the library tab is alive
    ref.listen(
      _cardViewTypeNotifier,
      (p, n) => n.whenData(
        (newType) => state = state.copyWith(cardViewType: newType),
      ),
      fireImmediately: true,
    );
    return LibraryState(isLoading: false);
  }

  ///|
  ///|
  /// ===================================================================================================
  /// METHODS
  /// ===================================================================================================

  void toggleCardViewType() async {
    final value = ref.read(_cardViewTypeNotifier).value;
    if (value == null) return;
    ref
        .read(_cardViewTypeNotifier.notifier)
        .set(
          value == CardViewType.list ? CardViewType.grid : CardViewType.list,
        );
  }

  void setLoading(bool isLoading) =>
      state = state.copyWith(isLoading: isLoading);
}

///|
///|
/// ===================================================================================================
/// OTHERS
/// ===================================================================================================
final _scrollOffsetNotifier = NotifierProvider.autoDispose(
  () => DoubleNotifier(),
  dependencies: [LibraryPod.me],
);
final _coursesPaginationNotifier =
    NotifierProvider<CoursesPaginationPod, CoursePaginationState>(
      CoursesPaginationPod.new,
      dependencies: [LibraryPod.me],
    );

final _cardViewTypeNotifier = AsyncNotifierProvider.autoDispose(
  () => CardViewTypeNotifier(
    HiveDataKey.libraryCourseCardViewType.name,
    CardViewType.list,
  ),
);
