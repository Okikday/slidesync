import 'dart:developer';
import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/utils/leak_prevention.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';

enum CourseSortOption { nameAsc, nameDesc, dateCreatedAsc, dateCreatedDesc, dateModifiedAsc, dateModifiedDesc }

enum PlainCourseSortOption { name, dateCreated, dateModified }

class DoFetchInIsolateArgs {
  final int pageKey;
  final int limit;
  final CourseSortOption sortOption;
  final RootIsolateToken token;

  DoFetchInIsolateArgs(this.pageKey, this.limit, this.sortOption, this.token);
}

const int limit = 20;

class CoursesPagination extends LeakPrevention {
  late final PagingController<int, Course> pagingController;
  CourseSortOption sortOption;

  bool _fetching = false;
  final Queue<Completer<List<Course>>> _waitingQueue = Queue();

  CoursesPagination._({this.sortOption = CourseSortOption.dateModifiedDesc}) {
    pagingController = PagingController(
      getNextPageKey: getNextPageKey,
      fetchPage: (pageKey) => fetchPage(pageKey, limit),
    );
  }

  static CoursesPagination of({CourseSortOption? sortOption}) =>
      CoursesPagination._(sortOption: sortOption ?? CourseSortOption.dateModifiedDesc);

  Future<List<Course>> fetchPage(int pageKey, int limit) async {
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

extension CourseSortX on CourseSortOption {
  PlainCourseSortOption toPlain() {
    final n = name;
    final core = n.endsWith('Asc')
        ? n.substring(0, n.length - 3)
        : n.endsWith('Desc')
        ? n.substring(0, n.length - 4)
        : n;
    switch (core) {
      case 'name':
        return PlainCourseSortOption.name;
      case 'dateCreated':
        return PlainCourseSortOption.dateCreated;
      case 'dateModified':
        return PlainCourseSortOption.dateModified;
      default:
        return PlainCourseSortOption.dateModified;
    }
  }

  String get label {
    switch (this) {
      case CourseSortOption.nameAsc:
        return 'Name (Ascending)';
      case CourseSortOption.nameDesc:
        return 'Name (Descending)';
      case CourseSortOption.dateCreatedAsc:
        return 'Date Created (Ascending)';
      case CourseSortOption.dateCreatedDesc:
        return 'Date Created (Descending)';
      case CourseSortOption.dateModifiedAsc:
        return 'Date Modified (Ascending)';
      case CourseSortOption.dateModifiedDesc:
        return 'Date Modified (Descending)';
    }
  }
}
