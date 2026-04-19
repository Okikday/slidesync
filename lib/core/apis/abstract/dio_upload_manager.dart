import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:slidesync/core/apis/abstract/upload_download_base.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/utils/result.dart';

/// Built-in implementation of [UploadManagerBase] using Dio for multipart uploads.
/// Handles multi-link retry strategy with random selection.
class DioUploadManager implements UploadManagerBase {
  static final DioUploadManager _instance = DioUploadManager._();
  factory DioUploadManager() => _instance;
  DioUploadManager._();

  static const _maxFileSize = 200 * 1024 * 1024; // 200MB
  static const _sessionKeyPrefix = 'upload_session_';
  static const _timeout = Duration(seconds: 30);

  final _random = Random();
  final _activeSessions = <String, _UploadSession>{};
  late final Dio _dio = Dio(BaseOptions(connectTimeout: _timeout, receiveTimeout: _timeout, sendTimeout: _timeout));

  @override
  Future<Result<UploadResult?>> uploadFile({
    required File file,
    required List<String> vaultLinks,
    required String operationId,
    OnUploadProgress? onProgress,
    int maxAttempts = 3,
  }) => Result.tryRunAsync(() async {
    final fileSize = await file.length();

    // Validate file size
    if (fileSize > _maxFileSize) {
      final sizeMB = (fileSize / 1024 / 1024).toStringAsFixed(1);
      SyncLogger.error('File exceeds 200MB limit ($sizeMB MB)', '', operation: operationId);
      return null;
    }

    if (vaultLinks.isEmpty) {
      SyncLogger.error('No vault links provided', '', operation: operationId);
      return null;
    }

    SyncLogger.info(
      'Starting upload: ${file.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)',
      operation: operationId,
    );

    // Try to resume previous session
    final existingSession = await _loadSession(operationId);
    if (existingSession != null) {
      SyncLogger.info(
        'Resuming upload from ${existingSession.bytesUploaded}/${existingSession.totalBytes} bytes',
        operation: operationId,
      );
      return await _continueUpload(
        file: file,
        session: existingSession,
        operationId: operationId,
        onProgress: onProgress,
      );
    }

    // New upload: try maxAttempts different random links
    final selectedLinks = _selectRandomLinks(vaultLinks, maxAttempts);

    for (int attempt = 1; attempt <= selectedLinks.length; attempt++) {
      final link = selectedLinks[attempt - 1];

      SyncLogger.info(
        'Attempt $attempt/${selectedLinks.length}: Uploading to ${link.substring(0, 50)}...',
        operation: operationId,
      );

      final result = await _uploadToLink(
        file: file,
        link: link,
        operationId: operationId,
        attempt: attempt,
        onProgress: onProgress,
      );

      if (result != null) {
        SyncLogger.info('Upload successful on attempt $attempt', operation: operationId);
        await _clearSession(operationId);
        return result;
      }

      if (attempt < selectedLinks.length) {
        SyncLogger.warn('Attempt $attempt failed, trying next link', operation: operationId);
      }
    }

    SyncLogger.error('Upload failed after ${selectedLinks.length} attempts', '', operation: operationId);
    return null;
  });

  @override
  Future<Result<UploadResult?>> resumeUpload({required String operationId, OnUploadProgress? onProgress}) =>
      Result.tryRunAsync(() async {
        final session = await _loadSession(operationId);
        if (session == null) {
          SyncLogger.warn('No session found to resume', operation: operationId);
          return null;
        }

        final file = File(session.filePath);
        if (!await file.exists()) {
          SyncLogger.warn('Original file no longer exists', operation: operationId);
          await _clearSession(operationId);
          return null;
        }

        SyncLogger.info('Resuming from ${session.bytesUploaded}/${session.totalBytes} bytes', operation: operationId);

        return await _continueUpload(file: file, session: session, operationId: operationId, onProgress: onProgress);
      });

  @override
  Future<Result<void>> cancelUpload(String operationId) => Result.tryRunAsync(() async {
    _activeSessions.remove(operationId);
    await _clearSession(operationId);
    SyncLogger.info('Upload cancelled', operation: operationId);
  });

  @override
  Future<Result<Map<String, dynamic>?>> getSessionInfo(String operationId) => Result.tryRunAsync(() async {
    final session = await _loadSession(operationId);
    if (session == null) return null;

    return {
      'operationId': operationId,
      'filePath': session.filePath,
      'bytesUploaded': session.bytesUploaded,
      'totalBytes': session.totalBytes,
      'link': session.link,
      'attempt': session.attempt,
      'createdAt': session.createdAt.toIso8601String(),
    };
  });

  @override
  Future<Result<void>> clearSession(String operationId) => Result.tryRunAsync(() => _clearSession(operationId));

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Select [count] random unique links from available links.
  List<String> _selectRandomLinks(List<String> links, int count) {
    final selected = <String>[];
    final remaining = [...links];

    for (int i = 0; i < count && remaining.isNotEmpty; i++) {
      final idx = _random.nextInt(remaining.length);
      selected.add(remaining[idx]);
      remaining.removeAt(idx);
    }

    return selected;
  }

  /// Upload file to a specific link using Dio multipart request.
  Future<UploadResult?> _uploadToLink({
    required File file,
    required String link,
    required String operationId,
    required int attempt,
    OnUploadProgress? onProgress,
  }) async {
    final fileSize = await file.length();
    final fileName = file.path.split('/').last;

    // Create/persist session
    final session = _UploadSession(
      operationId: operationId,
      filePath: file.path,
      link: link,
      attempt: attempt,
      bytesUploaded: 0,
      totalBytes: fileSize,
      createdAt: DateTime.now(),
    );

    _activeSessions[operationId] = session;
    await _saveSession(operationId, session);

    try {
      final fileStream = file.openRead();
      final multipartFile = MultipartFile.fromStream(() => fileStream, fileSize, filename: fileName);

      final formData = FormData.fromMap({'file': multipartFile});

      SyncLogger.uploadProgress(operationId, 0, fileSize, attempt);

      final response = await _dio.post(
        link,
        data: formData,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
          SyncLogger.uploadProgress(operationId, sent, total, attempt);
          session.bytesUploaded = sent;
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        SyncLogger.warn('Upload failed with status ${response.statusCode}', operation: operationId);
        session.bytesUploaded = 0;
        await _saveSession(operationId, session);
        return null;
      }

      onProgress?.call(fileSize, fileSize);
      await _clearSession(operationId);

      return UploadResult(
        success: true,
        storagePath: link,
        bytesTransferred: fileSize,
        totalBytes: fileSize,
        attempts: attempt,
      );
    } on DioException catch (e) {
      SyncLogger.error('Upload to link failed', e, operation: operationId);
      session.bytesUploaded = 0;
      await _saveSession(operationId, session);
      return null;
    } catch (e) {
      SyncLogger.error('Upload to link failed (unknown error)', e, operation: operationId);
      session.bytesUploaded = 0;
      await _saveSession(operationId, session);
      return null;
    }
  }

  /// Continue an interrupted upload session.
  Future<UploadResult?> _continueUpload({
    required File file,
    required _UploadSession session,
    required String operationId,
    OnUploadProgress? onProgress,
  }) async {
    _activeSessions[operationId] = session;

    final result = await _uploadToLink(
      file: file,
      link: session.link,
      operationId: operationId,
      attempt: session.attempt,
      onProgress: onProgress,
    );

    if (result == null) {
      SyncLogger.warn('Resume failed, will retry with new link', operation: operationId);
    }

    return result;
  }

  Future<void> _saveSession(String id, _UploadSession session) =>
      AppHiveData.instance.setData<String>(key: '$_sessionKeyPrefix$id', value: session.toJson());

  Future<_UploadSession?> _loadSession(String id) async {
    final json = await AppHiveData.instance.getData<String>(key: '$_sessionKeyPrefix$id');
    if (json == null) return null;

    try {
      return _UploadSession.fromJson(json);
    } catch (e) {
      SyncLogger.warn('Failed to parse session: $e', operation: id);
      return null;
    }
  }

  Future<void> _clearSession(String id) => AppHiveData.instance.deleteData(key: '$_sessionKeyPrefix$id');
}

/// Internal upload session model.
class _UploadSession {
  final String operationId;
  final String filePath;
  final String link;
  final int attempt;
  int bytesUploaded;
  final int totalBytes;
  final DateTime createdAt;

  _UploadSession({
    required this.operationId,
    required this.filePath,
    required this.link,
    required this.attempt,
    required this.bytesUploaded,
    required this.totalBytes,
    required this.createdAt,
  });

  String toJson() =>
      [operationId, filePath, link, attempt, bytesUploaded, totalBytes, createdAt.toIso8601String()].join('|');

  factory _UploadSession.fromJson(String data) {
    final parts = data.split('|');
    return _UploadSession(
      operationId: parts[0],
      filePath: parts[1],
      link: parts[2],
      attempt: int.parse(parts[3]),
      bytesUploaded: int.parse(parts[4]),
      totalBytes: int.parse(parts[5]),
      createdAt: DateTime.parse(parts[6]),
    );
  }
}
