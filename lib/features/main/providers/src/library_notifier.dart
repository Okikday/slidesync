import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:slidesync/features/main/providers/entities/course_pagination_state.dart';
import 'package:slidesync/features/main/providers/entities/library_state.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/main/providers/src/courses_pagination_notifier.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';

const scrollTolerance = 20;

class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() {
    ref.onDispose(_dispose);
    scrollController.addListener(scrollListener);

    // Keep scroll offset notifier alive as long as the library tab is alive
    ref.emptyListenMany([scrollOffset]);
    return LibraryState();
  }

  void _dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    log("Disposed $runtimeType!");
  }

  void scrollListener() {
    final currOffset = scrollController.offset;
    final lastOffset = ref.read(scrollOffset);
    final tolerance = libraryAppBarMaxHeight + scrollTolerance;
    if (currOffset > tolerance && lastOffset > tolerance) return;

    if ((currOffset - lastOffset).abs() < 0.5) return;
    ref.read(scrollOffset.notifier).set(currOffset);
  }

  final ScrollController scrollController = ScrollController();
  final scrollOffset = _scrollOffsetNotifier;
  final coursesPagination = _coursesPaginationNotifier;
  final cardViewType = _cardViewTypeProvider;

  bool isAnyCardAnimating = false;
  Offset? cardTapPositionDetails;
}

///|
/// ===================================================================================================
/// EXTRA PROVIDERS
/// ===================================================================================================

final _scrollOffsetNotifier = NotifierProvider.autoDispose(() => DoubleNotifier());
final _coursesPaginationNotifier = NotifierProvider.autoDispose<CoursesPaginationNotifier, CoursePaginationState>(
  CoursesPaginationNotifier.new,
);

///|
///|
/// ===================================================================================================
/// OTHERS
/// ===================================================================================================

final _cardViewTypeProvider = AsyncNotifierProvider.autoDispose<CardViewTypeNotifier, int>(
  () => CardViewTypeNotifier(HiveDataPathKey.libraryTabCardViewType.name, 2),
);
