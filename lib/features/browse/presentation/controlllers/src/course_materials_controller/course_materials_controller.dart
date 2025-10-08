import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/shared/global/notifiers/common/course_sort_notifier.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/features/browse/presentation/controlllers/src/course_materials_controller/course_materials_pagination.dart';

final defaultContent = CourseContent.create(
  contentHash: '_',
  parentId: '_',
  title: '_',
  path: const FileDetails(),
  courseContentType: CourseContentType.unknown,
);

final _contentSortOptionProvider = AsyncNotifierProvider<CourseSortNotifier, CourseSortOption>(
  () => CourseSortNotifier(HiveDataPathKey.courseMaterialsSortOption.name),
  isAutoDispose: true,
);
final _contentPaginationFutureProvider = FutureProvider.family<CourseMaterialsPagination, String>((
  ref,
  collectionId,
) async {
  final sortOption = (await ref.read(_contentSortOptionProvider.future));
  // await Future.delayed(Durations.medium1);
  final cp = CourseMaterialsPagination.of(collectionId, sortOption: sortOption);
  ref.onDispose(() => cp.dispose());
  return cp;
}, isAutoDispose: true);

class CourseMaterialsController {
  /// 0 for Grid, 1 for List, 2 for otherwise
  static final AsyncNotifierProvider<CardViewTypeNotifier, int> cardViewType =
      AsyncNotifierProvider<CardViewTypeNotifier, int>(
        () => CardViewTypeNotifier(HiveDataPathKey.courseMaterialscardViewType.name, 2),
        isAutoDispose: true,
      );
  static AsyncNotifierProvider<CourseSortNotifier, CourseSortOption> get contentSortOptionProvider =>
      _contentSortOptionProvider;
  static FutureProvider<CourseMaterialsPagination> contentPaginationProvider(String collectionId) =>
      _contentPaginationFutureProvider(collectionId);

  static final NotifierProvider<DoubleNotifier, double> scrollOffsetProvider = NotifierProvider(
    DoubleNotifier.new,
    isAutoDispose: true,
  );
}
