import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';

class CourseSortNotifier extends AsyncNotifier<CourseSortOption> {
  final CourseSortOption _defaultKey;
  CourseSortNotifier([this._defaultKey = CourseSortOption.none]);
  @override
  FutureOr<CourseSortOption> build() async {
    final data = await AppHiveData.instance.getData<int>(key: HiveDataPathKey.libraryCourseSortOption.name);
    final option = CourseSortOption.values[data ?? _defaultKey.index];
    return option;
  }

  Future<void> set(CourseSortOption value) async {
    state = AsyncData(value);
    await Result.tryRunAsync(
      () async =>
          await AppHiveData.instance.setData(key: HiveDataPathKey.libraryCourseSortOption.name, value: value.index),
    );
  }
}
