import 'package:hive/hive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HiveDataIsolate {
  final String boxName;
  late Box _box;
  bool _isInitialized = false;

  HiveDataIsolate({this.boxName = "customBox"});

  Future<void> _initialize() async {
    if (!_isInitialized) {
      // Each isolate needs its own Hive.init()
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      _box = await Hive.openBox(boxName);
      _isInitialized = true;
    }
  }

  Future<dynamic> getData({required String key}) async {
    await _initialize();
    return _box.get(key);
  }

  Future<void> setData({required String key, required dynamic value}) async {
    await _initialize();
    await _box.put(key, value);
  }

  Future<void> deleteData({required String key}) async {
    await _initialize();
    await _box.delete(key);
  }
}
