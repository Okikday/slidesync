import 'dart:developer';
import 'dart:async';
import 'dart:math' as math;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/main/providers/entities/library_entities/course_pagination_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class CoursesPaginationNotifier extends Notifier<CoursePaginationState> {
  late final PagingController<int, Course> pagingController = PagingController(
    // value: PagingState(hasNextPage: false),
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => fetchPage(pageKey, limit),
  );

  bool isUpdating = false;
  bool extraCheck = false;
  bool _pendingRefresh = false;
  static const int limit = 20;

  @override
  CoursePaginationState build() {
    log("Build $runtimeType");
    final coursesOrdering = ref.read(_coursesOrderingProvider).value;

    ref.listen(
      _coursesOrderingProvider,
      (prev, next) => next.whenData((ordering) => updateCoursesOrdering(ordering, refresh: true)),
    );

    ref.onDispose(() {
      pagingController.dispose();
      log("Disposed $runtimeType!");
    });

    ref.listen(_coursesUpdateStream, (prev, next) async => await _syncCourses());

    return CoursePaginationState(coursesOrdering: coursesOrdering ?? EntityOrdering.dateModifiedDesc);
  }

  void updateCoursesOrdering(EntityOrdering coursesOrdering, {bool refresh = true}) {
    if (state.coursesOrdering == coursesOrdering) return;

    state = state.copyWith(coursesOrdering: coursesOrdering);
    ref.read(_coursesOrderingProvider.notifier).set(coursesOrdering);

    if (refresh) _refreshAndFetchFirstPage();
  }

  Future<List<Course>> fetchPage(int pageKey, int limit) {
    if (_pendingRefresh && pageKey == 1) {
      _pendingRefresh = false;
      scheduleMicrotask(
        () => pagingController
          ..refresh()
          ..fetchNextPage(),
      );
    }
    return _doFetch(pageKey, limit, state.coursesOrdering);
  }

  Future<void> _refreshAndFetchFirstPage() async {
    if (pagingController.value.isLoading) {
      _pendingRefresh = true;
      return;
    }
    _pendingRefresh = false;
    pagingController.refresh();
    pagingController.fetchNextPage();
  }

  Future<void> _syncCourses() async {
    if (isUpdating) {
      extraCheck = true;
      return;
    }

    isUpdating = true;

    try {
      await _runComparison();

      if (extraCheck) {
        extraCheck = false;
        await _runComparison();
      }
    } finally {
      isUpdating = false;
      extraCheck = false;
    }
  }

  Future<void> _runComparison() async {
    final List<List<Course>>? pages = pagingController.value.pages;
    if (pages == null || pages.isEmpty) return;

    final isar = CourseRepo.isar;
    final presentCount = await isar.courses.count();
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);

    log("DB: $presentCount  Displayed: $displayedCount");

    if (presentCount == displayedCount) {
      await _handleModifications(pages);
    } else {
      await _handleCountChange(pages, presentCount);
    }
  }

  Future<void> _handleModifications(List<List<Course>> pages) async {
    final displayedCourses = pages.expand((p) => p).toList();
    final displayedMap = {for (final c in displayedCourses) c.id: c};

    final freshCourses = await CourseRepo.filter.anyOf(displayedCourses, (q, c) => q.idEqualTo(c.id)).findAll();

    final modifiedMap = <int, Course>{};
    for (final fresh in freshCourses) {
      final displayed = displayedMap[fresh.id];
      if (displayed != null && fresh.lastModified.compareTo(displayed.lastModified) != 0) {
        modifiedMap[fresh.id] = fresh;
      }
    }

    if (modifiedMap.isEmpty) return;

    log("Updating ${modifiedMap.length} modified courses");

    pagingController.value = pagingController.value.copyWith(
      pages: pages.map((page) {
        return page.map((c) => modifiedMap[c.id] ?? c).toList();
      }).toList(),
    );
  }

  Future<void> _handleCountChange(List<List<Course>> pages, int presentCount) async {
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);
    final difference = presentCount - displayedCount;

    if (difference < 0) {
      pagingController.refresh();
      return;
    }

    final additionalPages = (difference / limit).ceil();
    final pagesToFetch = pages.length + math.min(additionalPages, 1);

    final newPages = <List<Course>>[];
    final newKeys = <int>[];

    for (int i = 0; i < pagesToFetch; i++) {
      final pageKey = i + 1;
      final fetched = await _doFetch(pageKey, limit, state.coursesOrdering);
      if (fetched.isEmpty) break;
      newPages.add(fetched);
      newKeys.add(pageKey);
    }

    if (newPages.isNotEmpty) {
      pagingController.value = pagingController.value.copyWith(pages: newPages, keys: newKeys);
    }
  }

  Future<List<Course>> _doFetch(int pageKey, int limit, EntityOrdering sortOption) async {
    final offset = (pageKey - 1) * limit;
    final query = CourseRepo.isar.courses.where();

    return switch (sortOption) {
      EntityOrdering.nameAsc => query.sortByTitle().offset(offset).limit(limit).findAll(),
      EntityOrdering.nameDesc => query.sortByTitleDesc().offset(offset).limit(limit).findAll(),
      EntityOrdering.dateCreatedAsc => query.sortByCreatedAt().offset(offset).limit(limit).findAll(),
      EntityOrdering.dateCreatedDesc => query.sortByCreatedAtDesc().offset(offset).limit(limit).findAll(),
      EntityOrdering.dateModifiedAsc => query.sortByLastModified().offset(offset).limit(limit).findAll(),
      EntityOrdering.dateModifiedDesc => query.sortByLastModifiedDesc().offset(offset).limit(limit).findAll(),
    };
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
  () => HiveAsyncImpliedNotifier<String, EntityOrdering>(
    HiveDataPathKey.libraryCourseOrdering.name,
    EntityOrdering.dateModifiedDesc,
    transformer: (raw) => raw.name,
    builder: (data) async =>
        EntityOrdering.values.firstWhere((e) => e.name == data, orElse: () => EntityOrdering.dateModifiedDesc),
  ),
);

final _coursesUpdateStream = StreamNotifierProvider(
  () => StreamedNotifier(() async* {
    yield* (await CourseRepo.isarData.watchForChanges(
      fireImmediately: false,
    )).map((c) => DateTime.now().millisecondsSinceEpoch);
  }),
);
