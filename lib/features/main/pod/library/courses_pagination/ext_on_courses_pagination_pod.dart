// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of 'courses_pagination_pod.dart';

extension MixinOnCoursesPaginationPod on CoursesPaginationPod {
  Future<void> _refreshAndFetchFirstPage() async {
    if (pagingController.value.isLoading) {
      _state = _state.copyWith(pendingRefresh: true);
      return;
    }
    _state = _state.copyWith(pendingRefresh: false);
    pagingController.refresh();
    pagingController.fetchNextPage();
  }

  Future<void> _syncCourses() async {
    if (_state.isUpdating) {
      _state = _state.copyWith(extraCheck: true);
      return;
    }

    _state = _state.copyWith(isUpdating: true);

    try {
      await _runComparison();

      if (_state.extraCheck) {
        _state = _state.copyWith(extraCheck: false);
        await _runComparison();
      }
    } finally {
      _state = _state.copyWith(extraCheck: false, isUpdating: false);
    }
  }

  Future<void> _runComparison() async {
    final List<List<Course>>? pages = pagingController.value.pages;
    if (pages == null || pages.isEmpty) return;

    final presentCount = await CourseRepo.isar.courses.count();
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

    final freshCourses = await CourseRepo.filter
        .anyOf(displayedCourses, (q, c) => q.idEqualTo(c.id))
        .findAll();

    final modifiedMap = <int, Course>{};
    for (final fresh in freshCourses) {
      final displayed = displayedMap[fresh.id];
      if (displayed != null &&
          fresh.lastModified.compareTo(displayed.lastModified) != 0) {
        modifiedMap[fresh.id] = fresh;
      }
    }

    if (modifiedMap.isEmpty) return;

    log("Updating ${modifiedMap.length} modified courses");

    pagingController.value = pagingController.value.copyWith(
      pages: pages
          .map((page) => page.map((c) => modifiedMap[c.id] ?? c).toList())
          .toList(),
    );
  }

  Future<void> _handleCountChange(
    List<List<Course>> pages,
    int presentCount,
  ) async {
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);
    final difference = presentCount - displayedCount;

    if (difference < 0) {
      pagingController.refresh();
      return;
    }

    final additionalPages = (difference / _limit).ceil();
    final pagesToFetch = pages.length + math.min(additionalPages, 1);

    final newPages = <List<Course>>[];
    final newKeys = <int>[];

    for (int i = 0; i < pagesToFetch; i++) {
      final pageKey = i + 1;
      final fetched = await _doFetch(pageKey, _limit, state.coursesOrdering);
      if (fetched.isEmpty) break;
      newPages.add(fetched);
      newKeys.add(pageKey);
    }

    if (newPages.isNotEmpty) {
      pagingController.value = pagingController.value.copyWith(
        pages: newPages,
        keys: newKeys,
      );
    }
  }

  Future<List<Course>> _doFetch(
    int pageKey,
    int limit,
    CoursesOrdering sortOption,
  ) async {
    final offset = (pageKey - 1) * limit;
    final query = CourseRepo.isar.courses.where();

    final what = switch (sortOption) {
      .nameAsc => query.sortByTitle(),
      .nameDesc => query.sortByTitleDesc(),
      .dateCreatedAsc => query.sortByCreatedAt(),
      .dateCreatedDesc => query.sortByCreatedAtDesc(),
      .dateModifiedAsc => query.sortByLastModified(),
      .dateModifiedDesc => query.sortByLastModifiedDesc(),
      .courseCodeAsc => null,
      .courseCodeDesc => null,
      // refer next comment
    };
    // Remember to change if another condition applies in the switch case above
    if (what == null) {
      return _fetchByCourseCode(
        query,
        offset,
        limit,
        ascending: sortOption == .courseCodeAsc,
      );
    } else {
      return what.offset(offset).limit(limit).findAll();
    }
  }

  Future<List<Course>> _fetchByCourseCode(
    QueryBuilder<Course, Course, QWhere> query,
    int offset,
    int limit, {
    required bool ascending,
  }) async {
    final courses = await query.findAll();

    courses.sort((left, right) {
      final leftCode = left.metadata.courseCode?.trim();
      final rightCode = right.metadata.courseCode?.trim();
      final leftMissing = leftCode == null || leftCode.isEmpty;
      final rightMissing = rightCode == null || rightCode.isEmpty;

      if (leftMissing && rightMissing) return 0;
      if (leftMissing) return 1;
      if (rightMissing) return -1;

      final comparison = leftCode.toLowerCase().compareTo(
        rightCode.toLowerCase(),
      );
      if (comparison != 0) {
        return ascending ? comparison : -comparison;
      }

      final titleComparison = left.title.toLowerCase().compareTo(
        right.title.toLowerCase(),
      );
      return ascending ? titleComparison : -titleComparison;
    });

    return courses.skip(offset).take(limit).toList();
  }
}

/// For handling the state of pagination internally
class _PaginationState {
  final bool isUpdating;
  final bool extraCheck;
  final bool pendingRefresh;

  const _PaginationState({
    this.isUpdating = false,
    this.extraCheck = false,
    this.pendingRefresh = false,
  });

  _PaginationState copyWith({
    bool? isUpdating,
    bool? extraCheck,
    bool? pendingRefresh,
  }) {
    return _PaginationState(
      isUpdating: isUpdating ?? this.isUpdating,
      extraCheck: extraCheck ?? this.extraCheck,
      pendingRefresh: pendingRefresh ?? this.pendingRefresh,
    );
  }
}
