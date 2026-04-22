import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/features/sync/providers/entities/transfer_state.dart';

class UploadFeedState {
  final String id;
  final String title;
  final SyncType type;
  final UploadFeedStatus status;
  final double progress;
  final int uploadedBytes;
  final int totalBytes;
  final DateTime startedAt;
  final DateTime updatedAt;
  final String? courseId;
  final String? collectionId;
  final String? contentId;
  final String? note;
  final List<String> logs;

  const UploadFeedState({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.progress,
    required this.uploadedBytes,
    required this.totalBytes,
    required this.startedAt,
    required this.updatedAt,
    this.courseId,
    this.collectionId,
    this.contentId,
    this.note,
    this.logs = const [],
  });

  bool get isActive =>
      status == UploadFeedStatus.queued || status == UploadFeedStatus.running || status == UploadFeedStatus.paused;

  TransferState toTransferState() {
    return TransferState(
      id: id,
      title: title,
      type: switch (type) {
        SyncType.course => TransferType.course,
        SyncType.collection => TransferType.collection,
        SyncType.content || SyncType.done => TransferType.content,
      },
      direction: TransferDirection.upload,
      progress: progress,
      uploadedBytes: uploadedBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
      status: switch (status) {
        UploadFeedStatus.queued => TransferStatus.pending,
        UploadFeedStatus.running => TransferStatus.inProgress,
        UploadFeedStatus.paused => TransferStatus.paused,
        UploadFeedStatus.completed => TransferStatus.completed,
        UploadFeedStatus.failed => TransferStatus.failed,
        UploadFeedStatus.cancelled => TransferStatus.cancelled,
      },
      sourceKey: contentId ?? collectionId ?? courseId,
    );
  }

  UploadFeedState copyWith({
    String? id,
    String? title,
    SyncType? type,
    UploadFeedStatus? status,
    double? progress,
    int? uploadedBytes,
    int? totalBytes,
    DateTime? startedAt,
    DateTime? updatedAt,
    String? courseId,
    String? collectionId,
    String? contentId,
    String? note,
    List<String>? logs,
  }) {
    return UploadFeedState(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courseId: courseId ?? this.courseId,
      collectionId: collectionId ?? this.collectionId,
      contentId: contentId ?? this.contentId,
      note: note ?? this.note,
      logs: logs ?? this.logs,
    );
  }
}

enum UploadFeedStatus { queued, running, paused, completed, failed, cancelled }
