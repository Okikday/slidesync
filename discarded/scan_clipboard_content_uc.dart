import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart'; // The lightweight alternative
import 'package:slidesync/core/constants/constants.dart';
import 'package:slidesync/core/utils/result.dart';

class ScanClipboardContentUc {
  /// Runs in Isolate
  static Future<AppClipboardData> scanClipboardForData(
    Map<String, dynamic> args,
  ) async {
    final token = args['token'] as RootIsolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    AppClipboardData clipboardData = (
      data: null,
      contentType: AppClipboardContentType.empty,
    );

    final result = await Result.tryRunAsync(() async {
      // Priority 1: Check for direct image data
      final Uint8List? imageBytes = await Pasteboard.image;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        log("Clipboard has image data!");
        final sizeInMb = imageBytes.length / (1024 * 1024);

        if (sizeInMb <= 50) {
          // 50MB total limit
          clipboardData = (
            data: imageBytes,
            contentType: AppClipboardContentType.image,
          );
          return;
        }
      }

      // Priority 2: Check for file URIs and determine their type
      final List<String> files = await Pasteboard.files();

      if (files.isNotEmpty) {
        final List<String> imagePaths = [];
        final List<String> otherPaths = [];

        // Categorize files
        for (final path in files) {
          if (_isImageFile(path) || _isImageContentUri(path)) {
            imagePaths.add(path);
          } else {
            otherPaths.add(path);
          }
        }

        // Handle image files by trying to load them
        if (imagePaths.isNotEmpty) {
          final List<Uint8List> loadedImages = [];
          for (final imagePath in imagePaths) {
            try {
              if (imagePath.startsWith('content://')) {
                log("Content URI detected for image: $imagePath");
                continue;
              } else {
                final file = File(imagePath);
                if (await file.exists()) {
                  final bytes = await file.readAsBytes();
                  final sizeInMb = bytes.length / (1024 * 1024);
                  if (sizeInMb <= 5) {
                    loadedImages.add(bytes);
                  }
                }
              }
            } catch (e) {
              log("Failed to load image file: $imagePath - $e");
            }
          }

          if (loadedImages.isNotEmpty) {
            log("Clipboard has ${loadedImages.length} image file(s)");
            final newData = loadedImages.length == 1
                ? loadedImages.first
                : loadedImages;
            final newContentType = loadedImages.length == 1
                ? AppClipboardContentType.image
                : AppClipboardContentType.images;
            clipboardData = (data: newData, contentType: newContentType);
            return;
          }
        }

        // Handle other files
        if (otherPaths.isNotEmpty) {
          if (otherPaths.length > 20) return; // Limit file count

          log("Clipboard has ${otherPaths.length} file(s)");
          final newData = otherPaths.length == 1
              ? otherPaths.first
              : otherPaths;
          final newContentType = otherPaths.length == 1
              ? AppClipboardContentType.file
              : AppClipboardContentType.files;
          clipboardData = (data: newData, contentType: newContentType);
          return;
        }
      }

      // Priority 3 & 4: HTML Text & Plain Text
      final ClipboardData? textData = await Clipboard.getData(
        Clipboard.kTextPlain,
      );

      if (textData != null &&
          textData.text != null &&
          textData.text!.isNotEmpty) {
        final String text = textData.text!;

        // Fallback heuristic: check if the copied string looks like raw HTML
        if (text.contains(RegExp(r'<[a-z][\s\S]*>', caseSensitive: false))) {
          log("Clipboard has HTML data!");
          clipboardData = (
            data: text,
            contentType: AppClipboardContentType.html,
          );
          return;
        }

        log("Clipboard has text data!");
        clipboardData = (data: text, contentType: AppClipboardContentType.text);
        return;
      }

      // If nothing is found, clipboard is empty or unsupported
      log("Clipboard is empty or contains unsupported data!");
      clipboardData = (data: null, contentType: AppClipboardContentType.empty);
    });

    if (result.isSuccess) {
      log("Finished scanning clipboard for data");
    } else {
      log("An error occurred while checking clipboard: ${result.message}");
    }

    return clipboardData;
  }

  static bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'tiff',
      'heic',
      'heif',
      'svg',
    ].contains(extension);
  }

  static bool _isImageContentUri(String uriString) {
    return uriString.contains('image') ||
        uriString.contains('photo') ||
        uriString.contains('picture') ||
        uriString.contains('media/external/images') ||
        uriString.contains('com.google.android.keep/blob/image');
  }

  static bool isDataEqual(
    AppClipboardData oldData,
    dynamic newData,
    AppClipboardContentType newType,
  ) {
    if (oldData.contentType != newType) {
      log("Content types differ: ${oldData.contentType} vs $newType");
      return false;
    }

    // Handle null cases
    if (oldData.data == null && newData == null) return true;
    if (oldData.data == null || newData == null) return false;

    // Handle Uint8List (single image)
    if (newData is Uint8List && oldData.data is Uint8List) {
      final result = ListEquality().equals(oldData.data as Uint8List, newData);
      log("Comparing Uint8List: equal = $result");
      return result;
    }
    // Handle List<Uint8List> (multiple images)
    else if (newData is List<Uint8List> && oldData.data is List<Uint8List>) {
      final oldList = oldData.data as List<Uint8List>;
      final newList = newData;
      if (oldList.length != newList.length) {
        log(
          "Image list lengths differ: ${oldList.length} vs ${newList.length}",
        );
        return false;
      }
      for (int i = 0; i < oldList.length; i++) {
        if (!ListEquality().equals(oldList[i], newList[i])) {
          log("Image at index $i differs");
          return false;
        }
      }
      log("All images in list are equal");
      return true;
    }
    // Handle List<String> (file paths)
    else if (newData is List<String> && oldData.data is List<String>) {
      final result = ListEquality().equals(
        oldData.data as List<String>,
        newData,
      );
      log("Comparing string lists: equal = $result");
      return result;
    }
    // Handle String (text/html/single file path)
    else if (newData is String && oldData.data is String) {
      final result = oldData.data == newData;
      log("Comparing strings: equal = $result");
      return result;
    }

    // Fallback for other types
    final result = oldData.data == newData;
    log("Comparing other types: equal = $result");
    return result;
  }
}
