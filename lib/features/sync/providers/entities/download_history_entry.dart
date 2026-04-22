import 'package:slidesync/features/sync/providers/entities/sync_type.dart';

class DownloadHistoryEntry {
  final String id;
  final String title;
  final SyncType type;
  final String? courseId;
  final String? collectionId;
  final String? contentId;
  final String? driveId;
  final String? sourceName;
  final int itemCount;
  final int totalBytes;
  final DateTime createdAt;
  final String? note;

  const DownloadHistoryEntry({
    required this.id,
    required this.title,
    required this.type,
    this.courseId,
    this.collectionId,
    this.contentId,
    this.driveId,
    this.sourceName,
    this.itemCount = 0,
    this.totalBytes = 0,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'courseId': courseId,
      'collectionId': collectionId,
      'contentId': contentId,
      'driveId': driveId,
      'sourceName': sourceName,
      'itemCount': itemCount,
      'totalBytes': totalBytes,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory DownloadHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    final typeName = map['type'] as String?;
    final type = SyncType.values.firstWhere((value) => value.name == typeName, orElse: () => SyncType.done);

    return DownloadHistoryEntry(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled download',
      type: type,
      courseId: map['courseId'] as String?,
      collectionId: map['collectionId'] as String?,
      contentId: map['contentId'] as String?,
      driveId: map['driveId'] as String?,
      sourceName: map['sourceName'] as String?,
      itemCount: (map['itemCount'] as num?)?.toInt() ?? 0,
      totalBytes: (map['totalBytes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      note: map['note'] as String?,
    );
  }
}
