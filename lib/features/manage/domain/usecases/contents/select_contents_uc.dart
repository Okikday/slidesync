import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:slidesync/core/constants/src/enums.dart';

/// Use this class to pick various content types and copy them into the app's cache directory.
class SelectContentsUc {
  /// Picks files based on the [type] and returns a list of cached [File]s.
  Future<List<File>?> referToAddContents(CourseContentType type, {bool selectByFolder = false}) async {
    if (selectByFolder) {
      return await _selectFolder();
    }
    switch (type) {
      case CourseContentType.unknown:
        return await _selectFiles();

      case CourseContentType.document:
        return await _selectDocuments();

      case CourseContentType.image:
        return await _selectImages();

      // case CourseContentType.video:
      //   return await _selectVideos();

      // case CourseContentType.audio:
      //   return await _selectAudios();

      default:
        return null;
    }
  }
}

Future<List<File>?> _selectFolder() async {
  final result = await FilePicker.platform.getDirectoryPath();
  if (result == null) return null;
  log('Selected directory: $result');

  try {
    final dir = Directory(result);

    // Check if directory exists and is accessible
    if (!await dir.exists()) {
      log('Directory does not exist');
      return null;
    }

    // List files synchronously but handle permission errors
    final List<FileSystemEntity> entities = [];
    try {
      entities.addAll(dir.listSync(recursive: true, followLinks: false));
    } catch (e) {
      log('Permission error: $e');
      return null;
    }

    final files = entities.whereType<File>().map((f) => f.path).toList();
    log("Found ${files.length} files: ${files.take(5)}..."); // Log first 5

    if (files.isEmpty) return null;

    return await _copyToCache(files);
  } catch (e) {
    log('Error reading folder: $e');
    return null;
  }
}

/// Helper to copy picked files into cache and return them.
Future<List<File>?> _selectFiles() async {
  final result = await FilePicker.platform.pickFiles(allowMultiple: true);
  if (result == null) return null;
  return _copyToCache(result.paths.whereType<String>());
}

Future<List<File>?> _selectDocuments() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowMultiple: true,
    allowedExtensions: ['pdf', 'docx', 'xlsx'],
  );
  if (result == null) return null;
  return _copyToCache(result.paths.whereType<String>());
}

Future<List<File>?> _selectImages() async {
  final picker = ImagePicker();
  final images = await picker.pickMultiImage();
  if (images.isEmpty) return null;
  return _copyToCache(images.map((x) => x.path));
}

/// Copies each source file at [paths] into the app cache directory, returns new File list.
Future<List<File>> _copyToCache(Iterable<String> paths) async {
  final cacheDir = await getTemporaryDirectory();
  final List<File> saved = [];
  for (var sourcePath in paths) {
    final filename = sourcePath.split(Platform.pathSeparator).last;
    final dest = File('${cacheDir.path}${Platform.pathSeparator}$filename');
    final copied = await File(sourcePath).copy(dest.path);
    saved.add(copied);
  }
  return saved;
}
