import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/features/main/providers/entities/library_entities/course_pagination_state.dart';
import 'package:slidesync/features/main/providers/entities/library_entities/library_state.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/main/providers/src/library_notifier/src/courses_pagination_notifier.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';

const scrollTolerance = 20;

class LibraryNotifier extends Notifier<LibraryState> {
  ///|
  ///|
  /// ===================================================================================================
  /// DECLARATIONS
  /// ===================================================================================================
  final ScrollController scrollController = ScrollController();

  bool isAnyCardAnimating = false;
  Offset? cardTapPositionDetails;

  final scrollOffset = _scrollOffsetNotifier;
  final coursesPagination = _coursesPaginationNotifier;
  // final cardViewType = _cardViewTypeProvider;

  ///|
  ///|
  /// ===================================================================================================
  /// LIFECYCLE
  /// ===================================================================================================
  @override
  LibraryState build() {
    ref.onDispose(_dispose);
    scrollController.addListener(scrollListener);

    // Keep scroll offset notifier alive as long as the library tab is alive
    initState();
    return LibraryState(isLoading: false);
  }

  void initState() {
    ref.emptyListenMany([scrollOffset]);
    ref.listen(
      _cardViewTypeNotifier,
      (p, n) => n.whenData((newType) => state = state.copyWith(cardViewType: newType)),
      fireImmediately: true,
    );
  }

  void _dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    log("Disposed $runtimeType!");
  }

  ///|
  ///|
  /// ===================================================================================================
  /// LISTENERS
  /// ===================================================================================================

  void scrollListener() {
    final currOffset = scrollController.offset;
    final lastOffset = ref.read(scrollOffset);
    final tolerance = libraryAppBarMaxHeight + scrollTolerance;
    if ((currOffset > tolerance && lastOffset > tolerance) || (currOffset - lastOffset).abs() < 0.5) return;
    ref.read(scrollOffset.notifier).set(currOffset);
  }

  ///|
  ///|
  /// ===================================================================================================
  /// OTHERS
  /// ===================================================================================================

  void toggleCardViewType() async {
    final value = ref.read(_cardViewTypeNotifier).value;
    if (value == null) return;
    ref.read(_cardViewTypeNotifier.notifier).set(value == CardViewType.list ? CardViewType.grid : CardViewType.list);
  }

  void setLoading(bool isLoading) => state = state.copyWith(isLoading: isLoading);
}

///|
///|
/// ===================================================================================================
/// OTHERS
/// ===================================================================================================
final _scrollOffsetNotifier = NotifierProvider.autoDispose(() => DoubleNotifier());
final _coursesPaginationNotifier = NotifierProvider<CoursesPaginationNotifier, CoursePaginationState>(
  CoursesPaginationNotifier.new,
);

final _cardViewTypeNotifier = AsyncNotifierProvider.autoDispose(
  () => CardViewTypeNotifier(HiveDataPathKey.libraryCourseCardViewType.name, CardViewType.list),
);
