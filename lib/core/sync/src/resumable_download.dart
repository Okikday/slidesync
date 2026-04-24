// ignore_for_file: unused_element

part of '../gdrive_manager.dart';

/// Handles resumable authenticated downloads from Google Drive.
/// Uses HTTP Range headers — interrupted downloads continue from last byte,
/// not from scratch. Session state persisted via AppHiveData.
class _ResumableDownload {
  _ResumableDownload._();

  static const _bufferSize = 512 * 1024; // 512KB read buffer

  static String _sessionKey(String operationId) => '${HiveDataPathKey.driveDownloadSession.name}_$operationId';

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Download Drive file [fileId] to [destPath] using auth [client].
  ///
  /// Streams [DriveProgress]. On completion, [DriveProgress.localPath] is set.
  /// Pass [operationId] to enable resume across app kills.
  static Stream<DriveProgress> download({
    required String fileId,
    required String destPath,
    required AuthClient client,
    required String operationId,
    int? knownSize,
  }) async* {
    try {
      // Resolve total size
      int totalBytes = knownSize ?? await _fetchFileSize(fileId, client);
      if (totalBytes <= 0) {
        throw StateError('Could not determine file size for $fileId');
      }

      yield DriveProgress.starting(totalBytes: totalBytes);

      // Check if we have a partial download already
      final destFile = File(destPath);
      await destFile.parent.create(recursive: true);

      int startByte = 0;
      if (await destFile.exists()) {
        startByte = await destFile.length();
        if (startByte >= totalBytes) {
          // Already complete
          yield DriveProgress.done(totalBytes: totalBytes, localPath: destPath);
          return;
        }
      }

      // Persist session
      await _saveSession(operationId, destPath, startByte, totalBytes);

      final downloadUrl = 'https://www.googleapis.com/drive/v3/files/$fileId?alt=media';

      final sink = destFile.openWrite(mode: FileMode.append);

      try {
        int bytesReceived = startByte;

        while (bytesReceived < totalBytes) {
          final end = (bytesReceived + _bufferSize - 1).clamp(0, totalBytes - 1).toInt();

          final request = http.Request('GET', Uri.parse(downloadUrl))..headers['Range'] = 'bytes=$bytesReceived-$end';

          final streamedResponse = await client.send(request);

          if (streamedResponse.statusCode != 206 && streamedResponse.statusCode != 200) {
            throw HttpException('Download failed (${streamedResponse.statusCode})');
          }

          await for (final chunk in streamedResponse.stream) {
            sink.add(chunk);
            bytesReceived += chunk.length;

            await _saveSession(operationId, destPath, bytesReceived, totalBytes);

            yield DriveProgress(
              bytesTransferred: bytesReceived,
              totalBytes: totalBytes,
              state: DriveProgressState.active,
            );
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      await _clearSession(operationId);

      yield DriveProgress.done(totalBytes: totalBytes, localPath: destPath);
    } catch (e, st) {
      log('ResumableDownload: failed', error: e, stackTrace: st);
      yield DriveProgress.failed(e.toString());
    }
  }

  // ── Session persistence via AppHiveData ───────────────────────────────────

  static Future<void> _saveSession(String id, String path, int received, int total) async {
    await AppHiveData.instance.setData<String>(
      key: _sessionKey(id),
      value: jsonEncode({'path': path, 'received': received, 'total': total}),
    );
  }

  static Future<void> _clearSession(String id) async {
    await AppHiveData.instance.deleteData(key: _sessionKey(id));
  }

  /// Check if a partial download exists for [operationId].
  /// Returns bytes already downloaded, or 0 if none.
  static Future<int> checkPartialDownload(String operationId) async {
    final raw = await AppHiveData.instance.getData<String>(key: _sessionKey(operationId));
    if (raw == null) return 0;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final path = m['path'] as String;
      if (!await File(path).exists()) return 0;
      return m['received'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Future<int> _fetchFileSize(String fileId, AuthClient client) async {
    final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?fields=size');
    final r = await client.get(url);
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      return int.tryParse(body['size']?.toString() ?? '') ?? 0;
    }
    return 0;
  }
}
