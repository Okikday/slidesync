import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar_community/isar.dart';

import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/grouped_module_content.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/module_contents_pagination_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

export 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/module_contents_pagination_state.dart';

part 'ext_module_contents_pagination_notifier.dart';

const int limit = 20;

class ModuleContentsPaginationNotifier extends Notifier<ModuleContentsPaginationState> {
  ModuleContentsPaginationNotifier(this.moduleId);

  ///
  ///
  /// ===================================================================================================
  /// DECLARATIONS
  /// ===================================================================================================

  Module? module;
  final int moduleId;

  /// Standard controller — used for [CardViewType.list] and [CardViewType.grid].
  late final PagingController<int, ModuleContent> pagingController = PagingController(
    getNextPageKey: _getNextPageKey,
    fetchPage: (pageKey) => fetchPage(pageKey, limit),
  );

  /// Organized controller — used for [CardViewType.organized].
  /// Items are [Object] so both [GroupedModuleContent] and solo [ModuleContent]
  /// can live in the same page list without unsafe casting downstream.
  late final PagingController<int, Object> organizedPagingController = PagingController(
    getNextPageKey: _getNextOrganizedPageKey,
    fetchPage: (pageKey) => _fetchOrganizedPage(pageKey, limit),
  );

  bool isUpdating = false;
  bool extraCheck = false;
  bool _pendingRefresh = false;

  ///
  ///
  /// ===================================================================================================
  /// LIFECYCLE
  /// ===================================================================================================

  @override
  ModuleContentsPaginationState build() {
    final contentsOrdering = ref.read(_moduleContentsOrderingProvider).value;

    ref.listen(
      _moduleContentsOrderingProvider,
      (prev, next) => next.whenData((newSort) => updateContentsOrdering(newSort, refresh: true)),
    );

    // Fire both sync paths on every DB change; each guards itself via
    // `pages == null || pages.isEmpty` so the idle controller is a no-op.
    ref.listen(_watchContentsChange(moduleId), (prev, next) async {
      await syncModuleContents();
      await syncOrganizedContents();
    });

    ref.onDispose(_dispose);

    return ModuleContentsPaginationState(
      isLoading: true,
      contentsOrdering: contentsOrdering ?? EntityOrdering.dateModifiedDesc,
    );
  }

  void _dispose() {
    pagingController.dispose();
    organizedPagingController.dispose();
    log('Disposed $runtimeType');
  }

  Future<void> _initModule() async {
    await Result.tryRunAsync(() async => module = await ModuleRepo.getByDbId(moduleId));
    log('Initialized module: ${module?.uid}');
  }

  ///
  ///
  /// ===================================================================================================
  /// PUBLIC API
  /// ===================================================================================================

  void updateContentsOrdering(EntityOrdering newSortOption, {bool refresh = true}) {
    if (state.contentsOrdering == newSortOption) return;

    ref.read(_moduleContentsOrderingProvider.notifier).set(newSortOption);
    state = state.copyWith(contentsOrdering: newSortOption, isLoading: false);

    if (refresh) _refreshBoth();
  }

  /// Called by [ModuleContentsNotifier] when [CardViewType] switches so the
  /// correct controller gets a fresh fetch.
  void refreshForViewType(CardViewType viewType) {
    switch (viewType) {
      case CardViewType.organized:
        _refreshController(organizedPagingController);
      case CardViewType.list || CardViewType.grid || CardViewType.other:
        _refreshController(pagingController);
    }
  }

  /// Public — the flat extension ([ext_module_contents_pagination_notifier])
  /// calls this directly in [_handleCountChange], matching the original contract.
  Future<List<ModuleContent>> fetchPage(int pageKey, int limit) async {
    await _ensureModule();
    state = state.copyWith(isLoading: false);

    if (_pendingRefresh && pageKey == 1) {
      _pendingRefresh = false;
      scheduleMicrotask(
        () => pagingController
          ..refresh()
          ..fetchNextPage(),
      );
      return [];
    }

    return _queryContents(pageKey: pageKey, limit: limit);
  }

  ///
  ///
  /// ===================================================================================================
  /// INTERNALS
  /// ===================================================================================================

  Future<List<Object>> _fetchOrganizedPage(int pageKey, int limit) async {
    await _ensureModule();

    if (_pendingRefresh && pageKey == 1) {
      _pendingRefresh = false;
      scheduleMicrotask(
        () => organizedPagingController
          ..refresh()
          ..fetchNextPage(),
      );
      return [];
    }

    final raw = await _queryContents(pageKey: pageKey, limit: limit);
    return groupModuleContents(raw);
  }

  Future<void> _ensureModule() async {
    if (module != null) return;
    await _initModule();
  }

  Future<List<ModuleContent>> _queryContents({required int pageKey, required int limit}) async {
    if (!ref.mounted) return [];

    final filter = module!.contents.filter();
    final offset = (pageKey - 1) * limit;
    final ordering = state.contentsOrdering;

    final query = switch (ordering) {
      EntityOrdering.nameAsc => filter.sortByTitle(),
      EntityOrdering.nameDesc => filter.sortByTitleDesc(),
      EntityOrdering.dateCreatedAsc => filter.sortByCreatedAt(),
      EntityOrdering.dateCreatedDesc => filter.sortByCreatedAtDesc(),
      EntityOrdering.dateModifiedAsc => filter.sortByLastModified(),
      EntityOrdering.dateModifiedDesc => filter.sortByLastModifiedDesc(),
    };

    return query.offset(offset).limit(limit).findAll();
  }

  void _refreshBoth() {
    _refreshController(pagingController);
    _refreshController(organizedPagingController);
  }

  void _refreshController<T>(PagingController<int, T> controller) {
    if (controller.value.isLoading) {
      _pendingRefresh = true;
      return;
    }
    _pendingRefresh = false;
    controller.refresh();
    controller.fetchNextPage();
  }

  int? _getNextPageKey(PagingState<int, ModuleContent> state) => state.lastPageIsEmpty ? null : state.nextIntPageKey;

  int? _getNextOrganizedPageKey(PagingState<int, Object> state) => state.lastPageIsEmpty ? null : state.nextIntPageKey;
}

///
///
/// ===================================================================================================
/// EXTRA PROVIDERS
/// ===================================================================================================

final _watchContentsChange = StreamNotifierProvider.autoDispose.family(
  (int arg) => StreamedNotifier<int>(() async* {
    final module = await ModuleRepo.getByDbId(arg);
    yield* module?.contents
            .filter()
            .watchLazy(fireImmediately: true)
            .map((_) => DateTime.now().millisecondsSinceEpoch) ??
        Stream.empty();
  }),
);

final _moduleContentsOrderingProvider = AsyncNotifierProvider.autoDispose(
  () => HiveAsyncImpliedNotifier<String, EntityOrdering>(
    HiveDataPathKey.moduleContentsOrdering.name,
    EntityOrdering.dateModifiedAsc,
    transformer: (raw) => raw.name,
    builder: (data) async =>
        EntityOrdering.values.firstWhere((e) => e.name == data, orElse: () => EntityOrdering.dateModifiedDesc),
  ),
);
