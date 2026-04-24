import 'dart:async';
import 'dart:developer';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/storage/isar_data/default_isar_schemas.dart';
import 'package:slidesync/core/storage/isar_data/src/isar_data_access.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';

Isar? _openDb;

Map<String, Isar> _customDbs = <String, Isar>{};

/// Initializes the shared database only once
Future<Isar> _openDefault({bool inspector = true}) async {
  if (_openDb == null) {
    final dir = await FileUtils.getAppDocumentsDirectory();
    _openDb = await Isar.open(defaultIsarSchemas, directory: dir.path, name: 'default', inspector: inspector);
    log("Initialized Isar");
  }
  return _openDb!;
}

Future<void> _closeDefault() async {
  await _openDb?.close();
  _openDb = null;
}

Future<Isar> _openCustom({
  required String dbName,
  required List<CollectionSchema> collectionSchemas,
  bool inspector = true,
}) async {
  final dir = await FileUtils.getAppDocumentsDirectory();
  final isar = await Isar.open(collectionSchemas, directory: dir.path, name: dbName, inspector: inspector);
  _customDbs[dbName] = isar;
  log("Initialized custom Isar: $dbName");
  return isar;
}

Future<void> _closeCustom(String dbName) async {
  final isar = _customDbs[dbName];
  if (isar != null) {
    await isar.close();
    _customDbs.remove(dbName);
    log("Closed custom Isar: $dbName");
  }
}

class IsarData<T> extends IsarDataAccess<T> {
  @override
  Isar get isarInstance => isar;

  static Isar get isar {
    if (_openDb == null) {
      throw Exception("Isar database not initialized. Call IsarData.initialize() before using the database.");
    }
    return _openDb!;
  }

  static Future<Isar> initializeDefault({bool inspector = true}) async => await _openDefault(inspector: inspector);
  static Future<Isar> initializeCustom({
    required String dbName,
    required List<CollectionSchema> collectionSchemas,
    bool inspector = true,
  }) async => await _openCustom(dbName: dbName, collectionSchemas: collectionSchemas, inspector: inspector);

  static Future<void> closeDefault() async => await _closeDefault();
  static Future<void> closeCustom(String dbName) async => await _closeCustom(dbName);
}
