import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';

class CleanUpUtils {
  /// Clears the cache and temporary directories.
  Future<void> clearCacheOrTemp() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        // Delete contents, not the directory itself
        tempDir.listSync().forEach((file) {
          file.deleteSync(recursive: true);
        });
      }

      final cacheDir = await getApplicationCacheDirectory();
      if (cacheDir.existsSync()) {
        // Delete contents, not the directory itself
        cacheDir.listSync().forEach((file) {
          file.deleteSync(recursive: true);
        });
      }

      log('Cache and temporary directories cleared.');
    } catch (e) {
      log('Error clearing cache/temp: $e');
    }
  }

  /// Recursively collects all empty directories under [rootDirPath].
  static Future<List<Directory>> findEmptyDirectories(String rootDirPath) async {
    final root = Directory(rootDirPath);
    if (!await root.exists()) return [];

    List<Directory> emptyDirs = [];

    Future<void> scan(Directory dir) async {
      final entries = dir.listSync();
      for (var entity in entries) {
        if (entity is Directory) {
          await scan(entity);
        }
      }
      // Recheck after scanning children — some subdirs might have been empty
      if (dir.listSync().isEmpty) {
        emptyDirs.add(dir);
      }
    }

    await scan(root);
    return emptyDirs;
  }

  /// Deletes all empty directories under [rootDirPath].
  static Future<void> deleteEmptyCoursesDirsInIsolate(Map<String, dynamic> data) async {
    log("Deleting Empty directories");
    final RootIsolateToken rootIsolateToken = data['rootIsolateToken'] as RootIsolateToken;
    final String rootDirPath = data['rootDirPath'] ?? '';
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final Directory baseDir = await FileUtils.getAppDocumentsDirectory();
    final empties = await findEmptyDirectories(
      rootDirPath.isEmpty ? baseDir.path : p.join(rootDirPath, AppPaths.materialsFolder),
    );
    for (var dir in empties) {
      try {
        await dir.delete(recursive: false);
      } catch (_) {}
    }
  }
}
