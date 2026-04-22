class TransferState {
  final String id;
  final String title;
  final TransferType type;
  final TransferDirection direction;
  final double progress;
  final int uploadedBytes;
  final int totalBytes;
  final DateTime startedAt;
  final TransferStatus status;
  final String? sourceKey;

  const TransferState({
    required this.id,
    required this.title,
    required this.type,
    required this.direction,
    required this.progress,
    required this.uploadedBytes,
    required this.totalBytes,
    required this.startedAt,
    required this.status,
    this.sourceKey,
  });

  Duration get elapsed => DateTime.now().difference(startedAt);

  Duration? get estimatedTimeRemaining {
    if (progress <= 0 || progress >= 1.0) return null;
    final bytesPerSecond = uploadedBytes / elapsed.inMilliseconds * 1000;
    if (bytesPerSecond <= 0) return null;
    final remainingBytes = totalBytes - uploadedBytes;
    return Duration(milliseconds: (remainingBytes / bytesPerSecond * 1000).toInt());
  }

  String get speedString {
    final bytesPerSecond = uploadedBytes / (elapsed.inMilliseconds / 1000);
    if (bytesPerSecond > 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    } else if (bytesPerSecond > 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    }
  }

  String get sizeString {
    if (totalBytes > 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (totalBytes > 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$totalBytes B';
    }
  }

  @override
  String toString() => 'TransferState($id, $direction, $status, ${(progress * 100).toStringAsFixed(0)}%)';
}

enum TransferType { course, collection, content }

enum TransferDirection { upload, download }

enum TransferStatus { pending, inProgress, paused, completed, failed, cancelled }

extension TransferStateCopyWith on TransferState {
  TransferState copyWith({
    String? id,
    String? title,
    TransferType? type,
    TransferDirection? direction,
    double? progress,
    int? uploadedBytes,
    int? totalBytes,
    DateTime? startedAt,
    TransferStatus? status,
    String? sourceKey,
  }) {
    return TransferState(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      progress: progress ?? this.progress,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      sourceKey: sourceKey ?? this.sourceKey,
    );
  }
}
