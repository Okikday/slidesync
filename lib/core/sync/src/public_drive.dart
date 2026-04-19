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
  }) async* {
    try {
      // 500MB guard
      final size = await file.length();
      if (size > _maxUploadBytes) {
        yield DriveProgress.failed('File exceeds 500MB limit (${DriveProgress.formatBytes(size)})');
        return;
      }

      final client = await GDriveManager.instance.auth.adminClient();
      if (client == null) {
        yield DriveProgress.failed('Admin not signed in');
        return;
      }

      // Resolve destination folder
      final segments = GDrivePaths.publicSegments(institutionId: institutionId, courseId: courseId);
      String? folderId;
      for (final name in segments) {
        folderId = await _PrivateDrive._findOrCreateFolder(client, name, folderId);
      }

      // Patch file description with uploader UID for audit trail
      // The description is readable via metadata so we know who uploaded.
      // Format: "uploadedBy:{uid}"
      final auditedFileName = fileName ?? p.basename(file.path);

      yield* _ResumableUpload.upload(
        file: file,
        parentFolderId: folderId!,
        client: client,
        operationId: operationId,
        fileName: auditedFileName,
        mimeType: mimeType,
      );

      // Note: after upload, caller must patch description with uploadedBy.
      // We don't do it here because we'd need the fileId from the final
      // DriveProgress event. The caller handles: patchDescription + batch write.
    } catch (e, st) {
      log('PublicDrive.upload failed', error: e, stackTrace: st);
      yield DriveProgress.failed(e.toString());
    }
  }

  /// Patch a file's description with the uploader UID after upload completes.
  /// Call this immediately after [upload] emits a [DriveProgress.done] event.
  Future<Result<void>> patchUploaderAudit({required String fileId, required String uploadedBy}) =>
      Result.tryRunAsync(() async {
        final client = await GDriveManager.instance.auth.adminClient();
        if (client == null) throw StateError('Admin not signed in');
        final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?fields=id');
        await client.patch(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'description': 'uploadedBy:$uploadedBy'}),
        );
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
  }) => Result.tryRunAsync(() async {
    final client = await GDriveManager.instance.auth.adminClient();
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
