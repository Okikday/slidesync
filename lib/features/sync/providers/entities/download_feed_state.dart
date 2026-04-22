import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/features/sync/providers/entities/transfer_state.dart';

class DownloadFeedState {
  final String id;
  final String title;
  final SyncType type;
  final DownloadFeedStatus status;
  final double progress;
  final int uploadedBytes;
  final int totalBytes;
  final DateTime startedAt;
  final DateTime updatedAt;
  final String? collectionId;
  final String? contentId;
  final String? driveId;
  final String? sourceName;
  final String? note;
  final List<String> logs;

  const DownloadFeedState({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.progress,
    required this.uploadedBytes,
    required this.totalBytes,
    required this.startedAt,
    required this.updatedAt,
    this.collectionId,
    this.contentId,
    this.driveId,
    this.sourceName,
    this.note,
    this.logs = const [],
  });

  bool get isActive =>
      status == DownloadFeedStatus.queued ||
      status == DownloadFeedStatus.running ||
      status == DownloadFeedStatus.paused;

  TransferState toTransferState() {
    return TransferState(
      id: id,
      title: title,
      type: switch (type) {
        SyncType.course => TransferType.course,
        SyncType.collection => TransferType.collection,
        SyncType.content || SyncType.done => TransferType.content,
      },
      direction: TransferDirection.download,
      progress: progress,
      uploadedBytes: uploadedBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
      status: switch (status) {
        DownloadFeedStatus.queued => TransferStatus.pending,
        DownloadFeedStatus.running => TransferStatus.inProgress,
        DownloadFeedStatus.paused => TransferStatus.paused,
        DownloadFeedStatus.completed => TransferStatus.completed,
        DownloadFeedStatus.failed => TransferStatus.failed,
        DownloadFeedStatus.cancelled => TransferStatus.cancelled,
      },
      sourceKey: driveId ?? contentId ?? collectionId,
    );
  }

  DownloadFeedState copyWith({
    String? id,
    String? title,
    SyncType? type,
    DownloadFeedStatus? status,
    double? progress,
    int? uploadedBytes,
    int? totalBytes,
    DateTime? startedAt,
    DateTime? updatedAt,
    String? collectionId,
    String? contentId,
    String? driveId,
    String? sourceName,
    String? note,
    List<String>? logs,
  }) {
    return DownloadFeedState(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collectionId: collectionId ?? this.collectionId,
      contentId: contentId ?? this.contentId,
      driveId: driveId ?? this.driveId,
      sourceName: sourceName ?? this.sourceName,
      note: note ?? this.note,
      logs: logs ?? this.logs,
    );
  }
}

enum DownloadFeedStatus { queued, running, paused, completed, failed, cancelled }
