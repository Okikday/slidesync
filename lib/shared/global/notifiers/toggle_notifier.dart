import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class ToggleNotifier extends AsyncBoolNotifier {
  ToggleNotifier(this._key, {this.defaultValue = false});

  final String _key;
  final bool defaultValue;

  @override
  Future<bool> build() async {
    final value = await AppHiveData.instance.getData(key: _key);
    return value is bool ? value : defaultValue;
  }

  @override
  Future<void> toggle() async {
    final current = !(state.value ?? defaultValue);
    state = AsyncData(current);
    await AppHiveData.instance.setData(key: _key, value: current);
  }

  Future<bool> updateType(bool Function(bool? state) cb) async {
    final current = state.value ?? defaultValue;
    if (current == cb(state.value)) return cb(state.value);
    state = AsyncData(cb(state.value));
    await AppHiveData.instance.setData(key: _key, value: cb);
    return cb(state.value);
  }
}
