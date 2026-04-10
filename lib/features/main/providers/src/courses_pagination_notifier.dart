import 'dart:developer';
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/main/providers/entities/course_pagination_state.dart';
import 'package:slidesync/shared/global/notifiers/common/course_sort_notifier.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CoursesPaginationNotifier extends Notifier<CoursePaginationState> {
  /// ===================================================================================================
  /// MUTABLE VARIABLES (Internal Manager State)
  /// ===================================================================================================
  late final PagingController<int, Course> pagingController = PagingController(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => fetchPage(pageKey, limit),
  );
  final Queue<Completer<List<Course>>> _waitingQueue = Queue();
  final coursesFilter = _coursesFilterProvider;

  bool _fetching = false;
  bool isUpdating = false;
  int count = -1;
  final int limit = 20;

  /// ===================================================================================================
  /// LIFECYCLE (Build & Dispose)
  /// ===================================================================================================

  @override
  CoursePaginationState build() {
    log("Rebuild $runtimeType");
    final filterPro = _coursesFilterProvider.readX(ref);
    final initialSort = filterPro.value ?? CourseSortOption.dateModifiedDesc;

    ref.listen(
      _coursesFilterProvider,
      (prev, next) => next.whenData((newSort) => updateSortOption(newSort, refresh: true)),
      fireImmediately: true,
    );

    ref.onDispose(() {
      _clearQueue();
      pagingController.dispose();
    });

    ref.listen(_coursesUpdateStream, (prev, next) async => await compareCoursesAndUpdate());

    return CoursePaginationState(sortOption: initialSort);
  }

  /// ===================================================================================================
  /// PUBLIC METHODS
  /// ===================================================================================================

  void updateSortOption(CourseSortOption newSortOption, {bool refresh = true}) {
    if (state.sortOption == newSortOption) return;

    ref.read(_coursesFilterProvider.notifier).set(newSortOption);
    state = state.copyWith(sortOption: newSortOption);

    if (refresh) pagingController.refresh();
  }

  /// The main fetch gateway with concurrency handling
  Future<List<Course>> fetchPage(int pageKey, int limit) async {
    // Initialize count if first run
    if (count <= 0) {
      final isar = await CourseRepo.isar;
      Future.microtask(() async => count = await isar.courses.count());
    }

    if (_fetching) {
      final completer = Completer<List<Course>>();
      _waitingQueue.add(completer);
      return completer.future;
    }

    _fetching = true;
    try {
      final token = RootIsolateToken.instance;
      if (token == null) return const [];

      // Perform the actual Isar fetch
      final result = await _doFetch(pageKey, limit, state.sortOption);

      // Resolve any callers waiting in the queue
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

  /// Advanced diffing: compares UI pages with DB and updates in-place
  Future<void> compareCoursesAndUpdate() async {
    if (isUpdating) {
      log("Courses Pagination is already updating!");
      return;
    }

    final isar = await CourseRepo.isar;
    final presentCount = await isar.courses.count();

    isUpdating = true;

    try {
      if (count < 0) {
        count = presentCount;
        return;
      }

      final List<List<Course>>? coursesOnPagesList = pagingController.value.pages;
      if (coursesOnPagesList == null) return;

      int coursesOnPagesCount = coursesOnPagesList.fold(0, (sum, page) => sum + page.length);
      log("Counted the courses displaying: $coursesOnPagesCount");

      if (presentCount == coursesOnPagesCount) {
        // SCENARIO 1: Count is the same, check for modified content
        final coursesLoadedOnPages = coursesOnPagesList.expand((i) => i).toList();
        final coursesOnPagesMap = {for (final course in coursesLoadedOnPages) course.id: course};

        final filterRepo = await CourseRepo.filter;
        final coursesFromIsar = await filterRepo.anyOf(coursesLoadedOnPages, (a, b) => a.idEqualTo(b.id)).findAll();

        final Map<int, Course> modifiedCoursesMap = {};
        for (final isarCourse in coursesFromIsar) {
          final pageCourse = coursesOnPagesMap[isarCourse.id];
          if (pageCourse != null && isarCourse != pageCourse) {
            modifiedCoursesMap[isarCourse.id] = isarCourse;
          }
        }

        if (modifiedCoursesMap.isNotEmpty) {
          log("Found ${modifiedCoursesMap.length} modified courses");
          final updatedPagesList = coursesOnPagesList.map((page) {
            return page.map((c) => modifiedCoursesMap[c.id] ?? c).toList();
          }).toList();

          pagingController.value = pagingController.value.copyWith(pages: updatedPagesList);
        }
      } else {
        // SCENARIO 2: Count changed (Items added or removed)
        final numberOfCurrentPages = coursesOnPagesList.length;
        final difference = presentCount - coursesOnPagesCount;

        if (difference <= 0) {
          pagingController.refresh();
          return;
        }

        int pagesToFetch;
        if (difference > 0) {
          final additionalItemsPages = (difference / limit).ceil();
          pagesToFetch = numberOfCurrentPages + math.min(additionalItemsPages, 1);
        } else {
          pagesToFetch = math.max((presentCount / limit).ceil(), 1);
        }

        final List<List<Course>> newPagesList = [];
        final List<int> newKeysList = [];

        for (int i = 0; i < pagesToFetch; i++) {
          final pageKey = i + 1;
          final fetchedPage = await _doFetch(pageKey, limit, state.sortOption);

          if (fetchedPage.isEmpty) break;

          newPagesList.add(fetchedPage);
          newKeysList.add(pageKey);
        }

        count = presentCount;
        if (newPagesList.isNotEmpty) {
          pagingController.value = pagingController.value.copyWith(pages: newPagesList, keys: newKeysList);
        }
      }
    } catch (e) {
      log("Error during update: $e");
    } finally {
      isUpdating = false;
    }
  }

  /// ===================================================================================================
  /// PRIVATE FETCHERS (Internal logic)
  /// ===================================================================================================

  void _clearQueue() {
    while (_waitingQueue.isNotEmpty) {
      _waitingQueue.removeFirst().completeError(StateError('Queue cleared'));
    }
  }

  Future<List<Course>> _doFetch(int pageKey, int limit, CourseSortOption sortOption) async {
    final offset = (pageKey - 1) * limit;
    final isar = await CourseRepo.isar;
    final query = isar.courses.where();

    return switch (sortOption) {
      CourseSortOption.nameAsc => await query.sortByCourseTitle().offset(offset).limit(limit).findAll(),
      CourseSortOption.nameDesc => await query.sortByCourseTitleDesc().offset(offset).limit(limit).findAll(),
      CourseSortOption.dateCreatedAsc => await query.sortByCreatedAt().offset(offset).limit(limit).findAll(),
      CourseSortOption.dateCreatedDesc => await query.sortByCreatedAtDesc().offset(offset).limit(limit).findAll(),
      CourseSortOption.dateModifiedAsc => await query.sortByLastUpdated().offset(offset).limit(limit).findAll(),
      CourseSortOption.dateModifiedDesc => await query.sortByLastUpdatedDesc().offset(offset).limit(limit).findAll(),
    };
  }
}

///
/// ===================================================================================================
/// EXTRA PROVIDERS
/// ===================================================================================================
final _coursesFilterProvider = AsyncNotifierProvider.autoDispose<CourseSortNotifier, CourseSortOption>(
  () => CourseSortNotifier(HiveDataPathKey.libraryCourseSortOption.name),
);

final _coursesUpdateStream = StreamNotifierProvider(
  () => StreamedNotifier(() async* {
    yield* (await CourseRepo.isarData.watchForChanges(
      fireImmediately: false,
    )).map((c) => DateTime.now().millisecondsSinceEpoch);
  }),
);
