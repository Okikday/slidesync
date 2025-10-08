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
import 'package:slidesync/core/utils/smart_isolate.dart';
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
  SmartIsolateContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>? _isolate;
  Completer<SmartIsolateContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>>? _initCompleter;
  bool _disposed = false;

  CourseMaterialsPagination._(this.parentId, {required this.sortOption}) {
    pagingController = PagingController(
      getNextPageKey: getNextPageKey,
      fetchPage: (pageKey) => fetchPage(pageKey, limit),
    );
  }

  static CourseMaterialsPagination of(String parentId, {CourseSortOption? sortOption}) =>
      CourseMaterialsPagination._(parentId, sortOption: sortOption ?? CourseSortOption.dateModifiedDesc);

  Future<void> init() async {
    if (_disposed) return;
    if (_initCompleter != null) return _initCompleter!.future.then((_) {}); // Already initializing

    _initCompleter = Completer();

    try {
      final token = RootIsolateToken.instance!;
      final newIsolate = await SmartIsolate.runContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>((
        registerHandler,
      ) async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(token);
        await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);
        registerHandler((arg, respond) async {
          final result = await doFetchInIsolate(arg);
          respond(result);
        });
        log("Initialized second isolate");
        return;
      });

      // Check if disposed during initialization
      if (_disposed) {
        newIsolate.dispose();
        _initCompleter!.completeError(StateError('Disposed during initialization'));
        return;
      }

      _isolate = newIsolate;
      _initCompleter!.complete(newIsolate);
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  // Future<void> init() async {
  //   log("Initializing...");
  //   final token = RootIsolateToken.instance!;
  //   isolate = await SmartIsolate.runContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>((
  //     registerHandler,
  //   ) async {
  //     BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  //     await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);
  //     registerHandler((arg, respond) async {
  //       final result = await doFetchInIsolate(arg);
  //       respond(result);
  //     });
  //     log("Initialized second isolate");
  //     return;
  //   });
  // }

  Future<List<CourseContent>> fetchPage(int pageKey, int limit) async {
    if (isFirstTime) await init();
    if (isFirstTime && pageKey == 0) {
      await Future.delayed(Durations.short4); // Wait for the page to finish animating - approx...
      isFirstTime = false;
    }
    if (isFirstTime) isFirstTime = false;
    if (_fetching) {
      final completer = Completer<List<CourseContent>>();
      _waitingQueue.add(completer);
      return completer.future;
    }

    _fetching = true;
    try {
      final resultFromIsolate = await _isolate?.execute(
        DoFetchInIsolateArgs(parentId, pageKey, limit, sortOption, RootIsolateToken.instance!).toMap(),
      );
      final result = resultFromIsolate?.map((e) => CourseContent.fromMap(e)).toList();

      while (_waitingQueue.isNotEmpty) {
        _waitingQueue.removeFirst().complete(result);
      }

      return result ?? [];
    } catch (error) {
      while (_waitingQueue.isNotEmpty) {
        _waitingQueue.removeFirst().completeError(error);
      }
      rethrow;
    } finally {
      _fetching = false;
    }
  }

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
  void onDispose() async {
    _disposed = true;
    clearQueue();

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      try {
        await _initCompleter!.future.timeout(Duration(seconds: 2));
      } catch (_) {
        log("Error disposing smartIsolate");
      }
    }

    _isolate?.dispose();
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

  Map<String, dynamic> toMap() {
    return {'parentId': parentId, 'pageKey': pageKey, 'limit': limit, 'sortOption': sortOption.index, 'token': token};
  }

  factory DoFetchInIsolateArgs.fromMap(Map<String, dynamic> map) {
    final sortRaw = map['sortOption'];
    final CourseSortOption sort = (sortRaw is int)
        ? CourseSortOption.values[sortRaw]
        : (sortRaw is String
              ? CourseSortOption.values.firstWhere(
                  (e) => e.name == sortRaw || e.toString() == sortRaw,
                  orElse: () => CourseSortOption.dateModifiedDesc,
                )
              : CourseSortOption.dateModifiedDesc);

    return DoFetchInIsolateArgs(
      map['parentId'] as String,
      map['pageKey'] as int,
      map['limit'] as int,
      sort,
      map['token'] as RootIsolateToken,
    );
  }
}

Future<List<Map<String, dynamic>>> doFetchInIsolate(Map<String, dynamic> arg) async {
  final args = DoFetchInIsolateArgs.fromMap(arg);
  final result = await _doFetch(args.parentId, args.pageKey, args.limit, args.sortOption);

  final jsonList = result.map((e) => e.toMap()).toList();
  return jsonList;
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
