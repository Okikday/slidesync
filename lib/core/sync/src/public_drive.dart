part of '../gdrive_manager.dart';

/// Handles public/admin Drive operations — uploading to vault folders,
/// listing shared institution folders, and reading uploader metadata.
///
/// All write operations require admin-scoped auth.
/// Folder structure:
///   MaterialsRepo/public/{institutionId}/{courseId}/file.pdf
class _PublicDrive {
  _PublicDrive._();

  static const _maxUploadBytes = 500 * 1024 * 1024; // 500MB hard cap
  AuthClient? _cachedAdminClient;

  Future<AuthClient?> _adminClient({bool forceRefreshAuth = false}) async {
    if (forceRefreshAuth) {
      _cachedAdminClient = null;
    }
    _cachedAdminClient ??= await GDriveManager.instance.auth.adminClient();
    return _cachedAdminClient;
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  /// Upload a file to the public vault folder for the given institution/course.
  ///
  /// Enforces the 500MB limit. Caller must pass [uploadedBy] (admin uid) —
  /// this is stored in the Drive file description for audit purposes and
  /// echoed back in [DriveFileEntity.description] on reads.
  ///
  /// Streams [DriveProgress]. On completion:
  ///   - [DriveProgress.driveFileId] → Drive file ID
  ///   - Caller is responsible for the Firestore batch write via
  ///     [Api.instance.vault.logUploadWithSource()] — clean separation.
  Stream<DriveProgress> upload({
    required File file,
    required String institutionId,
    required String courseId,
    required String uploadedBy,
    required String operationId,
    String? fileName,
    String? mimeType,
    bool forceRefreshAuth = false,
  }) async* {
    final item = PublicUploadObject(file: file, operationId: operationId, fileName: fileName, mimeType: mimeType);

    await for (final event in uploadMultiple(
      objects: [item],
      institutionId: institutionId,
      courseId: courseId,
      uploadedBy: uploadedBy,
      forceRefreshAuth: forceRefreshAuth,
    )) {
      yield event.progress;
    }
  }

  /// Upload multiple files to the public vault folder for the given institution/course.
  ///
  /// This reuses the same authenticated client and destination folder for all items.
  Stream<PublicUploadProgressEvent> uploadMultiple({
    required List<PublicUploadObject> objects,
    required String institutionId,
    required String courseId,
    required String uploadedBy,
    bool forceRefreshAuth = true,
  }) async* {
    if (objects.isEmpty) return;

    try {
      final client = await _adminClient(forceRefreshAuth: forceRefreshAuth);
      if (client == null) {
        for (final item in objects) {
          yield PublicUploadProgressEvent(
            operationId: item.operationId,
            file: item.file,
            progress: DriveProgress.failed('Admin not signed in'),
          );
        }
        return;
      }

      // Resolve destination folder
      final segments = GDrivePaths.publicSegments(institutionId: institutionId, courseId: courseId);
      String? folderId;
      for (final name in segments) {
        folderId = await _PrivateDrive._findOrCreateFolder(client, name, folderId);
      }

      for (final item in objects) {
        try {
          final size = await item.file.length();
          if (size > _maxUploadBytes) {
            yield PublicUploadProgressEvent(
              operationId: item.operationId,
              file: item.file,
              progress: DriveProgress.failed('File exceeds 500MB limit (${DriveProgress.formatBytes(size)})'),
            );
            continue;
          }

          final auditedFileName = item.fileName ?? p.basename(item.file.path);

          await for (final progress in _ResumableUpload.upload(
            file: item.file,
            parentFolderId: folderId!,
            client: client,
            operationId: item.operationId,
            fileName: auditedFileName,
            mimeType: item.mimeType,
          )) {
            yield PublicUploadProgressEvent(operationId: item.operationId, file: item.file, progress: progress);
          }
        } catch (e, st) {
          log('PublicDrive.uploadMultiple item failed', error: e, stackTrace: st);
          yield PublicUploadProgressEvent(
            operationId: item.operationId,
            file: item.file,
            progress: DriveProgress.failed(e.toString()),
          );
        }
      }
    } catch (e, st) {
      log('PublicDrive.upload failed', error: e, stackTrace: st);
      for (final item in objects) {
        yield PublicUploadProgressEvent(
          operationId: item.operationId,
          file: item.file,
          progress: DriveProgress.failed(e.toString()),
        );
      }
    }
  }

  /// Patch a file's description with the uploader UID after upload completes.
  /// Call this immediately after [upload] emits a [DriveProgress.done] event.
  Future<Result<void>> patchUploaderAudit({required String fileId, required String uploadedBy}) =>
      Result.tryRunAsync(() async {
        final client = await _adminClient();
        if (client == null) throw StateError('Admin not signed in');
        final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?fields=id');
        await client.patch(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'description': 'uploadedBy:$uploadedBy'}),
        );
      });

  /// Verifies that a file ID is readable from the signed-in admin Drive account.
  /// Useful to ensure an upload completed on Drive before marking business success.
  Future<Result<bool?>> verifyUploadedFileExists(String fileId, {bool forceRefreshAuth = false}) =>
      Result.tryRunAsync(() async {
        final client = await _adminClient(forceRefreshAuth: forceRefreshAuth);
        if (client == null) return false;

        final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?fields=id');
        final response = await client.get(url);
        return response.statusCode == 200;
      });

  // ── List & browse ──────────────────────────────────────────────────────────

  /// List files in a public vault folder.
  /// Uses public browser — no admin auth required for listing.
  Future<Result<DrivePage?>> list({
    required String institutionId,
    required String courseId,
    int pageSize = 50,
    String? pageToken,
    String? nameContains,
    bool forceRefreshAuth = false,
  }) => Result.tryRunAsync(() async {
    final client = await _adminClient(forceRefreshAuth: forceRefreshAuth);
    if (client == null) throw StateError('Not signed in');

    final segments = GDrivePaths.publicSegments(institutionId: institutionId, courseId: courseId);
    final folderId = await _PrivateDrive._resolveFolderOnly(client, segments);
    if (folderId == null) return DrivePage(files: []);

    return _DriveBrowser.listFolder(folderId, pageSize: pageSize, pageToken: pageToken, nameContains: nameContains);
  });

  /// Get file metadata including the [uploadedBy] uid from description.
  Future<Result<PublicDriveFile?>> getFileWithUploader(String fileId) => Result.tryRunAsync(() async {
    final entity = await _DriveBrowser.getMetadata(fileId);
    final uploadedBy = _parseUploaderFromDescription(entity.description);
    return PublicDriveFile(file: entity, uploadedBy: uploadedBy);
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String? _parseUploaderFromDescription(String? description) {
    if (description == null) return null;
    const prefix = 'uploadedBy:';
    if (description.startsWith(prefix)) {
      return description.substring(prefix.length).trim();
    }
    return null;
  }
}

/// A [DriveFileEntity] enriched with the uploader UID extracted from metadata.
class PublicDriveFile {
  final DriveFileEntity file;

  /// The admin uid who uploaded this file, parsed from Drive file description.
  /// Null if the audit field wasn't set (pre-existing files).
  final String? uploadedBy;

  const PublicDriveFile({required this.file, this.uploadedBy});
}

class PublicUploadObject {
  final File file;
  final String operationId;
  final String? fileName;
  final String? mimeType;

  const PublicUploadObject({required this.file, required this.operationId, this.fileName, this.mimeType});
}

class PublicUploadProgressEvent {
  final String operationId;
  final File file;
  final DriveProgress progress;

  const PublicUploadProgressEvent({required this.operationId, required this.file, required this.progress});
}
