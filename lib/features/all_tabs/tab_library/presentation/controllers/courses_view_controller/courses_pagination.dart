import 'dart:developer';
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/utils/leak_prevention.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';

enum CourseSortOption { nameAsc, nameDesc, dateCreatedAsc, dateCreatedDesc, dateModifiedAsc, dateModifiedDesc }

enum PlainCourseSortOption { name, dateCreated, dateModified }

// class DoFetchInIsolateArgs {
//   final int pageKey;
//   final int limit;
//   final CourseSortOption sortOption;
//   final RootIsolateToken token;

//   DoFetchInIsolateArgs(this.pageKey, this.limit, this.sortOption, this.token);
// }

const int limit = 20;

class CoursesPagination extends LeakPrevention {
  late final PagingController<int, Course> pagingController;
  CourseSortOption sortOption;

  bool _fetching = false;
  final Queue<Completer<List<Course>>> _waitingQueue = Queue();

  /// For stream cases, to keep track of what's going on
  int count = -1;
  bool isUpdating = false;

  CoursesPagination._({this.sortOption = CourseSortOption.dateModifiedDesc}) {
    pagingController = PagingController(
      getNextPageKey: getNextPageKey,
      fetchPage: (pageKey) => fetchPage(pageKey, limit),
    );
  }

  static CoursesPagination of({CourseSortOption? sortOption}) =>
      CoursesPagination._(sortOption: sortOption ?? CourseSortOption.dateModifiedDesc);

  Future<List<Course>> fetchPage(int pageKey, int limit) async {
    if (count <= 0) count = await (await CourseRepo.isar).courses.count();
    if (_fetching) {
      final completer = Completer<List<Course>>();
      _waitingQueue.add(completer);
      return completer.future;
    }

    _fetching = true;
    try {
      final token = RootIsolateToken.instance;
      if (token == null) return const [];
      final result = _doFetch(pageKey, limit, sortOption);

      while (_waitingQueue.isNotEmpty) {
        _waitingQueue.removeFirst().complete(result);
      }

      return result;
    } catch (error) {
      while (_waitingQueue.isNotEmpty) {
        _waitingQueue.removeFirst().completeError(error);
      }
      rethrow;
    } finally {
      _fetching = false;
    }
  }

  Future<List<Course>> _doFetch(int pageKey, int limit, CourseSortOption sortOption) async {
    final List<Course> result;

    switch (sortOption) {
      case CourseSortOption.nameAsc:
        result = await _fetchByTitle(pageKey, limit);
        break;
      case CourseSortOption.nameDesc:
        result = await _fetchByTitle(pageKey, limit, false);
        break;
      case CourseSortOption.dateCreatedAsc:
        result = await _fetchByDateCreated(pageKey, limit);
        break;
      case CourseSortOption.dateCreatedDesc:
        result = await _fetchByDateCreated(pageKey, limit, false);
        break;
      case CourseSortOption.dateModifiedAsc:
        result = await _fetchByDateModified(pageKey, limit);
        break;
      case CourseSortOption.dateModifiedDesc:
        result = await _fetchByDateModified(pageKey, limit, false);
        break;
    }

    return result;
  }

  Future<List<Course>> _fetchByTitle(int pageKey, int limit, [bool ascending = true]) async {
    final offset = (pageKey - 1) * limit;
    final filter = (await CourseRepo.filter);
    return await (ascending
        ? filter.idGreaterThan(0).sortByCourseTitle().offset(offset).limit(limit).findAll()
        : filter.idGreaterThan(0).sortByCourseTitleDesc().offset(offset).limit(limit).findAll());
  }

  Future<List<Course>> _fetchByDateCreated(int pageKey, int limit, [bool ascending = true]) async {
    final offset = (pageKey - 1) * limit;
    final filter = (await CourseRepo.filter);
    return await (ascending
        ? filter.idGreaterThan(0).sortByCreatedAt().offset(offset).limit(limit).findAll()
        : filter.idGreaterThan(0).sortByCreatedAtDesc().offset(offset).limit(limit).findAll());
  }

  Future<List<Course>> _fetchByDateModified(int pageKey, int limit, [bool ascending = true]) async {
    final offset = (pageKey - 1) * limit;
    final filter = (await CourseRepo.filter);
    return await (ascending
        ? filter.idGreaterThan(0).sortByLastUpdated().offset(offset).limit(limit).findAll()
        : filter.idGreaterThan(0).sortByLastUpdatedDesc().offset(offset).limit(limit).findAll());
  }

  static int? getNextPageKey(PagingState<int, Course> state) {
    return state.lastPageIsEmpty ? null : state.nextIntPageKey;
  }

  void clearQueue() {
    while (_waitingQueue.isNotEmpty) {
      _waitingQueue.removeFirst().completeError(StateError('Queue cleared'));
    }
  }

  void updateSortOption(CourseSortOption newSortOption, [bool refresh = false]) {
    sortOption = newSortOption;
    if (refresh) pagingController.refresh();
  }

  int get queueLength => _waitingQueue.length;
  bool get isBusy => _fetching;

  @override
  void onDispose() {
    clearQueue();
    pagingController.dispose();
    log("Disposed Courses Pagination");
  }
}

Future<void> compareCoursesAndUpdate(CoursesPagination cp) async {
  final presentCount = await (await CourseRepo.isar).courses.count();
  if (cp.isUpdating) {
    log("Courses Pagination is updating!");
    return;
  }
  cp.isUpdating = true;
  if (cp.count < 0) {
    cp.count = presentCount;
    cp.isUpdating = false;
    return;
  }

  int coursesOnPagesCount = 0;
  final List<List<Course>>? coursesOnPagesList = cp.pagingController.value.pages;
  if (coursesOnPagesList == null) {
    cp.isUpdating = false;
    return;
  }

  for (final i in coursesOnPagesList) {
    coursesOnPagesCount += i.length;
  }
  log("Counted the courses displaying: $coursesOnPagesCount");
  if (presentCount == coursesOnPagesCount) {
    final List<Course> coursesLoadedOnPages = coursesOnPagesList.reduce((value, element) {
      return value + element;
    });

    final Map<int, Course> coursesOnPagesMap = {for (final course in coursesLoadedOnPages) course.id: course};

    log("currentlyLoadedCoursesPages: $coursesLoadedOnPages");

    final List<Course> coursesLoadedOnPagesFromIsar = await (await CourseRepo.filter)
        .anyOf(coursesLoadedOnPages, (a, b) => a.idEqualTo(b.id))
        .findAll();

    final Map<int, Course> modifiedCoursesMap = {};

    for (final isarCourse in coursesLoadedOnPagesFromIsar) {
      final pageCourse = coursesOnPagesMap[isarCourse.id];
      if (pageCourse != null && !_areCoursesEqual(isarCourse, pageCourse)) {
        modifiedCoursesMap[isarCourse.id] = isarCourse;
      }
    }

    if (modifiedCoursesMap.isNotEmpty) {
      log("Found ${modifiedCoursesMap.length} modified courses");

      final List<List<Course>> updatedPagesList = coursesOnPagesList.map((page) {
        return page.map((course) {
          return modifiedCoursesMap[course.id] ?? course;
        }).toList();
      }).toList();

      cp.pagingController.value = cp.pagingController.value.copyWith(pages: updatedPagesList);

      log("Updated ${modifiedCoursesMap.length} courses in pages");
    }
  } else {
    final numberOfCurrentPages = coursesOnPagesList.length;

    final difference = presentCount - coursesOnPagesCount;
    if (difference <= 0) {
      cp.pagingController.refresh();
      cp.isUpdating = false;
      return;
    }

    int pagesToFetch;

    if (difference > 0) {
      // Items added - fetch current pages + max 1 additional page if needed
      final additionalItemsPages = (difference / limit).ceil();
      pagesToFetch = numberOfCurrentPages + math.min(additionalItemsPages, 1);
    } else {
      // Items removed - calculate how many pages we actually need now
      pagesToFetch = math.max((presentCount / limit).ceil(), 1);
    }

    final List<List<Course>> newPagesList = [];
    final List<int> newKeysList = [];

    // Fetch pages based on current sort option
    for (int i = 0; i < pagesToFetch; i++) {
      final pageKey = i + 1;

      final fetchedPage = await cp._doFetch(pageKey, limit, cp.sortOption);

      if (fetchedPage.isEmpty) {
        break;
      }

      newPagesList.add(fetchedPage);
      newKeysList.add(pageKey);
    }

    // Update count
    cp.count = presentCount;

    // Update the paging controller
    if (newPagesList.isNotEmpty) {
      cp.pagingController.value = cp.pagingController.value.copyWith(pages: newPagesList, keys: newKeysList);
    }
  }
  cp.isUpdating = false;
}

bool _areCoursesEqual(Course a, Course b) {
  return a == b;
}
