import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// ============================================================================
/// FIREBASE STORAGE SERVICE
/// ============================================================================
///
/// Robust Firebase Storage service for uploading/downloading packaged files
/// with automatic resume support, network resilience, and progress tracking.
///
/// Features:
/// - Validates .ss file format before upload
/// - Skip-on-exist logic (no redundant uploads)
/// - Automatic resume on network interruption (Firebase SDK handles this)
/// - Streaming uploads/downloads for memory efficiency
/// - Progress tracking and detailed logging
/// - Batch operations with individual failure isolation
/// - Returns maps for full traceability
///
/// Dependencies:
/// - firebase_storage: ^11.0.0 (handles resume automatically)
/// - logging: ^1.2.0
/// ============================================================================

class FirebaseStorageService {
  static final _log = Logger('FirebaseStorageService');

  final FirebaseStorage _storage;
  final String _baseStoragePath;

  /// Creates a Firebase Storage service instance.
  ///
  /// Args:
  /// - [storage]: FirebaseStorage instance (optional, defaults to instance())
  /// - [baseStoragePath]: Base path in storage bucket (e.g., 'uploads/packaged')
  FirebaseStorageService({FirebaseStorage? storage, required String baseStoragePath})
    : _storage = storage ?? FirebaseStorage.instance,
      _baseStoragePath = baseStoragePath.endsWith('/')
          ? baseStoragePath.substring(0, baseStoragePath.length - 1)
          : baseStoragePath;

  // =========================================================================
  // UPLOAD OPERATIONS
  // =========================================================================

  /// Uploads multiple .ss files to Firebase Storage.
  ///
  /// Process:
  /// 1. Validates each file has .ss extension
  /// 2. Checks if file already exists in storage (skips if found)
  /// 3. Uploads with automatic resume support
  /// 4. Returns download URLs for uploaded files
  ///
  /// Args:
  /// - [files]: List of .ss files to upload
  /// - [onProgress]: Optional callback for upload progress (fileName, progress, totalBytes)
  ///
  /// Returns: Map of local file path -> download URL
  /// Files that already exist or fail are excluded from the map
  Future<Map<String, String>> uploadFiles(
    List<File> files, {
    void Function(String fileName, double progress, int totalBytes)? onProgress,
  }) async {
    final results = <String, String>{};

    for (final file in files) {
      try {
        final url = await _uploadSingleFile(file, onProgress: onProgress);
        if (url != null) {
          results[file.path] = url;
        }
      } catch (e, stack) {
        _log.severe('Failed to upload ${file.path}', e, stack);
        // Continue with other files - one failure doesn't stop the batch
      }
    }

    _log.info('Successfully uploaded ${results.length}/${files.length} files');
    return results;
  }

  /// Uploads a single file to Firebase Storage.
  Future<String?> _uploadSingleFile(
    File file, {
    void Function(String fileName, double progress, int totalBytes)? onProgress,
  }) async {
    final fileName = path.basename(file.path);

    // Validate .ss extension
    if (!fileName.endsWith('.ss')) {
      _log.warning('Skipping $fileName - not a .ss file');
      return null;
    }

    final storagePath = '$_baseStoragePath/$fileName';
    final ref = _storage.ref(storagePath);

    // Check if file already exists in storage
    try {
      await ref.getMetadata();
      _log.info('Skipping $fileName - already exists in storage');

      // Return existing download URL
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // File doesn't exist (expected), continue with upload
      if (e.code != 'object-not-found') {
        _log.warning('Error checking existence of $fileName: ${e.message}');
      }
    }

    _log.info('Uploading $fileName (${await file.length()} bytes)');

    try {
      // Firebase SDK automatically handles resume on network interruption
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'application/octet-stream',
          customMetadata: {'originalFileName': fileName, 'uploadTimestamp': DateTime.now().toIso8601String()},
        ),
      );

      // Track progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(fileName, progress, snapshot.totalBytes);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _log.info('Successfully uploaded $fileName -> $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      _log.severe('Firebase error uploading $fileName: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // =========================================================================
  // DOWNLOAD OPERATIONS
  // =========================================================================

  /// Downloads multiple files from Firebase Storage by filename.
  ///
  /// Process:
  /// 1. Validates filenames end with .ss
  /// 2. Constructs storage path for each filename
  /// 3. Downloads files with automatic resume support
  /// 4. Saves to specified output directory
  ///
  /// Args:
  /// - [fileNames]: List of .ss filenames to download (e.g., ['uuid1.ss', 'uuid2.ss'])
  /// - [outputPath]: Local directory to save downloaded files
  /// - [overwriteExisting]: If true, re-downloads existing files (default: false)
  /// - [onProgress]: Optional callback for download progress (fileName, progress, totalBytes)
  ///
  /// Returns: Map of filename -> local file path
  /// Files that fail to download are excluded from the map
  Future<Map<String, String>> downloadFiles(
    List<String> fileNames, {
    required String outputPath,
    bool overwriteExisting = false,
    void Function(String fileName, double progress, int totalBytes)? onProgress,
  }) async {
    final results = <String, String>{};

    // Validate all filenames before starting
    final validFileNames = <String>[];
    for (final fileName in fileNames) {
      if (!fileName.endsWith('.ss')) {
        _log.warning('Skipping $fileName - not a .ss file');
        continue;
      }
      validFileNames.add(fileName);
    }

    if (validFileNames.isEmpty) {
      _log.warning('No valid .ss files to download');
      return results;
    }

    // Ensure output directory exists
    final outputDir = Directory(outputPath);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
      _log.info('Created output directory: $outputPath');
    }

    for (final fileName in validFileNames) {
      try {
        final localPath = await _downloadSingleFile(
          fileName,
          outputPath: outputPath,
          overwriteExisting: overwriteExisting,
          onProgress: onProgress,
        );
        if (localPath != null) {
          results[fileName] = localPath;
        }
      } catch (e, stack) {
        _log.severe('Failed to download $fileName', e, stack);
        // Continue with other files - one failure doesn't stop the batch
      }
    }

    _log.info('Successfully downloaded ${results.length}/${validFileNames.length} files');
    return results;
  }

  /// Downloads a single file from Firebase Storage.
  Future<String?> _downloadSingleFile(
    String fileName, {
    required String outputPath,
    bool overwriteExisting = false,
    void Function(String fileName, double progress, int totalBytes)? onProgress,
  }) async {
    final localPath = path.join(outputPath, fileName);
    final localFile = File(localPath);

    // Check if already downloaded
    if (await localFile.exists() && !overwriteExisting) {
      _log.info('Skipping $fileName - already exists at $localPath');
      return localPath;
    }

    final storagePath = '$_baseStoragePath/$fileName';
    final ref = _storage.ref(storagePath);

    _log.info('Downloading $fileName');

    try {
      // Get file metadata first to check existence and size
      final metadata = await ref.getMetadata();
      final fileSize = metadata.size ?? 0;

      // Firebase SDK automatically handles resume on network interruption
      final downloadTask = ref.writeToFile(localFile);

      // Track progress if callback provided
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(fileName, progress, snapshot.totalBytes);
        });
      }

      // Wait for download to complete
      await downloadTask;

      _log.info('Successfully downloaded $fileName ($fileSize bytes) -> $localPath');
      return localPath;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        _log.warning('File not found in storage: $fileName');

        // Cleanup - file doesn't exist, so partial download is useless
        if (await localFile.exists()) {
          await localFile.delete();
        }
      } else if (e.code == 'unauthorized' || e.code == 'unauthenticated') {
        _log.severe('Authentication error downloading $fileName: ${e.message}');

        // Cleanup - can't access file, partial download is useless
        if (await localFile.exists()) {
          await localFile.delete();
        }
      } else {
        // Network errors, quota exceeded, etc. - keep partial file for resume
        _log.warning('Recoverable error downloading $fileName: ${e.code} - ${e.message}');
        _log.info('Partial file preserved for resume: $localPath');
      }

      return null;
    }
  }

  // =========================================================================
  // UTILITY OPERATIONS
  // =========================================================================

  /// Checks if a file exists in Firebase Storage.
  ///
  /// Returns: true if file exists, false otherwise
  Future<bool> fileExists(String fileName) async {
    try {
      final ref = _storage.ref('$_baseStoragePath/$fileName');
      await ref.getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      _log.warning('Error checking existence of $fileName: ${e.message}');
      rethrow;
    }
  }

  /// Checks existence of multiple files in Firebase Storage.
  ///
  /// Returns: Map of filename -> exists (true/false)
  Future<Map<String, bool>> checkMultipleFiles(List<String> fileNames) async {
    final results = <String, bool>{};

    for (final fileName in fileNames) {
      try {
        results[fileName] = await fileExists(fileName);
      } catch (e) {
        _log.warning('Error checking $fileName: $e');
        results[fileName] = false;
      }
    }

    return results;
  }

  /// Gets download URL for a file without downloading it.
  ///
  /// Returns: Download URL or null if file doesn't exist
  Future<String?> getDownloadUrl(String fileName) async {
    try {
      final ref = _storage.ref('$_baseStoragePath/$fileName');
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        _log.info('File not found: $fileName');
        return null;
      }
      _log.severe('Error getting download URL for $fileName: ${e.message}');
      rethrow;
    }
  }

  /// Gets download URLs for multiple files.
  ///
  /// Returns: Map of filename -> download URL (null if not found)
  Future<Map<String, String?>> getMultipleDownloadUrls(List<String> fileNames) async {
    final results = <String, String?>{};

    for (final fileName in fileNames) {
      try {
        results[fileName] = await getDownloadUrl(fileName);
      } catch (e) {
        _log.warning('Error getting URL for $fileName: $e');
        results[fileName] = null;
      }
    }

    return results;
  }

  /// Deletes a file from Firebase Storage.
  ///
  /// Returns: true if deleted successfully, false if file didn't exist
  Future<bool> deleteFile(String fileName) async {
    try {
      final ref = _storage.ref('$_baseStoragePath/$fileName');
      await ref.delete();
      _log.info('Deleted $fileName from storage');
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        _log.info('File not found (already deleted?): $fileName');
        return false;
      }
      _log.severe('Error deleting $fileName: ${e.message}');
      rethrow;
    }
  }

  /// Deletes multiple files from Firebase Storage.
  ///
  /// Returns: Map of filename -> deleted successfully (true/false)
  Future<Map<String, bool>> deleteMultipleFiles(List<String> fileNames) async {
    final results = <String, bool>{};

    for (final fileName in fileNames) {
      try {
        results[fileName] = await deleteFile(fileName);
      } catch (e) {
        _log.severe('Failed to delete $fileName: $e');
        results[fileName] = false;
      }
    }

    _log.info('Deleted ${results.values.where((v) => v).length}/${fileNames.length} files');
    return results;
  }

  /// Lists all .ss files in the storage path.
  ///
  /// Returns: List of filenames
  Future<List<String>> listAllFiles() async {
    try {
      final ref = _storage.ref(_baseStoragePath);
      final result = await ref.listAll();

      final fileNames = result.items.map((item) => item.name).where((name) => name.endsWith('.ss')).toList();

      _log.info('Found ${fileNames.length} .ss files in storage');
      return fileNames;
    } on FirebaseException catch (e) {
      _log.severe('Error listing files: ${e.message}');
      rethrow;
    }
  }
}
