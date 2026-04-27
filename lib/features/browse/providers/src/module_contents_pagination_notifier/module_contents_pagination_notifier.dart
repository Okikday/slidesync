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

  late final PagingController<int, ModuleContent> pagingController = PagingController(
    getNextPageKey: _getNextPageKey,
    fetchPage: (pageKey) => fetchPage(pageKey, limit),
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

    ref.listen(_watchContentsChange(moduleId), (prev, next) async => await syncModuleContents());

    ref.onDispose(_dispose);

    return ModuleContentsPaginationState(
      isLoading: true,
      contentsOrdering: contentsOrdering ?? EntityOrdering.dateModifiedDesc,
    );
  }

  void _dispose() async {
    pagingController.dispose();
    log("Disposed $runtimeType");
  }

  Future<void> _initModule() async {
    await Result.tryRunAsync(() async => module = await ModuleRepo.getByDbId(moduleId));
    log("Initialized module");
    return;
  }

  ///
  ///
  /// ===================================================================================================
  /// FUNCTIONS
  /// ===================================================================================================

  void updateContentsOrdering(EntityOrdering newSortOption, {bool refresh = true}) {
    if (state.contentsOrdering == newSortOption) return;

    ref.read(_moduleContentsOrderingProvider.notifier).set(newSortOption);
    state = state.copyWith(contentsOrdering: newSortOption, isLoading: false);

    if (refresh) _refreshAndFetchFirstPage();
  }

  Future<List<ModuleContent>> fetchPage(int pageKey, int limit) async {
    if (module == null) {
      await _initModule();
      state = state.copyWith(isLoading: false);
    }
    if (_pendingRefresh && pageKey == 1) {
      _pendingRefresh = false;
      scheduleMicrotask(
        () => pagingController
          ..refresh()
          ..fetchNextPage(),
      );
    }

    final result = await _fetchModuleContents(pageKey: pageKey, limit: limit);

    return result;
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

  Future<List<ModuleContent>> _fetchModuleContents({required int pageKey, required int limit}) async {
    final filter = module!.contents.filter();
    final offset = (pageKey - 1) * limit;

    if (!ref.mounted) return [];
    final contentsOrdering = state.contentsOrdering;

    final query = switch (contentsOrdering) {
      EntityOrdering.nameAsc => filter.sortByTitle(),
      EntityOrdering.nameDesc => filter.sortByTitleDesc(),
      EntityOrdering.dateCreatedAsc => filter.sortByCreatedAt(),
      EntityOrdering.dateCreatedDesc => filter.sortByCreatedAtDesc(),
      EntityOrdering.dateModifiedAsc => filter.sortByLastModified(),
      EntityOrdering.dateModifiedDesc => filter.sortByLastModifiedDesc(),
    };

    return await query.offset(offset).limit(limit).findAll();
  }

  int? _getNextPageKey(PagingState<int, ModuleContent> state) => state.lastPageIsEmpty ? null : state.nextIntPageKey;
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
            .map((e) => DateTime.now().millisecondsSinceEpoch) ??
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
