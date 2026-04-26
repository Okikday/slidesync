import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar_community/isar.dart';

import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/module_contents_pagination_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

export 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/module_contents_pagination_state.dart';

part 'ext_module_contents_pagination_notifier.dart';

const int limit = 20;

class ModuleContentsPaginationNotifier extends Notifier<ModuleContentsPaginationState> {
  ModuleContentsPaginationNotifier(this.module) {
    pagingController = PagingController(
      getNextPageKey: _getNextPageKey,
      fetchPage: (pageKey) => fetchPage(pageKey, limit),
    );
  }

  ///
  ///
  /// ===================================================================================================
  /// DECLARATIONS
  /// ===================================================================================================

  final Module module;

  late PagingController<int, ModuleContent> pagingController;

  bool isUpdating = false;

  bool extraCheck = false;

  ///
  ///
  /// ===================================================================================================
  /// LIFECYCLE
  /// ===================================================================================================

  @override
  ModuleContentsPaginationState build() {
    final orderingProvider = _moduleContentsOrderingProvider.readX(ref);
    final initialOrdering = orderingProvider.value ?? EntityOrdering.dateModifiedDesc;

    ref.listen(
      _moduleContentsOrderingProvider,
      (prev, next) => next.whenData((newSort) => updateSortOption(newSort, refresh: true)),
      fireImmediately: true,
    );

    ref.onDispose(_dispose);

    ref.listen(_watchContentsChange(module.uid), (prev, next) async => await syncModuleContents());
    return ModuleContentsPaginationState(isLoading: true, contentsOrdering: initialOrdering);
  }

  void _dispose() async {
    pagingController.dispose();
    log("Disposed $runtimeType");
  }

  void updateSortOption(EntityOrdering newSortOption, {bool refresh = true}) {
    if (state.contentsOrdering == newSortOption) return;

    ref.read(_moduleContentsOrderingProvider.notifier).set(newSortOption);
    state = state.copyWith(sortOption: newSortOption);

    if (refresh) pagingController.refresh();
  }

  Future<List<ModuleContent>> fetchPage(int pageKey, int limit) async =>
      _fetchModuleContents(pageKey: pageKey, limit: limit);

  ///
  ///
  /// ===================================================================================================
  /// FUNCTIONS
  /// ===================================================================================================
  Future<List<ModuleContent>> _fetchModuleContents({required int pageKey, required int limit}) async {
    final offset = (pageKey - 1) * limit;
    final filter = module.contents.filter();
    if (!ref.mounted) return const [];
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
  (String? arg) => StreamedNotifier<int>(() async* {
    if (arg == null) {
      yield* Stream.empty();
      return;
    }
    final module = await ModuleRepo.getByUid(arg);
    yield* module?.contents
            .filter()
            .watchLazy(fireImmediately: true)
            .map((e) => DateTime.now().millisecondsSinceEpoch) ??
        Stream.empty();
  }),
);

final _moduleContentsOrderingProvider = AsyncNotifierProvider(
  () => HiveAsyncImpliedNotifier<String, EntityOrdering>(
    HiveDataPathKey.moduleContentsOrdering.name,
    EntityOrdering.dateModifiedAsc,
    transformer: (raw) => raw.name,
    builder: (data) async =>
        EntityOrdering.values.firstWhere((e) => e.name == data, orElse: () => EntityOrdering.dateModifiedDesc),
  ),
);
