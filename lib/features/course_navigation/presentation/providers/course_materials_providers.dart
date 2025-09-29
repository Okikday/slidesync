import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/models/progress_track_models/content_track.dart';
import 'package:slidesync/domain/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';
import 'package:slidesync/core/global_notifiers/common/card_view_type_notifier.dart';

final defaultContent = CourseContent.create(
  contentHash: '_',
  parentId: '_',
  title: '_',
  path: const FileDetails(),
  courseContentType: CourseContentType.unknown,
);

Future<QueryBuilder<CourseContent, CourseContent, QAfterSortBy>> _resolveQueryBuilder(
  String collectionId,
  CourseSortOption sortOption,
) async {
  final base = (await CourseContentRepo.filter).parentIdEqualTo(collectionId);

  switch (sortOption) {
    case CourseSortOption.nameAsc:
      return base.sortByTitle();
    case CourseSortOption.nameDesc:
      return base.sortByTitleDesc();
    case CourseSortOption.dateCreatedAsc:
      return base.sortByCreatedAt();
    case CourseSortOption.dateCreatedDesc:
      return base.sortByCreatedAtDesc();
    case CourseSortOption.dateModifiedAsc:
      return base.sortByLastModified();
    case CourseSortOption.dateModifiedDesc:
      return base.sortByLastModifiedDesc();
    case CourseSortOption.none:
      return base.sortByLastModifiedDesc();
  }
}

final _watchContentsFamily = StreamProvider.family<List<ContentWithProgress>, String>((ref, collectionId) {
  final sortOption = ref.watch(CourseMaterialsProviders.contentFilterProvider).value ?? CourseSortOption.none;
  final controller = StreamController<List<ContentWithProgress>>();

  StreamSubscription<List<CourseContent>>? contentsSub;
  StreamSubscription<List<ContentTrack>>? progressSub;

  List<CourseContent> latestContents = [];
  Map<String, ContentTrack> latestProgressMap = {};

  void emitCombined() {
    if (controller.isClosed) return;
    final combined = latestContents
        .map((c) => ContentWithProgress(content: c, progress: latestProgressMap[c.contentId]))
        .toList();
    controller.add(combined);
  }

  () async {
    try {
      final isar = await IsarData.isarFuture;
      final query = await _resolveQueryBuilder(collectionId, sortOption);
      final contentsStream = query.watch(fireImmediately: true);

      contentsSub = contentsStream.listen(
        (contents) {
          latestContents = contents;
          final ids = contents.map((c) => c.contentId).toList();

          progressSub?.cancel();
          progressSub = null;

          if (ids.isEmpty) {
            latestProgressMap = {};
            emitCombined();
            return;
          }

          progressSub = isar.contentTracks
              .filter()
              .anyOf(ids, (q, id) => q.contentIdEqualTo(id))
              .watch(fireImmediately: true)
              .listen(
                (progressList) {
                  final m = <String, ContentTrack>{for (final p in progressList) p.contentId: p};
                  latestProgressMap = m;
                  emitCombined();
                },
                onError: (e, st) {
                  if (!controller.isClosed) controller.addError(e, st);
                },
              );
        },
        onError: (e, st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }
  }();

  // Cleanup on provider dispose
  ref.onDispose(() {
    contentsSub?.cancel();
    progressSub?.cancel();
    controller.close();
  });

  return controller.stream;
});

class CourseMaterialsProviders {
  /// 0 for Grid, 1 for List, 2 for otherwise
  static final AsyncNotifierProvider<CardViewTypeNotifier, int> cardViewType =
      AsyncNotifierProvider<CardViewTypeNotifier, int>(
        () => CardViewTypeNotifier(HiveDataPathKey.courseMaterialscardViewType.name, 2),
        isAutoDispose: true,
      );

  static final AsyncNotifierProvider<ContentSortNotifier, CourseSortOption> contentFilterProvider =
      AsyncNotifierProvider<ContentSortNotifier, CourseSortOption>(ContentSortNotifier.new, isAutoDispose: true);

  static StreamProvider<List<ContentWithProgress>> watchContents(String collectionId) =>
      _watchContentsFamily(collectionId);

  static final PagingState<int, CourseContent> pagingState = PagingState();
  static final NotifierProvider<DoubleNotifier, double> scrollOffsetProvider = NotifierProvider(
    DoubleNotifier.new,
    isAutoDispose: true,
  );
}

class ContentWithProgress {
  final CourseContent content;
  final ContentTrack? progress; // may be null if no progress yet

  ContentWithProgress({required this.content, this.progress});
}

class ContentSortNotifier extends AsyncNotifier<CourseSortOption> {
  final CourseSortOption _defaultKey;
  ContentSortNotifier([this._defaultKey = CourseSortOption.none]);
  @override
  FutureOr<CourseSortOption> build() async {
    final option =
        CourseSortOption.values[await AppHiveData.instance.getData(key: HiveDataPathKey.courseMaterialsSortOption.name)
                as int? ??
            _defaultKey.index];
    return option;
  }

  Future<void> set(CourseSortOption value) async => state = AsyncData(value);
}
