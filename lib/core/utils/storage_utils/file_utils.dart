import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';

export 'dart:io';

class FileUtils {
  static Future<Directory> getAppDocumentsDirectory() async =>
      await (Platform.isWindows ? getApplicationSupportDirectory() : getApplicationDocumentsDirectory());

  static Future<String> _storeToAppDirectory(
    File file,
    String folderPath,
    String? newFileName, {
    AppDirType base = AppDirType.documents,
    bool overwrite = false,
  }) async {
    final Directory baseDir;
    switch (base) {
      case AppDirType.appSupport:
        baseDir = await getApplicationSupportDirectory();
        break;
      case AppDirType.temporary:
        baseDir = await getTemporaryDirectory();
        break;
      case AppDirType.cache:
        baseDir = await getTemporaryDirectory();
        break;
      case AppDirType.documents:
        baseDir = await getAppDocumentsDirectory();
        break;
    }

    final String fileName = p.basename(file.path);
    final String targetDirPath = folderPath.isEmpty ? baseDir.path : p.join(baseDir.path, folderPath);

    final Directory targetDir = Directory(targetDirPath);
    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }

    final String candidatePath = p.join(targetDirPath, newFileName ?? fileName);
    final String newPath = overwrite ? candidatePath : getUniqueFilePath(targetDirPath, newFileName ?? fileName);

    await file.copy(newPath);
    return newPath;
  }

  /// This stores File to the selected App directory (documents/appSupport/temporary/cache).
  /// Returns the path it's stored to.
  static Future<String> storeFile({
    required File file,
    String folderPath = '',
    String? newFileName,
    AppDirType base = AppDirType.documents,
    bool overwrite = false,
  }) async {
    return await _storeToAppDirectory(file, folderPath, newFileName, base: base, overwrite: overwrite);
  }

  static String getUniqueFilePath(String dirPath, String fileName) {
    String baseName = p.basenameWithoutExtension(fileName);
    String extension = p.extension(fileName);
    String newPath = p.join(dirPath, fileName);
    int counter = 1;

    while (File(newPath).existsSync()) {
      newPath = p.join(dirPath, '$baseName($counter)$extension');
      counter++;
    }

    return newPath;
  }

  /// Attempts to delete the file at [path].
  ///
  /// Returns `true` if the file existed and was deleted successfully,
  /// `false` if the file did not exist or if any error occurred.
  static Future<bool> deleteFileAtPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      } else {
        // File wasn’t there
        return false;
      }
    } catch (e) {
      // If something went wrong (e.g. permissions), treat as “couldn’t delete”
      return false;
    }
  }

  /// Deletes [relativePath] under the selected [base] directory.
  /// e.g. if base==documents and relativePath=="foo/bar",
  /// this will delete `appDocDir`/foo/bar recursively.
  static Future<bool> deleteFromAppDirectory({
    required String relativePath,
    AppDirType base = AppDirType.documents,
  }) async {
    try {
      Directory baseDir;
      switch (base) {
        case AppDirType.appSupport:
          baseDir = await getApplicationSupportDirectory();
          break;
        case AppDirType.temporary:
          baseDir = await getTemporaryDirectory();
          break;
        case AppDirType.cache:
          baseDir = await getTemporaryDirectory(); // or getCacheDirectory() on some platforms
          break;
        case AppDirType.documents:
          baseDir = await getAppDocumentsDirectory();
          break;
      }

      final targetDir = Directory(p.join(baseDir.path, relativePath));
      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
      }
      return true;
    } catch (e) {
      log('deleteAppDirectory error: $e');
      return false;
    }
  }

  /// Returns the file size in bytes, or 0 if the file doesn't exist (or on error).
  static Future<int> fileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return 0;
      return await file.length();
    } catch (_) {
      return 0;
    }
  }

  /// Searches for a file by name in the given [searchPath] or
  /// defaults to the app’s application directory.
  Future<File?> searchFile(String fileName, {Directory? searchPath}) async {
    try {
      final Directory dir = searchPath ?? await FileUtils.getAppDocumentsDirectory();

      File? result;

      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith(fileName)) {
          result = entity;
          break; // Stop at first match
        }
      }

      if (result != null) {
        log('File found: ${result.path}');
      } else {
        log('File not found.');
      }

      return result;
    } catch (e) {
      log('Error searching for file: $e');
      return null;
    }
  }

  /// Deletes files in paths provided. Returns the count of files that were deleted
  static Future<int> deleteFiles(List<String> paths) async {
    int count = 0;
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
          count++;
        } catch (_) {}
      }
    }
    return count;
  }

  Future<int> getFolderSize(String folderPath) async {
    final directory = Directory(folderPath);
    if (!await directory.exists()) return 0;

    int totalSize = 0;

    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          totalSize += await entity.length();
        } catch (_) {
          // skip unreadable files
        }
      }
    }

    return totalSize;
  }

  static Future<int> getFilesSize(List<File> files) async {
    int total = 0;
    for (final file in files) {
      total += await file.length();
    }
    return total;
  }

  static Future<int> getFileSize(String path) async {
    final file = File(path);
    return await file.length();
  }
}
