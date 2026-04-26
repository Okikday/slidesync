import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';

class CourseSortNotifier extends AsyncNotifier<EntityOrdering> {
  final EntityOrdering _defaultKey;
  final String path;
  CourseSortNotifier(this.path, [this._defaultKey = EntityOrdering.dateModifiedDesc]);
  @override
  FutureOr<EntityOrdering> build() async {
    final options = EntityOrdering.values;
    final option =
        options[(await AppHiveData.instance.getData<int>(key: path))?.clamp(0, options.length - 1) ??
            _defaultKey.index];
    return option;
  }

  Future<void> set(EntityOrdering value) async {
    if (state.value == value) return;
    state = AsyncData(value);
    await AppHiveData.instance.setData(key: path, value: value.index);
  }

  // Future<void> updateSort(CourseSortOption value) async {
  //   if (value == state.value) return;
  //   state = AsyncData(value);
  //   await Result.tryRunAsync(() async => await AppHiveData.instance.setData(key: path, value: value.index));
  // }
}
