part of '../gdrive_manager.dart';

/// Handles all read-only Drive operations using a public API key.
/// No authentication required — these are for publicly accessible files/folders.
///
/// All methods are static and isolate-friendly.
class _DriveBrowser {
  _DriveBrowser._();

  static const _fields =
      'id,name,mimeType,size,modifiedTime,createdTime,'
      'webViewLink,webContentLink,parents,description,fileExtension,originalFilename,'
      'starred,trashed,iconLink,thumbnailLink,md5Checksum,owners,shared,viewedByMe,'
      'lastModifyingUser,version,hasAugmentedPermissions,isAppAuthorized';

  // ── Metadata ───────────────────────────────────────────────────────────────

  static Future<DriveFileEntity> getMetadata(String fileId) async {
    final client = http.Client();
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId'
        '?fields=$_fields&key=${Uri.encodeComponent(GDriveAuth.apiKey)}',
      );
      final r = await client.get(url);
      if (r.statusCode == 200) {
        return DriveFileEntity.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
      }
      throw HttpException(
          'Metadata fetch failed (${r.statusCode}): ${r.body}', uri: url);
    } finally {
      client.close();
    }
  }

  static Future<bool> isAccessible(String fileId) async {
    final client = http.Client();
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId'
        '?fields=id&key=${Uri.encodeComponent(GDriveAuth.apiKey)}',
      );
      final r = await client.get(url);
      return r.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  // ── Folder listing (paginated) ─────────────────────────────────────────────

  /// Returns one page of a folder's children.
  /// Pass [pageToken] from [DrivePage.nextPageToken] for subsequent pages.
  static Future<DrivePage> listFolder(
    String folderId, {
    int pageSize = 50,
    String? pageToken,
    String? nameContains, // optional filter
    String? mimeType,     // e.g. 'application/pdf'
  }) async {
    final client = http.Client();
    try {
      final queryParts = [
        "'$folderId' in parents",
        'trashed=false',
        if (nameContains != null) "name contains '${nameContains.replaceAll("'", "\\'")}'",
        if (mimeType != null) "mimeType='$mimeType'",
      ];
      final q = Uri.encodeQueryComponent(queryParts.join(' and '));

      final tokenParam = pageToken != null
          ? '&pageToken=${Uri.encodeQueryComponent(pageToken)}'
          : '';

      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files'
        '?q=$q'
        '&fields=nextPageToken,files($_fields)'
        '&pageSize=$pageSize'
        '&orderBy=folder,name'
        '&key=${Uri.encodeComponent(GDriveAuth.apiKey)}'
        '$tokenParam',
      );

      final r = await client.get(url);
      if (r.statusCode != 200) {
        throw HttpException(
            'Folder listing failed (${r.statusCode}): ${r.body}', uri: url);
      }

      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final files = (body['files'] as List<dynamic>? ?? [])
          .map((f) => DriveFileEntity.fromJson(f as Map<String, dynamic>))
          .toList();

      return DrivePage(
        files: files,
        nextPageToken: body['nextPageToken'] as String?,
      );
    } finally {
      client.close();
    }
  }

  /// Convenience: fetch ALL pages for a folder. Use sparingly on large folders.
  static Future<List<DriveFileEntity>> listFolderAll(
    String folderId, {
    String? nameContains,
    String? mimeType,
  }) async {
    final all = <DriveFileEntity>[];
    String? pageToken;
    do {
      final page = await listFolder(
        folderId,
        pageSize: 100,
        pageToken: pageToken,
        nameContains: nameContains,
        mimeType: mimeType,
      );
      all.addAll(page.files);
      pageToken = page.nextPageToken;
    } while (pageToken != null);
    return all;
  }

  // ── Link resolution ────────────────────────────────────────────────────────

  /// Resolves a Drive link to a [DriveResource].
  /// For folders: returns metadata + first page of children.
  /// For files: returns metadata only.
  static Future<DriveResource> resolveLink(
    String link, {
    int folderPageSize = 50,
  }) async {
    final id = GDrivePaths.extractId(link);
    if (id == null) throw ArgumentError('Could not extract Drive ID from: $link');

    final meta = await getMetadata(id);

    if (meta.isFolder) {
      final page = await listFolder(id, pageSize: folderPageSize);
      return DriveResource(
        type: DriveResourceType.folder,
        file: meta,
        children: page.files,
      );
    }

    return DriveResource(type: meta.resourceType, file: meta);
  }

  // ── Search within a folder ─────────────────────────────────────────────────

  /// Search for files matching [query] within a specific folder.
  static Future<DrivePage> searchInFolder(
    String folderId,
    String query, {
    int pageSize = 30,
    String? pageToken,
  }) =>
      listFolder(
        folderId,
        pageSize: pageSize,
        pageToken: pageToken,
        nameContains: query,
      );

  // ── Download (public files, no auth) ──────────────────────────────────────

  /// Downloads a publicly accessible file to a temp path.
  /// For authenticated private downloads, use [_ResumableDownload] instead.
  static Future<String> downloadPublicFile(
    String fileId, {
    required String destPath,
  }) async {
    final client = http.Client();
    try {
      // Try REST alt=media first
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId'
        '?alt=media&key=${Uri.encodeComponent(GDriveAuth.apiKey)}',
      );
      var r = await client.get(url);

      // Fallback to direct uc?export=download
      if (r.statusCode != 200) {
        final fallback =
            Uri.parse('https://drive.google.com/uc?export=download&id=$fileId');
        r = await client.get(fallback);
        final ct = r.headers['content-type'] ?? '';
        if (r.statusCode != 200 || ct.contains('text/html')) {
          throw StateError(
              'Cannot download file $fileId — may be private or require auth.');
        }
      }

      final file = File(destPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(r.bodyBytes);
      return destPath;
    } finally {
      client.close();
    }
  }

  // ── Google-native export ───────────────────────────────────────────────────

  /// Exports a Google-native file (Doc/Sheet/Slide) to a target MIME type.
  /// Common targets:
  ///   Docs  → 'application/pdf' | 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ///   Sheets → 'application/pdf' | 'text/csv'
  ///   Slides → 'application/pdf' | 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  static Future<String> exportGoogleFile(
    String fileId, {
    required String exportMimeType,
    required String destPath,
  }) async {
    final client = http.Client();
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId/export'
        '?mimeType=${Uri.encodeComponent(exportMimeType)}'
        '&key=${Uri.encodeComponent(GDriveAuth.apiKey)}',
      );
      final r = await client.get(url);
      if (r.statusCode != 200) {
        throw HttpException(
            'Export failed (${r.statusCode}): ${r.body}', uri: url);
      }
      final file = File(destPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(r.bodyBytes);
      return destPath;
    } finally {
      client.close();
    }
  }
}
