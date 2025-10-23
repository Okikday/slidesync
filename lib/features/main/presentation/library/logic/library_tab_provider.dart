import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/main/presentation/library/logic/src/courses_pagination.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/shared/global/notifiers/common/course_sort_notifier.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/features/main/presentation/library/logic/src/library_tab_state.dart';

class LibraryTabProvider {
  ///|
  ///|
  /// ===================================================================================================
  /// STATE
  /// ===================================================================================================
  static final state = Provider<LibraryTabState>((ref) {
    final lts = LibraryTabState.of(ref);
    ref.onDispose(lts.dispose);
    return lts;
  });

  ///|
  ///|
  /// ===================================================================================================
  /// COURSES PAGINATION
  /// ===================================================================================================

  static final _watchCourseChanges = StreamProvider((ref) async* {
    final stream = await CourseRepo.isarData.watchForChanges(fireImmediately: false);
    yield* stream.map((c) => DateTime.now().millisecondsSinceEpoch);
  });

  static final coursesPaginationProvider = FutureProvider<CoursesPagination>((ref) async {
    final sortOption = await ref.read(coursesFilterProvider.future);
    final cp = CoursesPagination.of(sortOption: sortOption);
    // Listen for when there's any change in any of the courses
    ref.listen(_watchCourseChanges, (prev, next) async {
      await cp.compareCoursesAndUpdate(cp);
    });

    ref.onDispose(() => cp.dispose());
    return cp;
  });

  static final coursesFilterProvider = AsyncNotifierProvider.autoDispose<CourseSortNotifier, CourseSortOption>(
    () => CourseSortNotifier(HiveDataPathKey.libraryCourseSortOption.name),
  );

  ///|
  ///|
  /// ===================================================================================================
  /// OTHERS
  /// ===================================================================================================

  static final cardViewTypeProvider = AsyncNotifierProvider.autoDispose<CardViewTypeNotifier, int>(
    () => CardViewTypeNotifier(HiveDataPathKey.libraryTabCardViewType.name, 2),
  );
}
