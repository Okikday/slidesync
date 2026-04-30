// ignore_for_file: unused_element

part of '../gdrive_manager.dart';

/// Handles all private Drive operations — personal user backup and sync.
/// Uses [driveFileScope] — only sees files the app itself created.
///
/// Folder structure:
///   MaterialsRepo/private/{uid}/{courseId}/{collectionId}/file.pdf
class _PrivateDrive {
  _PrivateDrive._();

  static AuthClient? _cachedPrivateClient;
  static const _appRootName = 'MaterialsRepo';
  static const _rootTagKey = 'slidesyncRoot';
  static const _rootTagValue = 'v1';

  static Future<AuthClient?> _privateClient({bool forceRefreshAuth = false}) async {
    if (forceRefreshAuth) {
      _cachedPrivateClient = null;
    }
    _cachedPrivateClient ??= await GDriveManager.instance.auth.privateClient();
    return _cachedPrivateClient;
  }

  // ── Folder resolution ──────────────────────────────────────────────────────

  /// Resolves (creating if needed) the Drive folder ID for a given path.
  /// [segments] = ['MaterialsRepo', 'private', uid, courseId, collectionId]
  static Future<Result<String?>> resolveFolderPath(List<String> segments, {bool forceRefreshAuth = false}) =>
      Result.tryRunAsync(() async {
        final client = await _privateClient(forceRefreshAuth: forceRefreshAuth);
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
  /// [operationId] is a caller-provided stable key (e.g. xxh3Hash) used
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
    bool forceRefreshAuth = false,
  }) async* {
    try {
      final client = await _privateClient(forceRefreshAuth: forceRefreshAuth);
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
    bool forceRefreshAuth = false,
  }) async* {
    try {
      final client = await _privateClient(forceRefreshAuth: forceRefreshAuth);
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
    bool forceRefreshAuth = false,
  }) => Result.tryRunAsync(() async {
    final client = await _privateClient(forceRefreshAuth: forceRefreshAuth);
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
    Future<String?> queryFolder({required bool taggedRootOnly}) async {
      final conditions = <String>[
        "name='${name.replaceAll("'", "\\'")}'",
        "mimeType='application/vnd.google-apps.folder'",
        'trashed=false',
        if (parentId != null) "'$parentId' in parents",
        if (taggedRootOnly) "appProperties has { key='$_rootTagKey' and value='$_rootTagValue' }",
      ];

      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files'
        '?q=${Uri.encodeQueryComponent(conditions.join(' and '))}&fields=files(id)&pageSize=1',
      );
      var r = await client.get(url);
      // If token is invalid/expired, try refreshing the admin client once and retry.
      if (r.statusCode == 401 || r.statusCode == 403) {
        try {
          final refreshed = await GDriveManager.instance.auth.adminClient();
          if (refreshed != null) {
            client = refreshed;
            r = await client.get(url);
          }
        } catch (_) {
          // ignore and fall through to error handling below
        }
      }
      if (r.statusCode != 200) return null;
      final files = (jsonDecode(r.body) as Map<String, dynamic>)['files'] as List<dynamic>;
      if (files.isEmpty) return null;
      return (files.first as Map<String, dynamic>)['id'] as String;
    }

    // Prefer the tagged root folder so we don't accidentally create/upload into
    // a duplicate MaterialsRepo tree with the same visible name.
    if (parentId == null && name == _appRootName) {
      final taggedRoot = await queryFolder(taggedRootOnly: true);
      if (taggedRoot != null) {
        return taggedRoot;
      }

      final fallbackRoot = await queryFolder(taggedRootOnly: false);
      if (fallbackRoot != null) {
        await client.patch(
          Uri.parse('https://www.googleapis.com/drive/v3/files/$fallbackRoot?fields=id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'appProperties': {_rootTagKey: _rootTagValue},
          }),
        );
        return fallbackRoot;
      }
    } else {
      final folderId = await queryFolder(taggedRootOnly: false);
      if (folderId != null) {
        return folderId;
      }
    }

    // Create the folder
    final createUrl = Uri.parse('https://www.googleapis.com/drive/v3/files?fields=id');
    final body = {
      'name': name,
      'mimeType': 'application/vnd.google-apps.folder',
      if (parentId != null) 'parents': [parentId],
      if (parentId == null && name == _appRootName) 'appProperties': {_rootTagKey: _rootTagValue},
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
      parentId = await _findOrCreateFolder(client, name, parentId);
      if (parentId == null) return null;
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
