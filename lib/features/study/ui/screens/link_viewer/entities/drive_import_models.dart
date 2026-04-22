import 'package:path/path.dart' as p;
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart' as drive_service;

class DriveSourceFingerprint {
  final String? driveId;
  final String? shortcutTargetId;
  final String? md5Checksum;
  final String sourceName;
  final String normalizedTitle;
  final String normalizedExtension;
  final int? fileSize;
  final String mimeType;
  final String mimeBucket;

  const DriveSourceFingerprint({
    required this.driveId,
    required this.shortcutTargetId,
    required this.md5Checksum,
    required this.sourceName,
    required this.normalizedTitle,
    required this.normalizedExtension,
    required this.fileSize,
    required this.mimeType,
    required this.mimeBucket,
  });

  factory DriveSourceFingerprint.fromFile(drive_service.DriveFile file) {
    final sourceName = file.name?.trim() ?? '';
    final normalizedTitle = _normalizeToken(p.basenameWithoutExtension(sourceName));
    final normalizedExtension = _normalizeToken(file.fileExtension ?? p.extension(sourceName).replaceFirst('.', ''));
    final fileSize = int.tryParse(file.size ?? '');
    final mimeType = (file.mimeType ?? '').trim();
    final mimeBucket = _driveMimeBucket(mimeType);

    return DriveSourceFingerprint(
      driveId: _normalizeToken(file.navigationTargetId ?? file.id),
      shortcutTargetId: _normalizeToken(file.shortcutTargetId),
      md5Checksum: _normalizeToken(file.md5Checksum),
      sourceName: sourceName,
      normalizedTitle: normalizedTitle,
      normalizedExtension: normalizedExtension,
      fileSize: fileSize,
      mimeType: mimeType,
      mimeBucket: mimeBucket,
    );
  }

  String get sourceKey {
    if (driveId != null && driveId!.isNotEmpty) {
      return 'drive-id:$driveId';
    }
    if (shortcutTargetId != null && shortcutTargetId!.isNotEmpty) {
      return 'drive-shortcut:$shortcutTargetId';
    }
    if (md5Checksum != null && md5Checksum!.isNotEmpty) {
      return 'drive-md5:$md5Checksum';
    }
    return 'drive-fallback:$normalizedTitle|$normalizedExtension|${fileSize ?? 0}|$mimeBucket';
  }

  Map<String, dynamic> toMetadataFields() {
    return <String, dynamic>{
      'driveSourceKey': sourceKey,
      'driveId': driveId,
      'driveShortcutTargetId': shortcutTargetId,
      'driveMd5Checksum': md5Checksum,
      'driveSourceName': sourceName,
      'driveTitle': normalizedTitle,
      'driveExtension': normalizedExtension,
      'driveFileSize': fileSize,
      'driveMimeType': mimeType,
      'driveMimeBucket': mimeBucket,
    }..removeWhere((key, value) => value == null || value == '');
  }

  bool matchesContent(CourseContent content) {
    final metadata = content.metadata;
    final fields = metadata.fields ?? const <String, dynamic>{};

    String? fieldValue(String key) => fields[key]?.toString().trim().toLowerCase();

    final storedSourceKey = fieldValue('driveSourceKey') ?? fieldValue('sourceKey');
    if (storedSourceKey != null && storedSourceKey == sourceKey) return true;

    final storedDriveId = fieldValue('driveId');
    if (driveId != null && driveId!.isNotEmpty && storedDriveId == driveId) return true;

    final storedShortcutTargetId = fieldValue('driveShortcutTargetId');
    if (shortcutTargetId != null && shortcutTargetId!.isNotEmpty && storedShortcutTargetId == shortcutTargetId) {
      return true;
    }

    final storedMd5Checksum = fieldValue('driveMd5Checksum');
    if (md5Checksum != null && md5Checksum!.isNotEmpty && storedMd5Checksum == md5Checksum) return true;

    final storedTitle = _normalizeToken(content.title);
    final storedOriginalTitle = _normalizeToken(p.basenameWithoutExtension(metadata.originalFileName ?? ''));
    final titleMatches =
        normalizedTitle.isNotEmpty && (storedTitle == normalizedTitle || storedOriginalTitle == normalizedTitle);
    if (!titleMatches) return false;

    if (fileSize != null && fileSize! > 0 && content.fileSize != fileSize) return false;

    if (normalizedExtension.isNotEmpty) {
      final contentExtension = _normalizeToken(
        p.extension(metadata.originalFileName ?? content.title).replaceFirst('.', ''),
      );
      if (contentExtension.isNotEmpty && contentExtension != normalizedExtension) {
        return false;
      }
    }

    final storedMimeBucket = _normalizeToken(fields['driveMimeBucket']?.toString());
    if (storedMimeBucket.isNotEmpty && storedMimeBucket != mimeBucket) return false;

    return true;
  }
}

class DriveCacheEntry {
  final String path;
  final String uuid;
  final int bytes;
  final String? note;
  final bool reusedExistingPath;
  final drive_service.DriveFile sourceFile;
  final DriveSourceFingerprint fingerprint;

  const DriveCacheEntry({
    required this.path,
    required this.uuid,
    required this.bytes,
    required this.sourceFile,
    required this.fingerprint,
    this.note,
    this.reusedExistingPath = false,
  });
}

class DriveImportOutcome {
  final String collectionId;
  final String title;
  final SyncType type;
  final int itemCount;
  final int totalBytes;
  final String? primaryContentId;
  final String? note;

  const DriveImportOutcome({
    required this.collectionId,
    required this.title,
    required this.type,
    required this.itemCount,
    required this.totalBytes,
    this.primaryContentId,
    this.note,
  });
}

String _normalizeToken(String? value) => (value ?? '').trim().toLowerCase();

String _driveMimeBucket(String? mimeType) {
  final normalized = _normalizeToken(mimeType);
  if (normalized.isEmpty) return 'unknown';
  if (normalized.startsWith('application/vnd.google-apps.document')) return 'google-doc';
  if (normalized.startsWith('application/vnd.google-apps.spreadsheet')) return 'google-sheet';
  if (normalized.startsWith('application/vnd.google-apps.presentation')) return 'google-slide';
  if (normalized == 'application/vnd.google-apps.folder') return 'folder';
  if (normalized == 'application/vnd.google-apps.shortcut') return 'shortcut';
  if (normalized.startsWith('image/')) return 'image';
  if (normalized.startsWith('video/')) return 'video';
  if (normalized.startsWith('audio/')) return 'audio';
  if (normalized.contains('pdf')) return 'pdf';
  if (normalized.startsWith('text/')) return 'text';
  return 'file';
}
