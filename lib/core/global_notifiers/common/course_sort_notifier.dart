import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';

class CourseSortNotifier extends AsyncNotifier<CourseSortOption> {
  final CourseSortOption _defaultKey;
  final String path;
  CourseSortNotifier(this.path, [this._defaultKey = CourseSortOption.dateModifiedDesc]);
  @override
  FutureOr<CourseSortOption> build() async {
    final data = await AppHiveData.instance.getData<int>(key: path);
    final options = CourseSortOption.values;
    final option = options[data?.clamp(0, options.length - 1) ?? _defaultKey.index];
    return option;
  }

  Future<void> set(CourseSortOption value) async {
    if (state.value == value) return;
    state = AsyncData(value);
    await Result.tryRunAsync(() async => await AppHiveData.instance.setData(key: path, value: value.index));
  }

  // Future<void> updateSort(CourseSortOption value) async {
  //   if (value == state.value) return;
  //   state = AsyncData(value);
  //   await Result.tryRunAsync(() async => await AppHiveData.instance.setData(key: path, value: value.index));
  // }
}
