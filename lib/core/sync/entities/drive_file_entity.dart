/// Represents a file or folder returned by the Drive API.
/// Replaces the old DriveFile — same fields, cleaner API.
class DriveFileEntity {
  final String id;
  final String name;
  final String mimeType;
  final String? size; // Drive returns size as string
  final String? webViewLink;
  final String? webContentLink;
  final List<String> parents;
  final String? modifiedTime;
  final String? createdTime;
  final String? description;
  final String? fileExtension;
  final String? originalFilename;
  final bool starred;
  final bool trashed;
  final String? iconLink;
  final String? thumbnailLink;
  final String? md5Checksum; // used as content hash where available

  // Owner
  final String? ownerDisplayName;
  final String? ownerEmail;
  final String? ownerPhotoLink;

  // Sharing
  final bool shared;
  final bool? viewedByMe;
  final String? lastModifyingUserDisplayName;
  final String? lastModifyingUserEmail;

  final int? version;
  final bool? hasAugmentedPermissions;
  final bool? isAppAuthorized;

  const DriveFileEntity({
    required this.id,
    required this.name,
    required this.mimeType,
    this.size,
    this.webViewLink,
    this.webContentLink,
    this.parents = const [],
    this.modifiedTime,
    this.createdTime,
    this.description,
    this.fileExtension,
    this.originalFilename,
    this.starred = false,
    this.trashed = false,
    this.iconLink,
    this.thumbnailLink,
    this.md5Checksum,
    this.ownerDisplayName,
    this.ownerEmail,
    this.ownerPhotoLink,
    this.shared = false,
    this.viewedByMe,
    this.lastModifyingUserDisplayName,
    this.lastModifyingUserEmail,
    this.version,
    this.hasAugmentedPermissions,
    this.isAppAuthorized,
  });

  factory DriveFileEntity.fromJson(Map<String, dynamic> j) {
    final owners = j['owners'] as List<dynamic>?;
    final firstOwner =
        owners?.isNotEmpty == true ? owners!.first as Map<String, dynamic>? : null;
    final lastModifier = j['lastModifyingUser'] as Map<String, dynamic>?;

    return DriveFileEntity(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      mimeType: j['mimeType'] as String? ?? '',
      size: j['size']?.toString(),
      webViewLink: j['webViewLink'] as String?,
      webContentLink: j['webContentLink'] as String?,
      parents: (j['parents'] as List<dynamic>?)?.cast<String>() ?? [],
      modifiedTime: j['modifiedTime'] as String?,
      createdTime: j['createdTime'] as String?,
      description: j['description'] as String?,
      fileExtension: j['fileExtension'] as String?,
      originalFilename: j['originalFilename'] as String?,
      starred: j['starred'] as bool? ?? false,
      trashed: j['trashed'] as bool? ?? false,
      iconLink: j['iconLink'] as String?,
      thumbnailLink: j['thumbnailLink'] as String?,
      md5Checksum: j['md5Checksum'] as String?,
      ownerDisplayName: firstOwner?['displayName'] as String?,
      ownerEmail: firstOwner?['emailAddress'] as String?,
      ownerPhotoLink: firstOwner?['photoLink'] as String?,
      shared: j['shared'] as bool? ?? false,
      viewedByMe: j['viewedByMe'] as bool?,
      lastModifyingUserDisplayName: lastModifier?['displayName'] as String?,
      lastModifyingUserEmail: lastModifier?['emailAddress'] as String?,
      version: j['version'] is String
          ? int.tryParse(j['version'] as String)
          : j['version'] as int?,
      hasAugmentedPermissions: j['hasAugmentedPermissions'] as bool?,
      isAppAuthorized: j['isAppAuthorized'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mimeType': mimeType,
        'size': size,
        'webViewLink': webViewLink,
        'webContentLink': webContentLink,
        'parents': parents,
        'modifiedTime': modifiedTime,
        'createdTime': createdTime,
        'description': description,
        'fileExtension': fileExtension,
        'originalFilename': originalFilename,
        'starred': starred,
        'trashed': trashed,
        'iconLink': iconLink,
        'thumbnailLink': thumbnailLink,
        'md5Checksum': md5Checksum,
        'ownerDisplayName': ownerDisplayName,
        'ownerEmail': ownerEmail,
        'ownerPhotoLink': ownerPhotoLink,
        'shared': shared,
        'viewedByMe': viewedByMe,
        'lastModifyingUserDisplayName': lastModifyingUserDisplayName,
        'lastModifyingUserEmail': lastModifyingUserEmail,
        'version': version,
        'hasAugmentedPermissions': hasAugmentedPermissions,
        'isAppAuthorized': isAppAuthorized,
      };

  // ── Derived helpers ────────────────────────────────────────────────────────

  DriveResourceType get resourceType {
    final mt = mimeType.toLowerCase();
    if (mt == 'application/vnd.google-apps.folder') return DriveResourceType.folder;
    if (mt.startsWith('application/vnd.google-apps.document')) return DriveResourceType.googleDoc;
    if (mt.startsWith('application/vnd.google-apps.spreadsheet')) return DriveResourceType.googleSheet;
    if (mt.startsWith('application/vnd.google-apps.presentation')) return DriveResourceType.googleSlide;
    if (mt == 'application/vnd.google-apps.shortcut') return DriveResourceType.shortcut;
    return DriveResourceType.file;
  }

  bool get isFolder => resourceType == DriveResourceType.folder;
  bool get isGoogleNative => mimeType.startsWith('application/vnd.google-apps.') && !isFolder;

  /// Drive API returns size as string; parsed here for convenience.
  int? get sizeBytes => size != null ? int.tryParse(size!) : null;

  String get formattedSize {
    final bytes = sizeBytes;
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Best available content hash — md5 from Drive if present, null otherwise.
  /// Caller should fall back to xxh3 of downloaded bytes when this is null.
  String? get contentHash => md5Checksum;

  /// Resolved display name including extension for Google-native files.
  String get displayName {
    if (!isGoogleNative) return name;
    final ext = _googleNativeExtension;
    if (ext != null && !name.toLowerCase().endsWith(ext)) return '$name$ext';
    return name;
  }

  String? get _googleNativeExtension {
    final mt = mimeType.toLowerCase();
    if (mt.contains('document')) return '.gdoc';
    if (mt.contains('spreadsheet')) return '.gsheet';
    if (mt.contains('presentation')) return '.gslides';
    if (mt.contains('drawing')) return '.gdraw';
    if (mt.contains('form')) return '.gform';
    return null;
  }

  DateTime? get createdAt =>
      createdTime != null ? DateTime.tryParse(createdTime!) : null;

  DateTime? get modifiedAt =>
      modifiedTime != null ? DateTime.tryParse(modifiedTime!) : null;
}

// ── Supporting types ───────────────────────────────────────────────────────

enum DriveResourceType {
  file,
  folder,
  googleDoc,
  googleSheet,
  googleSlide,
  shortcut,
  unknown,
}

/// Result of resolving a Drive link — either a single file or a folder with children.
class DriveResource {
  final DriveResourceType type;
  final DriveFileEntity file; // always present — the resolved item itself
  final List<DriveFileEntity> children; // populated when type == folder

  const DriveResource({
    required this.type,
    required this.file,
    this.children = const [],
  });

  bool get isFolder => type == DriveResourceType.folder;
}

/// A page of folder listing results with an optional next-page cursor.
class DrivePage {
  final List<DriveFileEntity> files;
  final String? nextPageToken;

  bool get hasMore => nextPageToken != null;

  const DrivePage({required this.files, this.nextPageToken});
}
