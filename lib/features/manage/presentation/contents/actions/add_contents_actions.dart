import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/basic_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/store_contents.dart';
import 'package:slidesync/features/manage/domain/usecases/types/add_content_result.dart';
import 'package:slidesync/features/manage/presentation/contents/views/add_contents/adding_content_overlay.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/add_contents_uc.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/helpers.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';
import 'package:super_clipboard/super_clipboard.dart';

enum AppClipboardContentType { empty, text, image, images, file, files, html, unsupported }

typedef AppClipboardData = ({dynamic data, AppClipboardContentType contentType});

class AddContentsActions {
  /// Runs in Isolate
  static Future<AppClipboardData> scanClipboardForData(Map<String, dynamic> args) async {
    final token = args['token'] as RootIsolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    AppClipboardData clipboardData = (data: null, contentType: AppClipboardContentType.empty);

    final Result<void> result = await Result.tryRunAsync(() async {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) return;

      final reader = await clipboard.read();

      // Priority 1: Check for direct image formats
      final List<Uint8List> images = [];

      if (reader.canProvide(Formats.png)) {
        log("Clipboard has PNG image data!");
        await _readImageFile(reader, Formats.png, images);
      }

      if (reader.canProvide(Formats.jpeg)) {
        log("Clipboard has JPEG image data!");
        await _readImageFile(reader, Formats.jpeg, images);
      }

      if (reader.canProvide(Formats.gif)) {
        log("Clipboard has GIF image data!");
        await _readImageFile(reader, Formats.gif, images);
      }

      if (reader.canProvide(Formats.webp)) {
        log("Clipboard has WebP image data!");
        await _readImageFile(reader, Formats.webp, images);
      }

      if (images.isNotEmpty) {
        final totalSize = images.fold(0, (sum, img) => sum + img.length) / (1024 * 1024);
        if (totalSize > 50) return; // 50MB total limit

        final newData = images.length == 1 ? images.first : images;
        final newContentType = images.length == 1 ? AppClipboardContentType.image : AppClipboardContentType.images;
        clipboardData = (data: newData, contentType: newContentType);
        return;
      }

      // Priority 2: Check for file URIs and determine their type
      if (reader.canProvide(Formats.fileUri)) {
        final Uri? uri = await reader.readValue(Formats.fileUri);
        if (uri == null) return;

        final List<String> filePaths = [uri.path];
        final List<String> imagePaths = [];
        final List<String> otherPaths = [];

        // Categorize files
        for (final path in filePaths) {
          if (_isImageFile(path) || _isImageContentUri(uri.toString())) {
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
              if (uri.scheme == 'content') {
                log("Content URI detected for image: ${uri.toString()}");
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
            final newData = loadedImages.length == 1 ? loadedImages.first : loadedImages;
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
          final newData = otherPaths.length == 1 ? otherPaths.first : otherPaths;
          final newContentType = otherPaths.length == 1 ? AppClipboardContentType.file : AppClipboardContentType.files;
          clipboardData = (data: newData, contentType: newContentType);
          return;
        }
      }

      // Priority 3: Check for HTML text
      if (reader.canProvide(Formats.htmlText)) {
        log("Clipboard has HTML data!");
        final String? htmlData = await reader.readValue(Formats.htmlText);
        if (htmlData != null && htmlData.isNotEmpty) {
          clipboardData = (data: htmlData, contentType: AppClipboardContentType.html);
          return;
        }
      }

      // Priority 4: Check for plain text
      if (reader.canProvide(Formats.plainText)) {
        log("Clipboard has text data!");
        final String? textData = await reader.readValue(Formats.plainText);
        if (textData != null && textData.isNotEmpty) {
          clipboardData = (data: textData, contentType: AppClipboardContentType.text);
          return;
        }
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

  static Future<void> _readImageFile(ClipboardReader reader, SimpleFileFormat format, List<Uint8List> images) async {
    try {
      final completer = Completer<void>();

      reader.getFile(format, (file) async {
        try {
          final stream = file.getStream();
          final bytes = <int>[];
          await for (final chunk in stream) {
            bytes.addAll(chunk);
          }
          final imageData = Uint8List.fromList(bytes);
          final sizeInMb = imageData.length / (1024 * 1024);
          if (sizeInMb <= 5) {
            // 5MB per image limit
            images.add(imageData);
          }
          completer.complete();
        } catch (e) {
          log("Error in getFile callback: $e");
          completer.completeError(e);
        }
      });

      await completer.future;
    } catch (e) {
      log("Failed to read image file: $e");
    }
  }

  static bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff', 'heic', 'heif', 'svg'].contains(extension);
  }

  static bool _isImageContentUri(String uriString) {
    // Check for common Android content URI patterns that indicate images
    return uriString.contains('image') ||
        uriString.contains('photo') ||
        uriString.contains('picture') ||
        uriString.contains('media/external/images') ||
        uriString.contains('com.google.android.keep/blob/image');
  }

  static bool isDataEqual(AppClipboardData oldData, dynamic newData, AppClipboardContentType newType) {
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
        log("Image list lengths differ: ${oldList.length} vs ${newList.length}");
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
      final result = ListEquality().equals(oldData.data as List<String>, newData);
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

  static void onClickToAddContent(
    BuildContext context, {
    required CourseCollection collection,
    required CourseContentType type,
  }) async {
    final sMap = await AppHiveData.instance.getData(key: HiveDataPathKey.contentsAddingProgressList.name);
    if (sMap != null) {
      final selectedContentPathsOnStorage = sMap as Map<String, dynamic>?;

      if (selectedContentPathsOnStorage != null && selectedContentPathsOnStorage.isNotEmpty) {
        bool canContinue = false;
        await asyncUseRootStateContext(
          (context) async => await UiUtils.showCustomDialog(
            context,
            child: AppAlertDialog(
              title: "Pending operation",
              content:
                  "Some of the contents you were adding didn’t finish processing last time. Would you like to complete that first?",
              onCancel: () {
                canContinue = false;
                context.pop();
              },
              onConfirm: () {
                canContinue = true;
                context.pop();
              },
              onPop: () {
                canContinue = false;
                context.pop();
              },
            ),
          ),
        );

        if (canContinue) {
          await AddContentsUc.resumeFromLastAddToCollection(selectedContentPathsOnStorage, collection);
          await asyncUseRootStateContext(
            (context) async => await UiUtils.showFlushBar(
              context,
              msg: "You'll be referred to add contents soon, watch out...",
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }

    ValueNotifier<String> valueNotifier = ValueNotifier("Loading...");
    final entry = OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) => LoadingOverlay(message: value),
      ),
    );
    if (context.mounted) {
      Overlay.of(context).insert(entry);
    } else {
      final currContext = rootNavigatorKey.currentState?.context;
      if (currContext != null && currContext.mounted) {
        Overlay.of(context).insert(entry);
      }
    }
    final List<AddContentResult> result = await AddContentsUc.addToCollection(
      collection: collection,
      type: type,
      valueNotifier: valueNotifier,
    );

    entry.remove();
    valueNotifier.dispose();
    log("result: $result");
    if (result.isNotEmpty) {
      final currContext = rootNavigatorKey.currentState?.context;
      if (currContext != null && currContext.mounted) {
        Overlay.of(context).insert(entry);
      }
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "Successfully added course contents!",
        vibe: FlushbarVibe.success,
      );
    } else if (result.isEmpty) {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "An error was encountered while adding contents!",
        flushbarPosition: FlushbarPosition.TOP,
        vibe: FlushbarVibe.warning,
      );
    } else {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "An error occured while adding contents",
        vibe: FlushbarVibe.error,
      );
    }
  }

  static void onClickToAddContentNoRef({required CourseCollection collection, required List<String> filePaths}) async {
    ValueNotifier<String> valueNotifier = ValueNotifier("Offloading contents");
    final entry = OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) => LoadingOverlay(message: value),
      ),
    );
    if (rootNavigatorKey.currentState!.overlay!.context.mounted) {
      rootNavigatorKey.currentState?.overlay?.insert(entry);
    }
    final List<AddContentResult> result = await AddContentsUc.addToCollectionNoRef(
      collection: collection,
      valueNotifier: valueNotifier,
      filePaths: filePaths,
    );

    entry.remove();
    valueNotifier.dispose();

    if (result.isNotEmpty) {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "Successfully added course contents!",
        vibe: FlushbarVibe.success,
      );
    } else if (result.isEmpty) {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "An error was encountered while adding contents!",
        flushbarPosition: FlushbarPosition.TOP,
        vibe: FlushbarVibe.warning,
      );
    } else {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "An error occured while adding contents",
        vibe: FlushbarVibe.error,
      );
    }
  }
}
