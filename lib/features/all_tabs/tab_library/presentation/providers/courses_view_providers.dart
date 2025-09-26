import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/actions/courses_view_actions.dart';

const int limit = 20;

class CoursesViewProviders {
  static final AutoDisposeStateProvider<CourseSortOption> coursesFilterOptions = AutoDisposeStateProvider((ref) {
    // ref.onDispose(() => log("Disposed coursesFilterOptions"));
    return CourseSortOption.none;
  });
  static final AutoDisposeStreamProvider<void> watchChanges = AutoDisposeStreamProvider<void>((ref) async* {
    final stream = await CourseRepo.isarData.watchForChanges(fireImmediately: false);
    yield* stream;
  });

  static final PagingState<int, Course> pagingState = PagingState();
}
