import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/core/utils/file_utils.dart';

import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/image_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:image/image.dart';

// typedef PreviewImagePathRecord<Record> = ({String previewDirPath, String previewPath});

class CreateContentPreviewImage {
  /// Returns the preview path where the image file is stored at after making a compressed version of the image
  static Future<String?> _createForTypeImage(String path, String genToPreviewPath) async {
    final Result<String?> result = await Result.tryRunAsync(() async {
      log("Creating preview for Type Image");
      final Result<File> result = await ImageUtils.compressImage(
        inputFile: File(path),
        targetMB: 0.05,
        outputFormat: 'png',
      );

      if (result.isSuccess) {
        final File file = result.data!;
        final appDocDir = await FileUtils.getAppDocumentsDirectory();

        // separate the path into directory + file name
        final dirPath = p.join(appDocDir.path, p.dirname(genToPreviewPath));
        final fileName = p.basename(genToPreviewPath);

        // create the directory if it doesn't exist
        await Directory(dirPath).create(recursive: true);

        final copyToPath = p.join(dirPath, fileName);
        await file.copy(copyToPath);
        await file.delete();
        return copyToPath;
      }
      return null;
    });

    return result.data;
  }

  static Future<String?> _createForTypeDocument(String path, String genToPreviewPath) async {
    final Result<String?> result = await Result.tryRunAsync(() async {
      log("Creating preview for Type Document");

      pdfrxFlutterInitialize();

      final PdfDocument document = await PdfDocument.openFile(path);
      try {
        if (document.pages.isEmpty) {
          log("PDF has no pages");
          await document.dispose();
          return null;
        }

        // first page (pages list is zero-indexed)
        final PdfPage page = document.pages[0];

        final int targetWidth = page.width.toInt();
        final int targetHeight = page.height.toInt();

        final PdfImage? pageImage = await page.render(width: targetWidth, height: targetHeight);

        if (pageImage == null) {
          log("Failed to render PDF page");
          await document.dispose();
          return null;
        }

        final imageObj = pageImage.createImageNF();

        final List<int> bytes = encodePng(imageObj);

        pageImage.dispose();

        // Create temporary file for the rendered PDF page
        final tempDir = await Directory.systemTemp.createTemp('pdf_preview_');
        final tempFile = File(p.join(tempDir.path, 'temp_pdf_page.png'));
        await tempFile.writeAsBytes(bytes);

        // Compress the rendered PDF image
        final Result<File> compressionResult = await ImageUtils.compressImage(
          inputFile: tempFile,
          targetMB: 0.05,
          outputFormat: 'png',
        );

        if (compressionResult.isSuccess) {
          final File file = compressionResult.data!;
          final appDocDir = await FileUtils.getAppDocumentsDirectory();

          // separate the path into directory + file name
          final dirPath = p.join(appDocDir.path, p.dirname(genToPreviewPath));
          final fileName = p.basename(genToPreviewPath);

          await Directory(dirPath).create(recursive: true);

          final copyToPath = p.join(dirPath, fileName);
          await file.copy(copyToPath);
          await file.delete();

          await tempDir.delete(recursive: true);

          await document.dispose();
          log("Created compressed preview for document: $copyToPath");
          return copyToPath;
        } else {
          await tempDir.delete(recursive: true);
          await document.dispose();
          log("Failed to compress PDF preview");
          return null;
        }
      } catch (e, st) {
        try {
          await document.dispose();
        } catch (_) {}
        log('Error rendering PDF preview: $e\n$st');
        rethrow;
      }
    });

    return result.data;
  }

  void createForTypeLink() {}

  static Future<String?> createPreviewImageForContent(
    String path, {
    required CourseContentType courseContentType,
    required String filePath,
  }) async {
    final genPreviewPath = genRelativePreviewPath(filePath: filePath);
    if (genPreviewPath == null) return null;
    log("ContentType for preview: ${courseContentType.name}");
    switch (courseContentType) {
      case CourseContentType.image:
        return await _createForTypeImage(path, genPreviewPath);
      case CourseContentType.document:
        return await _createForTypeDocument(path, genPreviewPath);

      default:
        return null;
    }
  }

  /// Gets the preview image path for a file
  /// Make sure you are sending in a relative path
  static String? genRelativePreviewPath({required String filePath}) {
    final lastIndexOfPathSep = filePath.lastIndexOf(Platform.pathSeparator);
    if (lastIndexOfPathSep < 0) {
      return null;
    } else {
      final segments = p.split(filePath);
      if (segments.isEmpty) return null;

      final lastSegments = segments.length > 3 ? segments.sublist(segments.length - 3) : segments;

      final previewDir = AppPaths.previewsFolder;
      final relativePath = p.joinAll(lastSegments);

      return p.join(previewDir, relativePath);
    }
  }

  static FileDetails fileDetailsFromJson(String source) => FileDetails.fromJson(source);
  static CourseContent courseContentFromJson(String source) => CourseContent.fromJson(source);

  /// Adding lots of contents image preview in Background/Isolate
  static Future<void> createPreviewImagesTask(Map<String, dynamic> args) async {
    final Result<bool?> outcome = await Result.tryRunAsync<bool>(() async {
      final RootIsolateToken rootIsolateToken = args['rootIsolateToken'] as RootIsolateToken;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      final List<CourseContent> allContents = (args['courseContentsJsons'] as List<String>)
          .map((e) => courseContentFromJson(e))
          .toList();

      for (int i = 0; i < allContents.length; i++) {
        final content = allContents[i];
        final String path = fileDetailsFromJson(content.path).filePath;
        final bool fileExists = await File(path).exists();
        if (fileExists) {
          final previewPath = genRelativePreviewPath(filePath: path);
          if (previewPath == null) continue;
          final bool previewExists = await File(previewPath).exists();
          if (previewExists) {
            continue;
          } else {
            log("Creating preview image");

            await createPreviewImageForContent(
              path,
              courseContentType: content.courseContentType,
              filePath: previewPath,
            );
          }
        }
      }
      return true;
    });
    if (outcome.isSuccess) {
      log("Loaded image previews");
    } else {
      log("An exception occured!");
    }
  }

  static Future<List<CourseContent>> filterContentsWithoutPreview(List<CourseContent> courseContents) async {
    final List<CourseContent> nonExistingPreviewCourseContents = [];
    for (final content in courseContents) {
      final previewPath = genRelativePreviewPath(filePath: content.path.filePath);
      if (previewPath == null || previewPath.isEmpty) continue;
      if (!(await File(previewPath).exists())) {
        nonExistingPreviewCourseContents.add(content);
      }
    }
    return nonExistingPreviewCourseContents;
  }
}
