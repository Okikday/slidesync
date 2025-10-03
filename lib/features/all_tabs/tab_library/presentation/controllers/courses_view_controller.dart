
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums.dart';


import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';

import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/shared/global/notifiers/common/course_sort_notifier.dart';

final _coursesFilterOption = AsyncNotifierProvider<CourseSortNotifier, CourseSortOption>(
  () => CourseSortNotifier(HiveDataPathKey.libraryCourseSortOption.name),
  isAutoDispose: true,
);

final _coursesPaginationFutureProvider = FutureProvider((ref) async {
  final sortOption = await ref.read(CoursesViewController.coursesFilterOption.future);
  // Create pagination controller
  final cp = CoursesPagination.of(sortOption: sortOption);
  // Listen for when there's any change in any of the courses
  ref.listen(_watchCourseChanges, (prev, next) async {
    await compareCoursesAndUpdate(cp);
  });

  ref.onDispose(() => cp.dispose());
  return cp;
}, isAutoDispose: true);

final _watchCourseChanges = StreamProvider((ref) async* {
  final stream = await CourseRepo.isarData.watchForChanges(fireImmediately: false);
  yield* stream.map((c) => DateTime.now().millisecondsSinceEpoch);
});

final AsyncNotifierProvider<CardViewTypeNotifier, int> _cardViewTypeProvider =
    AsyncNotifierProvider<CardViewTypeNotifier, int>(
      () => CardViewTypeNotifier(HiveDataPathKey.libraryTabCardViewType.name, 2),
      isAutoDispose: true,
    );

class CoursesViewController {
  /// Outer Getters
  static AsyncNotifierProvider<CourseSortNotifier, CourseSortOption> get coursesFilterOption => _coursesFilterOption;
  static FutureProvider<CoursesPagination> get coursesPaginationFutureProvider => _coursesPaginationFutureProvider;
  static AsyncNotifierProvider<CardViewTypeNotifier, int> get cardViewTypeProvider => _cardViewTypeProvider;
}
