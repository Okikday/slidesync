import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_schemas.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';


const int limit = 20;

class CourseMaterialsPagination extends LeakPrevention {
  late final PagingController<int, CourseContent> pagingController;
  CourseSortOption sortOption;
  final String parentId;

  bool _fetching = false;
  bool isFirstTime = true;
  final Queue<Completer<List<CourseContent>>> _waitingQueue = Queue();

  CourseMaterialsPagination._(this.parentId, {required this.sortOption}) {
    pagingController = PagingController(
      getNextPageKey: getNextPageKey,
      fetchPage: (pageKey) => fetchPage(pageKey, limit),
    );
  }

  static CourseMaterialsPagination of(String parentId, {CourseSortOption? sortOption}) =>
      CourseMaterialsPagination._(parentId, sortOption: sortOption ?? CourseSortOption.dateModifiedDesc);

  Future<List<CourseContent>> fetchPage(int pageKey, int limit) async {
    if (isFirstTime && pageKey == 0) {
      await Future.delayed(Durations.extralong1); // Wait for the page to finish animating - approx...
      isFirstTime = false;
    }
    if (_fetching) {
      final completer = Completer<List<CourseContent>>();
      _waitingQueue.add(completer);
      return completer.future;
    }

    _fetching = true;
    try {
      final resultFromIsolate = await compute(
        doFetchInIsolate,
        DoFetchInIsolateArgs(parentId, pageKey, limit, sortOption, RootIsolateToken.instance!),
      );
      final result = resultFromIsolate.map((e) => CourseContent.fromJson(e)).toList();

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

  // Future<List<CourseContent>> _fetchDefault(int pageKey, int limit) async {
  //   _lastItemSortId ??= (pageKey - 1) * limit;

  //   final idGreaterThan = _lastItemSortId;
  //   log("Fetching content page $pageKey with ID > $idGreaterThan");
  //   final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  //   final result = await query.idGreaterThan(idGreaterThan).limit(limit).findAll();

  //   if (result.isNotEmpty) {
  //     _lastItemSortId = result.last.id;
  //   }

  //   return result;
  // }

  // Future<List<CourseContent>> _fetchByTitle(int pageKey, int limit, [bool ascending = true]) async {
  //   final offset = (pageKey - 1) * limit;
  //   final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  //   return await (ascending
  //       ? query.sortByTitle().offset(offset).limit(limit).findAll()
  //       : query.sortByTitleDesc().offset(offset).limit(limit).findAll());
  // }

  // Future<List<CourseContent>> _fetchByDateCreated(int pageKey, int limit, [bool ascending = true]) async {
  //   final offset = (pageKey - 1) * limit;
  //   final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  //   return await (ascending
  //       ? query.sortByCreatedAt().offset(offset).limit(limit).findAll()
  //       : query.sortByCreatedAtDesc().offset(offset).limit(limit).findAll());
  // }

  // Future<List<CourseContent>> _fetchByDateModified(int pageKey, int limit, [bool ascending = true]) async {
  //   final offset = (pageKey - 1) * limit;
  //   final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  //   return await (ascending
  //       ? query.sortByLastModified().offset(offset).limit(limit).findAll()
  //       : query.sortByLastModifiedDesc().offset(offset).limit(limit).findAll());
  // }

  static int? getNextPageKey(PagingState<int, CourseContent> state) {
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
    log("Disposed Course Materials Pagination");
  }
}

class DoFetchInIsolateArgs {
  final String parentId;
  final int pageKey;
  final int limit;
  final CourseSortOption sortOption;
  final RootIsolateToken token;

  DoFetchInIsolateArgs(this.parentId, this.pageKey, this.limit, this.sortOption, this.token);
}

Future<List<String>> doFetchInIsolate(DoFetchInIsolateArgs args) async {
  final RootIsolateToken rootIsolateToken = args.token;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);
  final result = await _doFetch(args.parentId, args.pageKey, args.limit, args.sortOption);
  await IsarData.close();
  final jsonList = result.map((e) => e.toJson()).toList();
  return jsonList;
  // log("Result: $result");
  // return result;
}

Future<List<CourseContent>> _doFetch(String parentId, int pageKey, int limit, CourseSortOption sortOption) async {
  final List<CourseContent> result;

  switch (sortOption) {
    case CourseSortOption.nameAsc:
      result = await _doFetchByTitle(parentId, pageKey, limit);
      break;
    case CourseSortOption.nameDesc:
      result = await _doFetchByTitle(parentId, pageKey, limit, false);
      break;
    case CourseSortOption.dateCreatedAsc:
      result = await _doFetchByDateCreated(parentId, pageKey, limit);
      break;
    case CourseSortOption.dateCreatedDesc:
      result = await _doFetchByDateCreated(parentId, pageKey, limit, false);
      break;
    case CourseSortOption.dateModifiedAsc:
      result = await _doFetchByDateModified(parentId, pageKey, limit);
      break;
    case CourseSortOption.dateModifiedDesc:
      result = await _doFetchByDateModified(parentId, pageKey, limit, false);
      break;
  }

  return result;
}

Future<List<CourseContent>> _doFetchByTitle(String parentId, int pageKey, int limit, [bool ascending = true]) async {
  final offset = (pageKey - 1) * limit;
  final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  return await (ascending
      ? query.sortByTitle().offset(offset).limit(limit).findAll()
      : query.sortByTitleDesc().offset(offset).limit(limit).findAll());
}

Future<List<CourseContent>> _doFetchByDateCreated(
  String parentId,
  int pageKey,
  int limit, [
  bool ascending = true,
]) async {
  final offset = (pageKey - 1) * limit;
  final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  return await (ascending
      ? query.sortByCreatedAt().offset(offset).limit(limit).findAll()
      : query.sortByCreatedAtDesc().offset(offset).limit(limit).findAll());
}

Future<List<CourseContent>> _doFetchByDateModified(
  String parentId,
  int pageKey,
  int limit, [
  bool ascending = true,
]) async {
  final offset = (pageKey - 1) * limit;
  final query = (await CourseContentRepo.filter).parentIdEqualTo(parentId);
  return await (ascending
      ? query.sortByLastModified().offset(offset).limit(limit).findAll()
      : query.sortByLastModifiedDesc().offset(offset).limit(limit).findAll());
}
