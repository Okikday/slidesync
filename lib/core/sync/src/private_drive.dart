part of '../gdrive_manager.dart';

/// Handles all private Drive operations — personal user backup and sync.
/// Uses [driveFileScope] — only sees files the app itself created.
///
/// Folder structure:
///   MaterialsRepo/private/{uid}/{courseId}/{collectionId}/file.pdf
class _PrivateDrive {
  _PrivateDrive._();

  // ── Folder resolution ──────────────────────────────────────────────────────

  /// Resolves (creating if needed) the Drive folder ID for a given path.
  /// [segments] = ['MaterialsRepo', 'private', uid, courseId, collectionId]
  static Future<Result<String?>> resolveFolderPath(List<String> segments) => Result.tryRunAsync(() async {
    final client = await GDriveManager.instance.auth.privateClient();
    if (client == null) throw StateError('Not signed in');

    String? parentId; // null = My Drive root
    for (final name in segments) {
      parentId = await _findOrCreateFolder(client, name, parentId);
    }
    return parentId;
  });

  // ── Upload ─────────────────────────────────────────────────────────────────

  /// Upload a local file to the user's private Drive folder.
  ///
  /// [uid], [courseId], [collectionId] define the folder path.
  /// [operationId] is a caller-provided stable key (e.g. contentHash) used
  /// to resume interrupted uploads.
  ///
  /// Streams [DriveProgress]. Check [DriveProgress.driveFileId] on completion.
  static Stream<DriveProgress> upload({
    required File file,
    required String uid,
    required String courseId,
    required String collectionId,
    required String operationId,
    String? fileName,
    String? mimeType,
  }) async* {
    try {
      final client = await GDriveManager.instance.auth.privateClient();
      if (client == null) {
        yield DriveProgress.failed('Not signed in');
        return;
      }

      // Resolve destination folder
      final segments = GDrivePaths.privateSegments(uid: uid, courseId: courseId, collectionId: collectionId);
      String? folderId;
      for (final name in segments) {
        folderId = await _findOrCreateFolder(client, name, folderId);
      }

      yield* _ResumableUpload.upload(
        file: file,
        parentFolderId: folderId!,
        client: client,
        operationId: operationId,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (e, st) {
      log('PrivateDrive.upload failed', error: e, stackTrace: st);
      yield DriveProgress.failed(e.toString());
    }
  }

  // ── Download ───────────────────────────────────────────────────────────────

  /// Download a private Drive file to [destPath].
  /// Streams [DriveProgress]. Check [DriveProgress.localPath] on completion.
  static Stream<DriveProgress> download({
    required String fileId,
    required String destPath,
    required String operationId,
    int? knownSize,
  }) async* {
    try {
      final client = await GDriveManager.instance.auth.privateClient();
      if (client == null) {
        yield DriveProgress.failed('Not signed in');
        return;
      }

      yield* _ResumableDownload.download(
        fileId: fileId,
        destPath: destPath,
        client: client,
        operationId: operationId,
        knownSize: knownSize,
      );
    } catch (e, st) {
      log('PrivateDrive.download failed', error: e, stackTrace: st);
      yield DriveProgress.failed(e.toString());
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<Result<void>> delete(String fileId) => Result.tryRunAsync(() async {
    final api = await GDriveManager.instance.auth.privateDriveApi();
    if (api == null) throw StateError('Not signed in');
    await api.files.delete(fileId);
  });

  // ── List ───────────────────────────────────────────────────────────────────

  /// List files in the user's private collection folder.
  Future<Result<DrivePage?>> list({
    required String uid,
    required String courseId,
    required String collectionId,
    int pageSize = 50,
    String? pageToken,
  }) => Result.tryRunAsync(() async {
    final client = await GDriveManager.instance.auth.privateClient();
    if (client == null) throw StateError('Not signed in');

    // Resolve folder ID (don't create — list only)
    final segments = GDrivePaths.privateSegments(uid: uid, courseId: courseId, collectionId: collectionId);
    final folderId = await _resolveFolderOnly(client, segments);
    if (folderId == null) return DrivePage(files: []);

    return _DriveBrowser.listFolder(folderId, pageSize: pageSize, pageToken: pageToken);
  });

  /// Get metadata for a single private file.
  Future<Result<DriveFileEntity?>> getMetadata(String fileId) => Result.tryRunAsync(() async {
    final api = await GDriveManager.instance.auth.privateDriveApi();
    if (api == null) throw StateError('Not signed in');
    final f =
        await api.files.get(
              fileId,
              $fields:
                  'id,name,mimeType,size,md5Checksum,modifiedTime,createdTime,'
                  'webViewLink,parents,description,fileExtension,owners',
            )
            as drive.File;
    return _driveFileToEntity(f);
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Future<String> _findOrCreateFolder(AuthClient client, String name, String? parentId) async {
    final q = [
      "name='${name.replaceAll("'", "\\'")}'",
      "mimeType='application/vnd.google-apps.folder'",
      'trashed=false',
      if (parentId != null) "'$parentId' in parents",
    ].join(' and ');

    final url = Uri.parse(
      'https://www.googleapis.com/drive/v3/files'
      '?q=${Uri.encodeQueryComponent(q)}&fields=files(id)&pageSize=1',
    );
    final r = await client.get(url);
    if (r.statusCode == 200) {
      final files = (jsonDecode(r.body) as Map<String, dynamic>)['files'] as List<dynamic>;
      if (files.isNotEmpty) {
        return (files.first as Map<String, dynamic>)['id'] as String;
      }
    }

    // Create the folder
    final createUrl = Uri.parse('https://www.googleapis.com/drive/v3/files?fields=id');
    final body = {
      'name': name,
      'mimeType': 'application/vnd.google-apps.folder',
      if (parentId != null) 'parents': [parentId],
    };
    final cr = await client.post(createUrl, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (cr.statusCode == 200) {
      return (jsonDecode(cr.body) as Map<String, dynamic>)['id'] as String;
    }
    throw HttpException('Failed to create folder "$name" (${cr.statusCode})');
  }

  static Future<String?> _resolveFolderOnly(AuthClient client, List<String> segments) async {
    String? parentId;
    for (final name in segments) {
      final q = [
        "name='${name.replaceAll("'", "\\'")}'",
        "mimeType='application/vnd.google-apps.folder'",
        'trashed=false',
        if (parentId != null) "'$parentId' in parents",
      ].join(' and ');

      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files'
        '?q=${Uri.encodeQueryComponent(q)}&fields=files(id)&pageSize=1',
      );
      final r = await client.get(url);
      if (r.statusCode != 200) return null;
      final files = (jsonDecode(r.body) as Map<String, dynamic>)['files'] as List<dynamic>;
      if (files.isEmpty) return null;
      parentId = (files.first as Map<String, dynamic>)['id'] as String;
    }
    return parentId;
  }

  static DriveFileEntity _driveFileToEntity(drive.File f) {
    return DriveFileEntity(
      id: f.id ?? '',
      name: f.name ?? '',
      mimeType: f.mimeType ?? '',
      size: f.size?.toString(),
      webViewLink: f.webViewLink,
      parents: f.parents ?? [],
      modifiedTime: f.modifiedTime?.toIso8601String(),
      createdTime: f.createdTime?.toIso8601String(),
      description: f.description,
      fileExtension: f.fileExtension,
      md5Checksum: f.md5Checksum,
      ownerDisplayName: f.owners?.isNotEmpty == true ? f.owners!.first.displayName : null,
      ownerEmail: f.owners?.isNotEmpty == true ? f.owners!.first.emailAddress : null,
    );
  }
}
