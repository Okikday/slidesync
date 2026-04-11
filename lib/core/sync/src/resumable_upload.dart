part of '../gdrive_manager.dart';

/// Handles resumable uploads to Google Drive using the resumable upload protocol.
/// Sessions are persisted to shared_preferences so interrupted uploads can resume
/// after an app kill — critical for large files on mobile networks.
///
/// Protocol: https://developers.google.com/drive/api/guides/manage-uploads#resumable
class _ResumableUpload {
  _ResumableUpload._();

  static const _chunkSize = 5 * 1024 * 1024; // 5MB chunks (Drive minimum)

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Upload [file] to [parentFolderId] using the provided auth [client].
  ///
  /// Returns a stream of [DriveProgress]. On completion, [DriveProgress.driveFileId]
  /// is populated. On failure, [DriveProgress.error] is set.
  ///
  /// Pass [operationId] to support resume across app kills. If a session
  /// exists for this ID, the upload resumes from the last committed byte.
  static Stream<DriveProgress> upload({
    required File file,
    required String parentFolderId,
    required AuthClient client,
    required String operationId,
    String? fileName,
    String? mimeType,
  }) async* {
    final totalBytes = await file.length();
    final name = fileName ?? p.basename(file.path);
    final mime = mimeType ?? _guessMime(name);

    yield DriveProgress.starting(totalBytes: totalBytes);

    try {
      // Try to restore a previous session
      String? sessionUri = await _loadSession(operationId);
      int startByte = 0;

      if (sessionUri != null) {
        // Query how many bytes the server already has
        startByte = await _querySessionOffset(sessionUri, client, totalBytes);
        if (startByte < 0) {
          // Session expired — start fresh
          sessionUri = null;
          startByte = 0;
        }
      }

      // Initiate new session if none restored
      sessionUri ??= await _initiateSession(
        client: client,
        name: name,
        mimeType: mime,
        totalBytes: totalBytes,
        parentFolderId: parentFolderId,
      );

      await _saveSession(
        operationId,
        ResumableSession(
          operationId: operationId,
          sessionUri: sessionUri,
          bytesTransferred: startByte,
          totalBytes: totalBytes,
          filePath: file.path,
        ),
      );

      // Upload chunks
      final fileStream = file.openRead(startByte);
      int bytesTransferred = startByte;
      String? driveFileId;

      final reader = file.openSync();
      reader.setPositionSync(startByte);

      try {
        while (bytesTransferred < totalBytes) {
          final end = (bytesTransferred + _chunkSize).clamp(0, totalBytes);
          final chunkSize = end - bytesTransferred;
          final chunk = reader.readSync(chunkSize);

          final result = await _uploadChunk(
            sessionUri: sessionUri,
            client: client,
            chunk: chunk,
            start: bytesTransferred,
            end: end - 1,
            totalBytes: totalBytes,
          );

          bytesTransferred = end;

          if (result.isComplete) {
            driveFileId = result.fileId;
          }

          // Update persisted session progress
          await _saveSession(
            operationId,
            ResumableSession(
              operationId: operationId,
              sessionUri: sessionUri,
              bytesTransferred: bytesTransferred,
              totalBytes: totalBytes,
              filePath: file.path,
              driveFileId: driveFileId,
            ),
          );

          yield DriveProgress(
            bytesTransferred: bytesTransferred,
            totalBytes: totalBytes,
            state: driveFileId != null ? DriveProgressState.done : DriveProgressState.active,
            driveFileId: driveFileId,
          );
        }
      } finally {
        reader.closeSync();
        fileStream; // suppress unused warning
      }

      // Clean up persisted session on success
      await _clearSession(operationId);

      yield DriveProgress.done(totalBytes: totalBytes, driveFileId: driveFileId);
    } catch (e, st) {
      log('ResumableUpload: failed', error: e, stackTrace: st);
      yield DriveProgress.failed(e.toString(), totalBytes: totalBytes);
    }
  }

  // ── Session management ─────────────────────────────────────────────────────

  static Future<String> _initiateSession({
    required AuthClient client,
    required String name,
    required String mimeType,
    required int totalBytes,
    required String parentFolderId,
  }) async {
    final metadata = jsonEncode({
      'name': name,
      'parents': [parentFolderId],
    });

    final url = Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable');

    final response = await client.post(
      url,
      headers: {
        'X-Upload-Content-Type': mimeType,
        'X-Upload-Content-Length': '$totalBytes',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: metadata,
    );

    if (response.statusCode != 200) {
      throw HttpException('Failed to initiate upload session (${response.statusCode}): ${response.body}', uri: url);
    }

    final location = response.headers['location'];
    if (location == null) throw StateError('Drive did not return a session URI');
    return location;
  }

  static Future<_ChunkResult> _uploadChunk({
    required String sessionUri,
    required AuthClient client,
    required List<int> chunk,
    required int start,
    required int end,
    required int totalBytes,
  }) async {
    final response = await client.put(
      Uri.parse(sessionUri),
      headers: {'Content-Range': 'bytes $start-$end/$totalBytes', 'Content-Type': 'application/octet-stream'},
      body: chunk,
    );

    // 200/201 = complete, 308 = resume incomplete (more chunks needed)
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return _ChunkResult(isComplete: true, fileId: body['id'] as String?);
    }
    if (response.statusCode == 308) {
      return const _ChunkResult(isComplete: false);
    }

    throw HttpException('Chunk upload failed (${response.statusCode}): ${response.body}');
  }

  /// Query the server for how many bytes it has received for an existing session.
  /// Returns -1 if the session has expired.
  static Future<int> _querySessionOffset(String sessionUri, AuthClient client, int totalBytes) async {
    try {
      final r = await client.put(Uri.parse(sessionUri), headers: {'Content-Range': 'bytes */$totalBytes'});
      if (r.statusCode == 308) {
        final range = r.headers['range'];
        if (range == null) return 0; // no bytes received yet
        final end = int.tryParse(range.split('-').last) ?? 0;
        return end + 1;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        return totalBytes; // already complete
      }
      return -1; // expired or invalid
    } catch (_) {
      return -1;
    }
  }

  // ── Local session persistence via AppHiveData ─────────────────────────────
  // Keys follow the pattern: driveUploadSession_{operationId}
  // Stored in the regular (non-encrypted) Hive box — session URIs are
  // time-limited by Drive anyway, so encryption is not needed here.

  static String _sessionKey(String operationId) => '${HiveDataPathKey.driveUploadSession.name}_$operationId';

  static Future<String?> _loadSession(String operationId) async {
    final raw = await AppHiveData.instance.getData<String>(key: _sessionKey(operationId));
    if (raw == null) return null;
    try {
      final session = ResumableSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return session.sessionUri;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveSession(String operationId, ResumableSession session) async {
    await AppHiveData.instance.setData<String>(key: _sessionKey(operationId), value: jsonEncode(session.toJson()));
  }

  static Future<void> _clearSession(String operationId) async {
    await AppHiveData.instance.deleteData(key: _sessionKey(operationId));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _guessMime(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    const mimes = {
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.xls': 'application/vnd.ms-excel',
      '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '.ppt': 'application/vnd.ms-powerpoint',
      '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.mp4': 'video/mp4',
      '.mp3': 'audio/mpeg',
      '.zip': 'application/zip',
    };
    return mimes[ext] ?? 'application/octet-stream';
  }
}

class _ChunkResult {
  final bool isComplete;
  final String? fileId;
  const _ChunkResult({required this.isComplete, this.fileId});
}
