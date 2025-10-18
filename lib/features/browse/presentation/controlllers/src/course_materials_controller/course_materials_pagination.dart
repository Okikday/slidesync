import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:math' as math;

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

  /// For stream cases, to keep track of what's going on
  int count = -1;
  bool isUpdating = false;

  final Queue<Completer<List<CourseContent>>> _waitingQueue = Queue();
  SmartIsolateContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>? _isolate;
  Completer<SmartIsolateContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>>? _initCompleter;
  bool _disposed = false;
  bool _isStopping = false;

  CourseMaterialsPagination._(this.parentId, {required this.sortOption}) {
    pagingController = PagingController(
      getNextPageKey: getNextPageKey,
      fetchPage: (pageKey) => fetchPage(pageKey, limit),
    );
  }

  static CourseMaterialsPagination of(String parentId, {CourseSortOption? sortOption}) =>
      CourseMaterialsPagination._(parentId, sortOption: sortOption ?? CourseSortOption.dateModifiedDesc);

  Future<void> init() async {
    if (_disposed || _isStopping) return;
    if (_initCompleter != null) return _initCompleter!.future.then((_) {});

    _initCompleter = Completer();
    log("init completer");

    try {
      final token = RootIsolateToken.instance!;
      log("init completer 2");

      final newIsolate = await SmartIsolate.runContinuous<Map<String, dynamic>, List<Map<String, dynamic>>>((
        registerHandler,
      ) async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(token);
        await IsarData.initialize(collectionSchemas: isarSchemas, inspector: false);
        registerHandler((arg, respond) {
          doFetchInIsolate(arg)
              .then((result) {
                respond(result);
              })
              .catchError((error) {
                log("Error while fetching materials from second isolate");
              });
        });
        log("Initialized second isolate");
        return;
      });

      if (_disposed || _isStopping) {
        newIsolate.dispose();
        _initCompleter!.completeError(StateError('Stopped during initialization'));
        return;
      }

      _isolate = newIsolate;

      _initCompleter!.complete(newIsolate);
    } catch (e) {
      _initCompleter!.completeError(e);
      log("$e");
    }
  }

  Future<List<CourseContent>> fetchPage(int pageKey, int limit) async {
    if (_isStopping) return [];
    if (count <= 0) count = await (await CourseContentRepo.filter).parentIdEqualTo(parentId).count();
    if (isFirstTime || _isolate == null) await init();
    if (_isStopping || _isolate == null) return [];
    log(("isIsolate value : $_isolate"));
    if (isFirstTime && pageKey == 0) {
      await Future.delayed(Durations.extralong1);
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

  Future<void> stopIsolate() async {
    // Make it async
    _isStopping = true;

    // Wait for any pending init to complete
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      try {
        await _initCompleter!.future.timeout(Duration(seconds: 2));
      } catch (_) {}
    }

    _isolate?.kill();
    _isolate = null;
    _initCompleter = null;

    log("Stopped isolate");
  }

  void restartIsolate() {
    _isStopping = false; // Allow init again
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

Future<void> compareContentAndUpdate(CourseMaterialsPagination cmp) async {
  final presentCount = await (await CourseContentRepo.isar).courseContents
      .filter()
      .parentIdEqualTo(cmp.parentId)
      .count();

  if (cmp.isUpdating) {
    log("Course Materials Pagination is updating!");
    return;
  }

  cmp.isUpdating = true;

  if (cmp.count < 0) {
    cmp.count = presentCount;
    cmp.isUpdating = false;
    return;
  }

  int contentOnPagesCount = 0;
  final List<List<CourseContent>>? contentOnPagesList = cmp.pagingController.value.pages;

  if (contentOnPagesList == null) {
    cmp.isUpdating = false;
    return;
  }

  for (final page in contentOnPagesList) {
    contentOnPagesCount += page.length;
  }

  log("Counted the content displaying: $contentOnPagesCount");

  if (presentCount == contentOnPagesCount) {
    // Same count - check for modifications
    final List<CourseContent> contentLoadedOnPages = contentOnPagesList.reduce((value, element) {
      return value + element;
    });

    final Map<String, CourseContent> contentOnPagesMap = {
      for (final content in contentLoadedOnPages) content.contentId: content,
    };

    log("currentlyLoadedContentPages: $contentLoadedOnPages");

    final List<CourseContent> contentLoadedOnPagesFromIsar = await (await CourseContentRepo.filter)
        .parentIdEqualTo(cmp.parentId)
        .anyOf(contentLoadedOnPages, (query, content) => query.contentIdEqualTo(content.contentId))
        .findAll();

    final Map<String, CourseContent> modifiedContentMap = {};

    for (final isarContent in contentLoadedOnPagesFromIsar) {
      final pageContent = contentOnPagesMap[isarContent.contentId];
      if (pageContent != null && isarContent != pageContent) {
        modifiedContentMap[isarContent.contentId] = isarContent;
      }
    }

    if (modifiedContentMap.isNotEmpty) {
      log("Found ${modifiedContentMap.length} modified content items");

      final List<List<CourseContent>> updatedPagesList = contentOnPagesList.map((page) {
        return page.map((content) {
          return modifiedContentMap[content.contentId] ?? content;
        }).toList();
      }).toList();

      cmp.pagingController.value = cmp.pagingController.value.copyWith(pages: updatedPagesList);

      log("Updated ${modifiedContentMap.length} content items in pages");
    }
  } else {
    // Different count - refetch pages
    final numberOfCurrentPages = contentOnPagesList.length;
    final difference = presentCount - contentOnPagesCount;

    if (difference <= 0) {
      cmp.pagingController.refresh();
      cmp.isUpdating = false;
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

    final List<List<CourseContent>> newPagesList = [];
    final List<int> newKeysList = [];

    // Fetch pages based on current sort option
    for (int i = 0; i < pagesToFetch; i++) {
      final pageKey = i + 1;

      final resultFromIsolate = await cmp._isolate?.execute(
        DoFetchInIsolateArgs(cmp.parentId, pageKey, limit, cmp.sortOption, RootIsolateToken.instance!).toMap(),
      );

      final fetchedPage = resultFromIsolate?.map((e) => CourseContent.fromMap(e)).toList() ?? [];

      if (fetchedPage.isEmpty) {
        break;
      }

      newPagesList.add(fetchedPage);
      newKeysList.add(pageKey);
    }

    // Update count
    cmp.count = presentCount;

    // Update the paging controller
    if (newPagesList.isNotEmpty) {
      cmp.pagingController.value = cmp.pagingController.value.copyWith(pages: newPagesList, keys: newKeysList);
    }
  }

  cmp.isUpdating = false;
}
