import 'dart:io';
import 'dart:developer' as dev;
import 'package:slidesync/core/utils/result.dart';

/// Progress callback for upload operations.
typedef OnUploadProgress = void Function(int bytesTransferred, int totalBytes);

/// Upload result with tracking info.
class UploadResult {
  final bool success;
  final String? storagePath;
  final String? error;
  final int bytesTransferred;
  final int totalBytes;
  final int attempts;

  const UploadResult({
    required this.success,
    this.storagePath,
    this.error,
    this.bytesTransferred = 0,
    required this.totalBytes,
    required this.attempts,
  });

  @override
  String toString() =>
      'UploadResult(success: $success, path: $storagePath, '
      'bytes: $bytesTransferred/$totalBytes, attempts: $attempts)';
}

/// Reliable upload manager for files to remote storage (Google Drive folder links).
/// Handles:
/// - Resumable uploads across app kills (via operation IDs)
/// - Automatic retry with 3 random link attempts
/// - 200MB file size limit
/// - Progress tracking and logging
abstract class UploadManagerBase {
  /// Upload [file] to storage vault.
  ///
  /// Parameters:
  /// - [file]: File to upload (max 200MB)
  /// - [vaultLinks]: List of available storage links to try (min 1)
  /// - [operationId]: Unique ID for resume support
  /// - [onProgress]: Optional callback for progress updates
  /// - [maxAttempts]: Number of different links to try (default: 3)
  ///
  /// Returns [UploadResult] with success status and storage path, or null on failure.
  Future<Result<UploadResult?>> uploadFile({
    required File file,
    required List<String> vaultLinks,
    required String operationId,
    OnUploadProgress? onProgress,
    int maxAttempts = 3,
  });

  /// Resume a previously interrupted upload.
  ///
  /// Returns null if no session exists for [operationId].
  Future<Result<UploadResult?>> resumeUpload({required String operationId, OnUploadProgress? onProgress});

  /// Cancel an ongoing upload operation.
  Future<Result<void>> cancelUpload(String operationId);

  /// Get upload session info (for debugging).
  Future<Result<Map<String, dynamic>?>> getSessionInfo(String operationId);

  /// Clear completed upload session.
  Future<Result<void>> clearSession(String operationId);
}

/// Manages download operations with resumable capability across app kills.
/// Handles:
/// - Resumable downloads via Range headers
/// - Session persistence (stores offset, total size, etc.)
/// - Progress tracking
/// - Automatic cleanup on completion
abstract class DownloadManagerBase {
  /// Download from [remoteUrl] to [destPath].
  ///
  /// Parameters:
  /// - [remoteUrl]: HTTP(S) URL to download from
  /// - [destPath]: Local file path to save to
  /// - [operationId]: Unique ID for resume support
  /// - [onProgress]: Optional callback for progress updates
  /// - [knownSize]: Optional hint for total file size
  ///
  /// Returns [DownloadResult] with success status and local path, or null on failure.
  /// Automatically resumes if interrupted.
  Future<Result<DownloadResult?>> downloadFile({
    required String remoteUrl,
    required String destPath,
    required String operationId,
    OnDownloadProgress? onProgress,
    int? knownSize,
  });

  /// Resume a previously interrupted download.
  ///
  /// Returns null if no session exists for [operationId].
  Future<Result<DownloadResult?>> resumeDownload({required String operationId, OnDownloadProgress? onProgress});

  /// Cancel an ongoing download operation.
  Future<Result<void>> cancelDownload(String operationId);

  /// Get download session info (for debugging).
  Future<Result<Map<String, dynamic>?>> getSessionInfo(String operationId);

  /// Clear completed download session.
  Future<Result<void>> clearSession(String operationId);
}

/// Progress callback for download operations.
typedef OnDownloadProgress = void Function(int bytesReceived, int totalBytes);

/// Download result with tracking info.
class DownloadResult {
  final bool success;
  final String? localPath;
  final String? error;
  final int bytesReceived;
  final int totalBytes;

  const DownloadResult({
    required this.success,
    this.localPath,
    this.error,
    this.bytesReceived = 0,
    required this.totalBytes,
  });

  @override
  String toString() =>
      'DownloadResult(success: $success, path: $localPath, '
      'bytes: $bytesReceived/$totalBytes)';
}

/// Logging utility for upload/download operations.
/// Helps track bugs and issues.
class SyncLogger {
  static final SyncLogger _instance = SyncLogger._();
  factory SyncLogger() => _instance;
  SyncLogger._();

  static const _tag = '🔄 SyncManager';

  /// Log info-level message.
  static void info(String message, {String? operation}) {
    final prefix = operation != null ? '[$operation]' : '';
    dev.log('$prefix $message', name: _tag);
  }

  /// Log warning-level message.
  static void warn(String message, {String? operation}) {
    final prefix = operation != null ? '[$operation]' : '';
    dev.log('⚠️ $prefix $message', name: _tag);
  }

  /// Log error-level message.
  static void error(String message, dynamic error, {String? operation}) {
    final prefix = operation != null ? '[$operation]' : '';
    dev.log('❌ $prefix $message\nError: $error', name: _tag);
  }

  /// Log upload progress.
  static void uploadProgress(String operationId, int bytes, int total, int attempt) {
    final percent = ((bytes / total) * 100).toStringAsFixed(1);
    dev.log('[Upload] $operationId - $bytes/$total bytes ($percent%) - Attempt $attempt', name: _tag);
  }

  /// Log download progress.
  static void downloadProgress(String operationId, int bytes, int total) {
    final percent = ((bytes / total) * 100).toStringAsFixed(1);
    dev.log('[Download] $operationId - $bytes/$total bytes ($percent%)', name: _tag);
  }
}
