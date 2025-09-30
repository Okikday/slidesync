import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/core/global_notifiers/common/course_sort_notifier.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';

final _coursesFilterOption = AsyncNotifierProvider<CourseSortNotifier, CourseSortOption>(
  CourseSortNotifier.new,
  isAutoDispose: true,
);

final _coursesPaginationFutureProvider = FutureProvider((ref) async {
  final sortOption = await ref.watch(CoursesViewController.coursesFilterOption.future);
  await ref.watch(_watchCourseChanges.future);
  final cp = CoursesPagination.of(sortOption: sortOption);

  ref.onDispose(() => cp.dispose());
  return cp;
}, isAutoDispose: true);

final _watchCourseChanges = StreamProvider((ref) async* {
  final stream = await CourseRepo.isarData.watchForChanges(fireImmediately: true);
  yield* stream;
});

// final coursesChangeListenerProvider = Provider.autoDispose<void>((ref) {
//   ref.listen<AsyncValue<dynamic>>(
//     _watchCourseChanges,
//     (previous, next) {
//       if (next is AsyncData) {
//         ref.invalidate(_coursesPaginationFutureProvider);
//       }
//     },
//     fireImmediately: false,
//   );
// });

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
