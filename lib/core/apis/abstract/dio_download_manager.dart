import 'dart:io';
import 'package:dio/dio.dart';
import 'package:slidesync/core/apis/abstract/upload_download_base.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/utils/result.dart';

/// Built-in implementation of [DownloadManagerBase] using Dio with Range header support.
/// Supports resumable downloads across app kills.
class DioDownloadManager implements DownloadManagerBase {
  static final DioDownloadManager _instance = DioDownloadManager._();
  factory DioDownloadManager() => _instance;
  DioDownloadManager._();

  static const _sessionKeyPrefix = 'download_session_';
  static const _timeout = Duration(seconds: 30);

  final _activeSessions = <String, _DownloadSession>{};
  late final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  @override
  Future<Result<DownloadResult?>> downloadFile({
    required String remoteUrl,
    required String destPath,
    required String operationId,
    OnDownloadProgress? onProgress,
    int? knownSize,
  }) => Result.tryRunAsync(() async {
    if (remoteUrl.isEmpty) {
      SyncLogger.error('URL cannot be empty', '', operation: operationId);
      return null;
    }

    SyncLogger.info('Starting download: $remoteUrl → $destPath', operation: operationId);

    // Resolve total size
    int? totalBytes = knownSize;
    totalBytes ??= await _fetchFileSize(remoteUrl);

    if (totalBytes == null || totalBytes <= 0) {
      SyncLogger.error('Could not determine file size from $remoteUrl', '', operation: operationId);
      return null;
    }

    // Check for partial download
    final destFile = File(destPath);
    await destFile.parent.create(recursive: true);

    int startByte = 0;
    if (await destFile.exists()) {
      final existingSize = await destFile.length();
      if (existingSize >= totalBytes) {
        SyncLogger.info('Download already complete', operation: operationId);
        return DownloadResult(success: true, localPath: destPath, bytesReceived: totalBytes, totalBytes: totalBytes);
      }
      startByte = existingSize;
    }

    // Create session
    final session = _DownloadSession(
      operationId: operationId,
      remoteUrl: remoteUrl,
      destPath: destPath,
      bytesReceived: startByte,
      totalBytes: totalBytes,
      createdAt: DateTime.now(),
    );

    _activeSessions[operationId] = session;
    await _saveSession(operationId, session);

    return await _performDownload(session: session, operationId: operationId, onProgress: onProgress);
  });

  @override
  Future<Result<DownloadResult?>> resumeDownload({required String operationId, OnDownloadProgress? onProgress}) =>
      Result.tryRunAsync(() async {
        final session = await _loadSession(operationId);
        if (session == null) {
          SyncLogger.warn('No session found to resume', operation: operationId);
          return null;
        }

        final destFile = File(session.destPath);
        if (!await destFile.exists()) {
          SyncLogger.warn('Partially downloaded file no longer exists', operation: operationId);
          await _clearSession(operationId);
          return null;
        }

        _activeSessions[operationId] = session;

        SyncLogger.info('Resuming from ${session.bytesReceived}/${session.totalBytes} bytes', operation: operationId);

        return await _performDownload(session: session, operationId: operationId, onProgress: onProgress);
      });

  @override
  Future<Result<void>> cancelDownload(String operationId) => Result.tryRunAsync(() async {
    _activeSessions.remove(operationId);
    await _clearSession(operationId);
    SyncLogger.info('Download cancelled', operation: operationId);
  });

  @override
  Future<Result<Map<String, dynamic>?>> getSessionInfo(String operationId) => Result.tryRunAsync(() async {
    final session = await _loadSession(operationId);
    if (session == null) return null;

    return {
      'operationId': operationId,
      'remoteUrl': session.remoteUrl,
      'destPath': session.destPath,
      'bytesReceived': session.bytesReceived,
      'totalBytes': session.totalBytes,
      'createdAt': session.createdAt.toIso8601String(),
    };
  });

  @override
  Future<Result<void>> clearSession(String operationId) => Result.tryRunAsync(() => _clearSession(operationId));

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Fetch file size from HEAD request or Range header.
  Future<int?> _fetchFileSize(String remoteUrl) async {
    try {
      // Try HEAD first
      final headResponse = await _dio.head(remoteUrl);
      final contentLength = headResponse.headers.value('content-length');
      if (contentLength != null) {
        return int.tryParse(contentLength);
      }

      // Fallback: GET with Range header to get size
      final rangeResponse = await _dio.get(remoteUrl, options: Options(headers: {'Range': 'bytes=0-0'}));

      final contentRange = rangeResponse.headers.value('content-range');
      if (contentRange != null) {
        // Format: "bytes 0-0/total"
        final parts = contentRange.split('/');
        if (parts.length == 2) {
          return int.tryParse(parts[1]);
        }
      }

      return null;
    } catch (e) {
      SyncLogger.warn('Failed to fetch file size: $e');
      return null;
    }
  }

  /// Perform the actual download with resumable support.
  Future<DownloadResult?> _performDownload({
    required _DownloadSession session,
    required String operationId,
    OnDownloadProgress? onProgress,
  }) async {
    try {
      final destFile = File(session.destPath);
      final sink = destFile.openWrite(mode: FileMode.append);

      SyncLogger.downloadProgress(operationId, session.bytesReceived, session.totalBytes);

      final response = await _dio.get(
        session.remoteUrl,
        options: Options(
          headers: {'Range': 'bytes=${session.bytesReceived}-${session.totalBytes - 1}'},
          responseType: ResponseType.stream,
        ),
        onReceiveProgress: (received, total) {
          final totalReceived = session.bytesReceived + received;
          onProgress?.call(totalReceived, session.totalBytes);
          SyncLogger.downloadProgress(operationId, totalReceived, session.totalBytes);
          session.bytesReceived = totalReceived;
        },
      );

      if (response.statusCode != 206 && response.statusCode != 200) {
        SyncLogger.warn('Download failed with status ${response.statusCode}', operation: operationId);
        await sink.close();
        return null;
      }

      // Write response stream to file
      await response.data.stream.pipe(sink);
      await sink.close();

      final finalSize = await destFile.length();
      if (finalSize < session.totalBytes) {
        SyncLogger.warn('Downloaded file incomplete: $finalSize/${session.totalBytes} bytes', operation: operationId);
        return null;
      }

      onProgress?.call(session.totalBytes, session.totalBytes);
      await _clearSession(operationId);

      return DownloadResult(
        success: true,
        localPath: session.destPath,
        bytesReceived: finalSize,
        totalBytes: session.totalBytes,
      );
    } on DioException catch (e) {
      SyncLogger.error('Download failed', e, operation: operationId);
      await _saveSession(operationId, session);
      return null;
    } catch (e) {
      SyncLogger.error('Download failed (unknown error)', e, operation: operationId);
      await _saveSession(operationId, session);
      return null;
    }
  }

  Future<void> _saveSession(String id, _DownloadSession session) =>
      AppHiveData.instance.setData<String>(key: '$_sessionKeyPrefix$id', value: session.toJson());

  Future<_DownloadSession?> _loadSession(String id) async {
    final json = await AppHiveData.instance.getData<String>(key: '$_sessionKeyPrefix$id');
    if (json == null) return null;

    try {
      return _DownloadSession.fromJson(json);
    } catch (e) {
      SyncLogger.warn('Failed to parse session: $e', operation: id);
      return null;
    }
  }

  Future<void> _clearSession(String id) => AppHiveData.instance.deleteData(key: '$_sessionKeyPrefix$id');
}

/// Internal download session model.
class _DownloadSession {
  final String operationId;
  final String remoteUrl;
  final String destPath;
  int bytesReceived;
  final int totalBytes;
  final DateTime createdAt;

  _DownloadSession({
    required this.operationId,
    required this.remoteUrl,
    required this.destPath,
    required this.bytesReceived,
    required this.totalBytes,
    required this.createdAt,
  });

  String toJson() =>
      [operationId, remoteUrl, destPath, bytesReceived, totalBytes, createdAt.toIso8601String()].join('|');

  factory _DownloadSession.fromJson(String data) {
    final parts = data.split('|');
    return _DownloadSession(
      operationId: parts[0],
      remoteUrl: parts[1],
      destPath: parts[2],
      bytesReceived: int.parse(parts[3]),
      totalBytes: int.parse(parts[4]),
      createdAt: DateTime.parse(parts[5]),
    );
  }
}
