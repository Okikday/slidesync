import 'dart:developer';
import 'dart:async';
import 'dart:math' as math;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/base/src/custom_notifiers.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/main/pod/library/courses_pagination/course_pagination_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

part 'ext_on_courses_pagination_pod.dart';

const int _limit = 20;

class CoursesPaginationPod extends Notifier<CoursePaginationState> {
  late final pagingController = PagingController<int, Course>(
    // value: PagingState(hasNextPage: false),
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: fetchPage,
  );

  _PaginationState _state = const _PaginationState();

  @override
  CoursePaginationState build() {
    log("Build $runtimeType");
    final coursesOrdering = ref.read(_coursesOrderingProvider).value;

    ref.listen(
      _coursesOrderingProvider,
      (prev, next) => next.whenData(
        (ordering) => updateCoursesOrdering(ordering, refresh: true),
      ),
    );

    ref.onDispose(() {
      pagingController.dispose();
      log("Disposed $runtimeType!");
    });

    ref.listen(
      _coursesUpdateStream,
      (prev, next) async => await _syncCourses(),
    );

    return CoursePaginationState(
      coursesOrdering: coursesOrdering ?? .dateModifiedDesc,
    );
  }

  /// Purpose: Updates the courses ordering
  void updateCoursesOrdering(
    CoursesOrdering coursesOrdering, {
    bool refresh = true,
  }) {
    if (state.coursesOrdering == coursesOrdering) return;

    state = state.copyWith(coursesOrdering: coursesOrdering);
    ref.read(_coursesOrderingProvider.notifier).set(coursesOrdering);

    if (refresh) _refreshAndFetchFirstPage();
  }

  /// Purpose: Fetches the pages in batches as requested.
  /// Returns: List of Courses as requested per page
  Future<List<Course>> fetchPage(int pageKey, [int? limit]) {
    limit ??= _limit;
    if (_state.pendingRefresh && pageKey == 1) {
      _state = _state.copyWith(pendingRefresh: false);
      scheduleMicrotask(
        () => pagingController
          ..refresh()
          ..fetchNextPage(),
      );
    }
    return _doFetch(pageKey, limit, state.coursesOrdering);
  }
}

///
/// ===================================================================================================
/// EXTRA PROVIDERS
/// ===================================================================================================
// final _coursesFilterProvider = AsyncNotifierProvider.autoDispose<CourseSortNotifier, CourseSortOption>(
//   () => CourseSortNotifier(HiveDataPathKey.libraryCourseSortOption.name),
// );

final _coursesOrderingProvider = AsyncNotifierProvider(
  () => KCachedNotifier<String, CoursesOrdering>(
    HiveDataKey.libraryCourseOrdering.name,
    .dateModifiedDesc,
    encode: (val) => val.name,
    decode: (raw) => CoursesOrdering.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => .dateModifiedDesc,
    ),
  ),
);

final _coursesUpdateStream = StreamNotifierProvider(
  () => StreamedNotifier(() async* {
    yield* (await CourseRepo.isarData.watchForChanges(
      fireImmediately: false,
    )).map((c) => DateTime.now().millisecondsSinceEpoch);
  }),
);
