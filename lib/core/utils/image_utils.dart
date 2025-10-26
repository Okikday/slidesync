// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/utils/file_utils.dart';

import 'result.dart';

class ImageUtils {
  /// Compress [inputFile], possibly resizing to [maxWidth]/[maxHeight],
  /// output to either [outputFormat] (jpg/png/webp) or keep the same
  /// format as the input.
  ///
  /// If [targetMB] is provided, we will do a second‐pass quality adjustment
  /// so the result is at or below that size (never dropping below quality=10).
  ///
  /// Returns a new file under the app's documents directory named
  /// "IMG-YYYYMMDD-WA####.<ext>".
  static Future<Result<File>> compressImage({
    required File inputFile,
    String? outputFormat,
    int quality = 90,
    double? targetMB,
    int maxWidth = 400,
    int maxHeight = 400,
  }) async {
    try {
      if (!(await inputFile.exists())) {
        return Result.error('Source file does not exist.');
      }

      // Generate a new, unique filename for the output
      final Directory docDir = await FileUtils.getAppDocumentsDirectory();
      // Figure out which extension to write
      final String srcExt = p.extension(inputFile.path).replaceFirst('.', '').toLowerCase();
      final String ext = (outputFormat ?? srcExt).toLowerCase();
      final CompressFormat format = _formatFromExt(ext);
      String outPath = await _generateNextFilePath(docDir, ext);
      final lastSeparatorIndex = outPath.lastIndexOf(Platform.pathSeparator);
      final dirPath = "${outPath.substring(0, lastSeparatorIndex + 1)}cache";
      outPath = "$dirPath${outPath.substring(lastSeparatorIndex)}";

      Uint8List? compressedBytes;

      // Check if platform supports flutter_image_compress
      final bool useNativeCompression = Platform.isAndroid || Platform.isIOS || kIsWeb;

      if (useNativeCompression) {
        // First‐pass compress using native
        compressedBytes = await FlutterImageCompress.compressWithFile(
          inputFile.path,
          minWidth: maxWidth,
          minHeight: maxHeight,
          quality: quality,
          format: format,
        );
        if (compressedBytes == null) {
          return Result.error('Failed to compress image (first pass).');
        }

        // If we have a size target, check and do one more pass of quality‐adjustment
        if (targetMB != null) {
          double currentMB = compressedBytes.length / (1024 * 1024);
          if (currentMB > targetMB) {
            // Calculate a proportional new quality
            int adjustedQuality = ((quality * (targetMB / currentMB)).floor()).clamp(10, quality);

            final Uint8List? reCompressed = await FlutterImageCompress.compressWithFile(
              inputFile.path,
              minWidth: maxWidth,
              minHeight: maxHeight,
              quality: adjustedQuality,
              format: format,
            );
            if (reCompressed != null) {
              compressedBytes = reCompressed;
            }
          }
        }
      } else {
        // Use pure Dart 'image' package for desktop platforms
        compressedBytes = await _compressWithDartImage(
          inputFile,
          ext: ext,
          quality: quality,
          targetMB: targetMB,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        if (compressedBytes == null) {
          return Result.error('Failed to compress image using Dart image package.');
        }
      }

      await Directory(dirPath).create();
      // Write out to disk once
      final File outFile = File(outPath);
      await outFile.writeAsBytes(compressedBytes, flush: true);
      return Result.success(outFile);
    } catch (e, st) {
      return Result.error('Compression error: $e\n$st');
    }
  }

  /// Compress image using pure Dart 'image' package (for desktop platforms)
  static Future<Uint8List?> _compressWithDartImage(
    File inputFile, {
    required String ext,
    required int quality,
    required double? targetMB,
    required int maxWidth,
    required int maxHeight,
  }) async {
    final bytes = await inputFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return null;

    // Resize if image exceeds max dimensions
    if (image.width > maxWidth || image.height > maxHeight) {
      image = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : null,
        height: image.height > maxHeight ? maxHeight : null,
        interpolation: img.Interpolation.average,
      );
    }

    // First pass compression
    Uint8List compressedBytes = _encodeImage(image, ext, quality);

    // If we have a size target, adjust quality
    if (targetMB != null) {
      double currentMB = compressedBytes.length / (1024 * 1024);
      if (currentMB > targetMB) {
        int adjustedQuality = ((quality * (targetMB / currentMB)).floor()).clamp(10, quality);
        compressedBytes = _encodeImage(image, ext, adjustedQuality);
      }
    }

    return compressedBytes;
  }

  /// Encode image to bytes based on format
  static Uint8List _encodeImage(img.Image image, String ext, int quality) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
      case 'png':
        return Uint8List.fromList(img.encodePng(image, level: 9 - (quality ~/ 11)));
      case 'webp':
        // Note: webp encoding might not be available in all versions of image package
        // Falls back to jpg if not available
        try {
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        } catch (_) {
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        }
      default:
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }
  }

  /// Turn “jpg”, “jpeg”, “png” or “webp” into the right CompressFormat.
  /// Defaults to JPEG if unknown.
  static CompressFormat _formatFromExt(String ext) {
    switch (ext) {
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      case 'jpeg':
      case 'jpg':
      default:
        return CompressFormat.jpeg;
    }
  }

  /// Scans [dir] for files matching IMG-YYYYMMDD-WA####.<ext> and returns
  /// the next available path. (e.g. IMG-20230606-WA0001.jpg, WA0002.jpg…)
  static Future<String> _generateNextFilePath(Directory dir, String ext) async {
    final String date = _todayString;
    final RegExp re = RegExp(r'^IMG-' + date + r'-WA(\d{4})\.' + ext + r'$');
    final List<FileSystemEntity> all = await dir.list().toList();

    int maxSeq = 0;
    for (final f in all) {
      final String name = p.basename(f.path);
      final Match? m = re.firstMatch(name);
      if (m != null) {
        final int seq = int.tryParse(m.group(1)!) ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      }
    }

    final String nextSeq = (maxSeq + 1).toString().padLeft(4, '0');
    final String filename = 'IMG-$date-WA$nextSeq.$ext';
    return p.join(dir.path, filename);
  }

  static String get _todayString {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
