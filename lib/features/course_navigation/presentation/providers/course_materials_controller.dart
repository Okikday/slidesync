import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/global_notifiers/common/course_sort_notifier.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';
import 'package:slidesync/core/global_notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_materials_controller/course_materials_pagination.dart';

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