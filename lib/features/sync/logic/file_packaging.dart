import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:es_compression/zstd.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

/// ============================================================================
/// STREAMING FILE COMPRESSION PACKAGE MANAGER
/// ============================================================================
///
/// A robust file packaging system using Zstandard compression with metadata
/// headers. Supports streaming operations, resume capability, and efficient
/// memory usage for files of any size.
///
/// Custom file format (.ss):
/// - [4 bytes: metadata_length (uint32 big-endian)]
/// - [N bytes: metadata JSON (UTF-8)]
/// - [remaining: Zstd compressed file data]
///
/// Features:
/// - Stream-based compression/decompression (constant memory usage)
/// - Resume support (skips complete files, detects incomplete)
/// - UUID-based file naming with original filename preservation
/// - Configurable output paths and overwrite behavior
/// ============================================================================

class FilePackageManager {
  static final _log = Logger('FilePackageManager');
  static const _uuid = Uuid();

  /// File extensions
  static const String finishedExtension = '.ss';
  static const String tempExtension = '.ss.tmp';

  /// Metadata header size (4 bytes for uint32 length)
  static const int headerSize = 4;

  // =========================================================================
  // COMPRESSION / PACKAGING
  // =========================================================================

  /// Packages multiple files for upload with compression and metadata.
  ///
  /// Each file is compressed with a metadata header containing:
  /// - originalName: The source filename
  /// - originalSize: Uncompressed file size in bytes
  /// - timestamp: ISO 8601 compression timestamp
  /// - uuid: Unique identifier for this package
  ///
  /// Args:
  /// - [files]: List of files to compress and package
  /// - [outputPath]: Directory to store compressed files (optional)
  /// - [overwriteExisting]: If true, recompresses existing files (default: false)
  ///
  /// Returns: Map of original file path -> packaged file path
  /// Failed files are excluded from the map
  static Future<Map<String, String>> packageFiles(
    List<File> files, {
    String? outputPath,
    bool overwriteExisting = false,
  }) async {
    final results = <String, String>{};

    for (final file in files) {
      try {
        final path = await _packageSingleFile(file, outputPath: outputPath, overwriteExisting: overwriteExisting);
        if (path != null) {
          results[file.path] = path;
        }
      } catch (e, stack) {
        _log.severe('Failed to package ${file.path}', e, stack);
        // Continue processing other files - one failure doesn't stop the rest
      }
    }

    _log.info('Successfully packaged ${results.length}/${files.length} files');
    return results;
  }

  /// Packages a single file with compression and metadata header.
  static Future<String?> _packageSingleFile(File file, {String? outputPath, bool overwriteExisting = false}) async {
    final fileName = file.uri.pathSegments.last;
    final uuid = _uuid.v4();
    final outputDir = outputPath ?? operationsCacheFolder;

    final finalPath = '$outputDir/$uuid$finishedExtension';
    final tempPath = '$outputDir/$uuid$tempExtension';

    // Check if already exists and complete
    final finalFile = File(finalPath);
    if (await finalFile.exists() && !overwriteExisting) {
      _log.info('Skipping $fileName - already packaged at $finalPath');
      return finalPath;
    }

    // Clean up any incomplete temp file
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      _log.info('Removing incomplete temp file: $tempPath');
      await tempFile.delete();
    }

    _log.info('Packaging $fileName -> $uuid$finishedExtension');

    try {
      // Prepare metadata
      final metadata = {
        'originalName': fileName,
        'originalSize': await file.length(),
        'timestamp': DateTime.now().toIso8601String(),
        'uuid': uuid,
      };

      final metadataBytes = utf8.encode(jsonEncode(metadata));
      final metadataLength = ByteData(headerSize)..setUint32(0, metadataBytes.length, Endian.big);

      // Write to temp file first (atomicity)
      final output = tempFile.openWrite();

      try {
        // Write metadata header
        output.add(metadataLength.buffer.asUint8List());
        output.add(metadataBytes);

        // Stream compress and write file data
        await file.openRead().transform(ZstdEncoder(level: 3)).pipe(output);
      } finally {
        await output.close();
      }

      // Move temp to final (atomic rename)
      await tempFile.rename(finalPath);

      _log.info('Successfully packaged $fileName (${await finalFile.length()} bytes)');
      return finalPath;
    } catch (e, stack) {
      _log.severe('Error packaging $fileName', e, stack);

      // Cleanup on failure
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      rethrow;
    }
  }

  // =========================================================================
  // DECOMPRESSION / UNPACKING
  // =========================================================================

  /// Unpacks multiple compressed files to specified directory.
  ///
  /// Args:
  /// - [packagedFiles]: List of .ss files to decompress
  /// - [outputPath]: Directory to extract files to (optional)
  /// - [overwriteExisting]: If true, overwrites existing files (default: false)
  ///
  /// Returns: List of paths to successfully unpacked files
  static Future<List<String>> unpackFiles(
    List<File> packagedFiles, {
    String? outputPath,
    bool overwriteExisting = false,
  }) async {
    final unpackedPaths = <String>[];

    for (final file in packagedFiles) {
      try {
        final path = await unpackFile(file, outputPath: outputPath, overwriteExisting: overwriteExisting);
        if (path != null) {
          unpackedPaths.add(path);
        }
      } catch (e, stack) {
        _log.severe('Failed to unpack ${file.path}', e, stack);
      }
    }

    return unpackedPaths;
  }

  /// Unpacks a single compressed file to its original filename.
  ///
  /// Reads metadata header to get original filename, then streams
  /// decompression to output file.
  static Future<String?> unpackFile(File packagedFile, {String? outputPath, bool overwriteExisting = false}) async {
    _log.info('Unpacking ${packagedFile.path}');

    try {
      // Read metadata
      final metadata = await readMetadata(packagedFile);
      final originalName = metadata['originalName'] as String;
      final outputDir = outputPath ?? operationsCacheFolder;

      final finalPath = '$outputDir/$originalName';
      final tempPath = '$finalPath.tmp';

      // Check if already unpacked
      final finalFile = File(finalPath);
      if (await finalFile.exists() && !overwriteExisting) {
        _log.info('Skipping $originalName - already exists at $finalPath');
        return finalPath;
      }

      // Clean up any incomplete temp file
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        _log.info('Removing incomplete temp file: $tempPath');
        await tempFile.delete();
      }

      // Get data offset (skip metadata header)
      final dataOffset = await _getDataOffset(packagedFile);

      // Stream decompress to temp file
      final output = tempFile.openWrite();

      try {
        await packagedFile.openRead(dataOffset).transform(ZstdDecoder()).pipe(output);
      } finally {
        await output.close();
      }

      // Move temp to final (atomic rename)
      await tempFile.rename(finalPath);

      _log.info('Successfully unpacked $originalName (${await finalFile.length()} bytes)');
      return finalPath;
    } catch (e, stack) {
      _log.severe('Error unpacking ${packagedFile.path}', e, stack);
      rethrow;
    }
  }

  // =========================================================================
  // METADATA UTILITIES
  // =========================================================================

  /// Reads metadata from a packaged file without decompressing.
  ///
  /// Efficiently reads only the header section to extract metadata JSON.
  ///
  /// Returns: Map containing metadata fields (originalName, originalSize, etc.)
  static Future<Map<String, dynamic>> readMetadata(File packagedFile) async {
    try {
      // Read metadata length (first 4 bytes)
      final lengthBytes = await packagedFile.openRead(0, headerSize).first;
      final metadataLength = ByteData.sublistView(Uint8List.fromList(lengthBytes)).getUint32(0, Endian.big);

      // Read metadata JSON
      final metadataBytes = await packagedFile.openRead(headerSize, headerSize + metadataLength).first;

      final metadata = jsonDecode(utf8.decode(metadataBytes)) as Map<String, dynamic>;
      return metadata;
    } catch (e, stack) {
      _log.severe('Failed to read metadata from ${packagedFile.path}', e, stack);
      rethrow;
    }
  }

  /// Reads metadata from multiple packaged files.
  ///
  /// Returns: List of metadata maps, one per file
  static Future<List<Map<String, dynamic>>> readMultipleMetadata(List<File> packagedFiles) async {
    final metadataList = <Map<String, dynamic>>[];

    for (final file in packagedFiles) {
      try {
        final metadata = await readMetadata(file);
        metadataList.add(metadata);
      } catch (e) {
        _log.warning('Skipping metadata read for ${file.path}: $e');
      }
    }

    return metadataList;
  }

  /// Gets the byte offset where compressed data starts (after metadata header).
  static Future<int> _getDataOffset(File packagedFile) async {
    final lengthBytes = await packagedFile.openRead(0, headerSize).first;
    final metadataLength = ByteData.sublistView(Uint8List.fromList(lengthBytes)).getUint32(0, Endian.big);

    return headerSize + metadataLength;
  }

  // =========================================================================
  // VALIDATION UTILITIES
  // =========================================================================

  /// Validates that a packaged file is complete and not corrupted.
  ///
  /// Checks:
  /// - File has valid extension
  /// - Metadata can be read
  /// - File size is reasonable
  ///
  /// Returns: true if file appears valid, false otherwise
  static Future<bool> validatePackagedFile(File packagedFile) async {
    try {
      // Check extension
      if (!packagedFile.path.endsWith(finishedExtension)) {
        _log.warning('Invalid extension: ${packagedFile.path}');
        return false;
      }

      // Check file exists and has content
      if (!await packagedFile.exists()) {
        _log.warning('File does not exist: ${packagedFile.path}');
        return false;
      }

      final fileSize = await packagedFile.length();
      if (fileSize < headerSize + 2) {
        // At least header + minimal metadata
        _log.warning('File too small: ${packagedFile.path} ($fileSize bytes)');
        return false;
      }

      // Try to read metadata
      await readMetadata(packagedFile);

      return true;
    } catch (e) {
      _log.warning('Validation failed for ${packagedFile.path}: $e');
      return false;
    }
  }

  /// Validates multiple packaged files.
  ///
  /// Returns: Map of file path to validation result
  static Future<Map<String, bool>> validateMultipleFiles(List<File> packagedFiles) async {
    final results = <String, bool>{};

    for (final file in packagedFiles) {
      results[file.path] = await validatePackagedFile(file);
    }

    return results;
  }

  // =========================================================================
  // CLEANUP UTILITIES
  // =========================================================================

  /// Removes incomplete temporary files from a directory.
  ///
  /// Cleans up .ss.tmp files that may have been left from interrupted operations.
  static Future<int> cleanupTempFiles(String directoryPath) async {
    int cleaned = 0;

    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        return 0;
      }

      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith(tempExtension)) {
          _log.info('Removing temp file: ${entity.path}');
          await entity.delete();
          cleaned++;
        }
      }

      _log.info('Cleaned up $cleaned temp files from $directoryPath');
    } catch (e, stack) {
      _log.severe('Error during temp file cleanup', e, stack);
    }

    return cleaned;
  }

  static String get operationsCacheFolder => '/tmp/cache';
}
