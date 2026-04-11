/// Unified progress model for both uploads and downloads.
/// Streamed from resumable operations so UI can bind directly.
class DriveProgress {
  final int bytesTransferred;
  final int totalBytes;
  final DriveProgressState state;
  final String? error;

  /// Local file path — populated on download completion.
  final String? localPath;

  /// Remote Drive file ID — populated on upload completion.
  final String? driveFileId;

  const DriveProgress({
    required this.bytesTransferred,
    required this.totalBytes,
    required this.state,
    this.error,
    this.localPath,
    this.driveFileId,
  });

  double get progress =>
      totalBytes > 0 ? (bytesTransferred / totalBytes).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progress * 100).round();

  bool get isDone => state == DriveProgressState.done;
  bool get isFailed => state == DriveProgressState.failed;
  bool get isPaused => state == DriveProgressState.paused;
  bool get isActive => state == DriveProgressState.active;

  String get formattedProgress {
    final transferred = formatBytes(bytesTransferred);
    final total = formatBytes(totalBytes);
    return '$transferred / $total ($progressPercent%)';
  }

  DriveProgress copyWith({
    int? bytesTransferred,
    int? totalBytes,
    DriveProgressState? state,
    String? error,
    String? localPath,
    String? driveFileId,
  }) =>
      DriveProgress(
        bytesTransferred: bytesTransferred ?? this.bytesTransferred,
        totalBytes: totalBytes ?? this.totalBytes,
        state: state ?? this.state,
        error: error ?? this.error,
        localPath: localPath ?? this.localPath,
        driveFileId: driveFileId ?? this.driveFileId,
      );

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ── Named constructors for convenience ─────────────────────────────────────

  const DriveProgress.starting({required int totalBytes})
      : this(
          bytesTransferred: 0,
          totalBytes: totalBytes,
          state: DriveProgressState.active,
        );

  const DriveProgress.paused({
    required int bytesTransferred,
    required int totalBytes,
  }) : this(
          bytesTransferred: bytesTransferred,
          totalBytes: totalBytes,
          state: DriveProgressState.paused,
        );

  factory DriveProgress.done({
    required int totalBytes,
    String? localPath,
    String? driveFileId,
  }) =>
      DriveProgress(
        bytesTransferred: totalBytes,
        totalBytes: totalBytes,
        state: DriveProgressState.done,
        localPath: localPath,
        driveFileId: driveFileId,
      );

  factory DriveProgress.failed(String error, {int bytesTransferred = 0, int totalBytes = 0}) =>
      DriveProgress(
        bytesTransferred: bytesTransferred,
        totalBytes: totalBytes,
        state: DriveProgressState.failed,
        error: error,
      );
}

enum DriveProgressState { active, paused, done, failed }

/// Persisted state for a resumable operation so it can survive app kills.
class ResumableSession {
  final String operationId; // unique per operation, stored locally
  final String sessionUri; // Drive resumable upload URI (uploads only)
  final int bytesTransferred;
  final int totalBytes;
  final String filePath; // local file path (source for upload, dest for download)
  final String? driveFileId; // populated after upload completes

  const ResumableSession({
    required this.operationId,
    required this.sessionUri,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.filePath,
    this.driveFileId,
  });

  Map<String, dynamic> toJson() => {
        'operationId': operationId,
        'sessionUri': sessionUri,
        'bytesTransferred': bytesTransferred,
        'totalBytes': totalBytes,
        'filePath': filePath,
        'driveFileId': driveFileId,
      };

  factory ResumableSession.fromJson(Map<String, dynamic> j) => ResumableSession(
        operationId: j['operationId'] as String,
        sessionUri: j['sessionUri'] as String,
        bytesTransferred: j['bytesTransferred'] as int,
        totalBytes: j['totalBytes'] as int,
        filePath: j['filePath'] as String,
        driveFileId: j['driveFileId'] as String?,
      );
}
