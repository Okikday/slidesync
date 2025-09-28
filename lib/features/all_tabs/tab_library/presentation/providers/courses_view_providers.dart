import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/actions/courses_view_actions.dart';

const int limit = 20;

class CoursesViewProviders {
  static final coursesFilterOptions = AsyncNotifierProvider<CourseSortNotifier, CourseSortOption>(
    CourseSortNotifier.new,
    isAutoDispose: true,
  );
  static final watchChanges = StreamProvider.autoDispose<void>((ref) async* {
    final stream = await CourseRepo.isarData.watchForChanges(fireImmediately: false);
    yield* stream;
  });

  static final PagingState<int, Course> pagingState = PagingState();
}

class CourseSortNotifier extends AsyncNotifier<CourseSortOption> {
  final CourseSortOption _defaultKey;
  CourseSortNotifier([this._defaultKey = CourseSortOption.none]);
  @override
  FutureOr<CourseSortOption> build() async {
    final option =
        CourseSortOption.values[await AppHiveData.instance.getData(key: HiveDataPathKey.libraryCourseSortOption.name)
                as int? ??
            _defaultKey.index];
    return option;
  }

  Future<void> set(CourseSortOption value) async => state = AsyncData(value);
}
