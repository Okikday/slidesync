import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/core/utils/smart_isolate.dart';

/// Service class for finding and matching files by size and hash in an isolate.
///
/// All heavy operations (file scanning, size filtering, hash calculation) are
/// performed in a background isolate to prevent UI blocking.
class FileMatcher {
  /// Finds files matching the provided hashes by first filtering by file size,
  /// then verifying with hash calculation. All heavy operations run in an isolate.
  ///
  /// **Parameters:**
  /// - [hashToSize]: Map of hash strings to their corresponding file sizes in bytes.
  ///   Can be null or empty, in which case an empty map is returned.
  /// - [directoryPath]: Optional directory path to search in. If provided and accessible,
  ///   this directory will be used. If not accessible or null, user will be prompted
  ///   to select a directory.
  ///
  /// **Returns:**
  /// A [Map<String, String>] where keys are hashes and values are the file paths
  /// of matching files. Only the first matching file for each hash is included.
  ///
  /// **Process:**
  /// 1. Uses provided directory or prompts user to select one
  /// 2. Spawns isolate to perform heavy operations:
  ///    - Recursively scans directory for files matching any of the provided sizes
  ///    - Groups candidate files by their size
  ///    - For each hash, calculates hash of size-matched files until match is found
  /// 3. Returns map of successfully matched hashes to file paths
  ///
  /// **Error Handling:**
  /// - Individual file read/hash errors are logged but don't stop the overall process
  /// - Directory access errors cause fallback to user selection
  /// - User cancellation returns an empty map
  /// - Isolate errors are properly caught and reported
  ///
  /// **Performance:**
  /// - All I/O and hash calculations run in background isolate
  /// - Pre-filters by file size to avoid unnecessary hash calculations
  /// - Stops hashing files for a given hash once a match is found
  ///
  /// **Example:**
  /// ```dart
  /// final hashToSize = {
  ///   'abc123': 1024,
  ///   'def456': 2048,
  /// };
  ///
  /// // With user selection
  /// final matches = await FileMatcher.findFilesByHashAndSize(hashToSize);
  ///
  /// // With provided path
  /// final matches2 = await FileMatcher.findFilesByHashAndSize(
  ///   hashToSize,
  ///   directoryPath: '/path/to/search',
  /// );
  /// ```
  static Future<Map<String, String>> findFilesByHashAndSize(
    Map<String, int>? hashToSize, {
    String? directoryPath,
  }) async {
    // Return early if no hashes provided
    if (hashToSize == null || hashToSize.isEmpty) {
      log('No hashes provided to search for');
      return {};
    }

    // Step 1: Determine directory to search
    String? selectedDirectory = directoryPath;

    // Check if provided directory is accessible
    if (selectedDirectory != null) {
      final hasAccess = await _checkDirectoryAccess(selectedDirectory);
      if (!hasAccess) {
        log('No access to provided directory: $selectedDirectory');
        log('Falling back to user selection...');
        selectedDirectory = null;
      }
    }

    // Prompt user if no valid directory
    if (selectedDirectory == null) {
      selectedDirectory = await _selectDirectory();
      if (selectedDirectory == null) {
        log('No directory selected by user');
        return {};
      }
    }

    log('Searching in directory: $selectedDirectory');
    log('Looking for ${hashToSize.length} file(s)');

    // Step 2: Run heavy operations in isolate
    try {
      final result = await SmartIsolate.run<_IsolateTask, _IsolateProgress, Map<String, String>>(
        _isolateEntryPoint,
        _IsolateTask(directoryPath: selectedDirectory, hashToSize: hashToSize),
        onProgress: (progress) {
          // Log progress from isolate
          if (progress.message != null) {
            log("${progress.message}");
          }
        },
      );

      log('Search complete: ${result.length}/${hashToSize.length} files matched');
      return result;
    } catch (e, stackTrace) {
      log('Error during file search: $e');
      log('StackTrace: $stackTrace');
      return {};
    }
  }

  /// Checks if the app has access to read the given directory.
  ///
  /// **Parameters:**
  /// - [path]: Directory path to check
  ///
  /// **Returns:**
  /// True if directory exists and is accessible, false otherwise.
  static Future<bool> _checkDirectoryAccess(String path) async {
    try {
      final directory = Directory(path);
      final exists = await directory.exists();
      if (!exists) return false;

      // Try to list directory to verify read access
      await directory.list(followLinks: false).take(1).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Prompts the user to select a directory using the system file picker.
  ///
  /// **Returns:**
  /// The selected directory path as a [String], or null if cancelled.
  static Future<String?> _selectDirectory() async {
    try {
      final String? path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select folder to search for files');
      return path;
    } catch (e) {
      log('Error selecting directory: $e');
      return null;
    }
  }

  /// Isolate entry point that performs all heavy file operations.
  ///
  /// This function runs in a background isolate and performs:
  /// 1. File scanning by size
  /// 2. Hash calculation for candidates
  /// 3. Matching hashes to file paths
  ///
  /// **Parameters:**
  /// - [task]: Contains directory path and hash-to-size mappings
  /// - [emitProgress]: Callback to report progress to main isolate
  ///
  /// **Returns:**
  /// Map of matched hashes to file paths
  static Future<Map<String, String>> _isolateEntryPoint(
    _IsolateTask task,
    void Function(_IsolateProgress) emitProgress,
  ) async {
    // Extract unique file sizes we're looking for
    final Set<int> targetSizes = task.hashToSize.values.toSet();
    emitProgress(_IsolateProgress(message: 'Target file sizes: $targetSizes'));

    // Find all files matching the target sizes
    final Map<int, List<String>> sizeToFilePaths = await _findFilesBySize(
      task.directoryPath,
      targetSizes,
      emitProgress,
    );

    // Log statistics
    int totalCandidates = 0;
    sizeToFilePaths.forEach((size, paths) {
      totalCandidates += paths.length;
      emitProgress(_IsolateProgress(message: 'Found ${paths.length} file(s) with size $size bytes'));
    });
    emitProgress(_IsolateProgress(message: 'Total candidate files: $totalCandidates'));

    // For each hash, find the first file that matches
    final Map<String, String> hashToFilePath = {};

    for (final entry in task.hashToSize.entries) {
      final String targetHash = entry.key;
      final int fileSize = entry.value;

      // Get candidate files with matching size
      final List<String>? candidateFiles = sizeToFilePaths[fileSize];

      if (candidateFiles == null || candidateFiles.isEmpty) {
        emitProgress(_IsolateProgress(message: 'No files found with size $fileSize for hash $targetHash'));
        continue;
      }

      emitProgress(_IsolateProgress(message: 'Checking ${candidateFiles.length} candidate(s) for hash $targetHash'));

      // Calculate hash for each candidate until we find a match
      bool foundMatch = false;
      for (final filePath in candidateFiles) {
        try {
          final String calculatedHash = await CryptoUtils.calculateFileHashXXH3(filePath);

          if (calculatedHash == targetHash) {
            hashToFilePath[targetHash] = filePath;
            emitProgress(_IsolateProgress(message: '✓ Match found for $targetHash: $filePath'));
            foundMatch = true;
            break; // Stop checking other files for this hash
          }
        } catch (e) {
          // Log error but continue with other candidates
          emitProgress(_IsolateProgress(message: 'Error calculating hash for $filePath: $e'));
        }
      }

      if (!foundMatch) {
        emitProgress(_IsolateProgress(message: '✗ No match found for hash $targetHash'));
      }
    }

    return hashToFilePath;
  }

  /// Recursively finds all files in a directory that match any of the target sizes.
  ///
  /// **Parameters:**
  /// - [directoryPath]: Root directory to search in
  /// - [targetSizes]: Set of file sizes (in bytes) to look for
  /// - [emitProgress]: Callback to report progress
  ///
  /// **Returns:**
  /// A [Map<int, List<String>>] where keys are file sizes and values are lists
  /// of file paths that have that size.
  ///
  /// **Error Handling:**
  /// Individual file/directory errors are logged but don't stop the scan.
  static Future<Map<int, List<String>>> _findFilesBySize(
    String directoryPath,
    Set<int> targetSizes,
    void Function(_IsolateProgress) emitProgress,
  ) async {
    final Map<int, List<String>> sizeToFilePaths = {};

    // Initialize lists for each target size
    for (final size in targetSizes) {
      sizeToFilePaths[size] = [];
    }

    try {
      final directory = Directory(directoryPath);

      // Recursively scan directory
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        // Only process files, skip directories and links
        if (entity is File) {
          try {
            final int fileSize = await entity.length();

            // If this file size matches one we're looking for, add it
            if (targetSizes.contains(fileSize)) {
              sizeToFilePaths[fileSize]!.add(entity.path);
            }
          } catch (e) {
            // Log error but continue scanning other files
            emitProgress(_IsolateProgress(message: 'Error reading file ${entity.path}: $e'));
          }
        }
      }
    } catch (e) {
      emitProgress(_IsolateProgress(message: 'Error scanning directory $directoryPath: $e'));
    }

    return sizeToFilePaths;
  }
}

/// Task data passed to the isolate.
class _IsolateTask {
  final String directoryPath;
  final Map<String, int> hashToSize;

  _IsolateTask({required this.directoryPath, required this.hashToSize});
}

/// Progress data emitted from the isolate.
class _IsolateProgress {
  final String? message;

  _IsolateProgress({this.message});
}
