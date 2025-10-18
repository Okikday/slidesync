import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class CardViewTypeNotifier extends AsyncIntNotifier {
  CardViewTypeNotifier(this._key, this._maxNumofType);

  final String _key;
  final int _maxNumofType;

  @override
  Future<int> build() async {
    final value = await AppHiveData.instance.getData(key: _key);
    return value is int ? value : 1;
  }

  Future<void> toggle() async {
    final current = (state.value ?? 0) + 1;
    final toSet = current < 0 || current > (_maxNumofType - 1) ? 0 : current;
    state = AsyncData(toSet);
    await AppHiveData.instance.setData(key: _key, value: toSet);
  }

  /// 0 for Grid, 1 for List, 2 for otherwise
  Future<int> updateType(int cb) async {
    final current = state.value ?? 0;
    if (current == cb) return cb;
    state = AsyncData(cb);
    await AppHiveData.instance.setData(key: _key, value: cb);
    return cb;
  }
}
