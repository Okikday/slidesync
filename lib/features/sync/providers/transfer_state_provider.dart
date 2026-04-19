import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single ongoing transfer (upload or download)
class TransferState {
  final String id;
  final String title;
  final TransferType type;
  final TransferDirection direction;
  final double progress; // 0.0 to 1.0
  final int uploadedBytes;
  final int totalBytes;
  final DateTime startedAt;
  final TransferStatus status;

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
  });

  /// Calculate elapsed time since transfer started
  Duration get elapsed => DateTime.now().difference(startedAt);

  /// Estimate time remaining based on current progress
  Duration? get estimatedTimeRemaining {
    if (progress <= 0 || progress >= 1.0) return null;
    final bytesPerSecond = uploadedBytes / elapsed.inMilliseconds * 1000;
    if (bytesPerSecond <= 0) return null;
    final remainingBytes = totalBytes - uploadedBytes;
    return Duration(milliseconds: (remainingBytes / bytesPerSecond * 1000).toInt());
  }

  /// Human-readable upload/download speed in MB/s or KB/s
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

  /// Human-readable total size
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

/// Notifier for managing transfer state
class TransferStateNotifier extends Notifier<Map<String, TransferState>> {
  @override
  Map<String, TransferState> build() => {};

  /// Add or update a transfer
  void upsertTransfer(TransferState transfer) {
    state = {...state, transfer.id: transfer};
  }

  /// Update progress of a transfer
  void updateProgress({required String id, required double progress, required int uploadedBytes}) {
    final existing = state[id];
    if (existing != null) {
      state = {...state, id: existing.copyWith(progress: progress.clamp(0.0, 1.0), uploadedBytes: uploadedBytes)};
    }
  }

  /// Update status of a transfer
  void updateStatus({required String id, required TransferStatus status}) {
    final existing = state[id];
    if (existing != null) {
      state = {...state, id: existing.copyWith(status: status)};
    }
  }

  /// Remove a transfer
  void removeTransfer(String id) {
    state = {...state}..remove(id);
  }

  /// Clear all transfers
  void clearAll() {
    state = {};
  }

  /// Get transfer by ID
  TransferState? getTransfer(String id) => state[id];

  /// Get all transfers for a given direction
  List<TransferState> getTransfersByDirection(TransferDirection direction) {
    return state.values.where((t) => t.direction == direction).toList();
  }

  /// Check if any transfer is in progress
  bool get hasInProgress => state.values.any((t) => t.status == TransferStatus.inProgress);
}

/// Extension for copyWith pattern (manually implemented for simplicity)
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
    );
  }
}

/// Riverpod 3.0 Provider: Global transfer state management
final transferStateProvider = NotifierProvider<TransferStateNotifier, Map<String, TransferState>>(
  TransferStateNotifier.new,
);

/// Selector: Get all active downloads
final activeDownloadsProvider = Provider<List<TransferState>>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values
      .where((t) => t.direction == TransferDirection.download && t.status == TransferStatus.inProgress)
      .toList();
});

/// Selector: Get all active uploads
final activeUploadsProvider = Provider<List<TransferState>>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values
      .where((t) => t.direction == TransferDirection.upload && t.status == TransferStatus.inProgress)
      .toList();
});

/// Selector: Combined active transfers
final activeSyncProvider = Provider<List<TransferState>>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values.where((t) => t.status == TransferStatus.inProgress).toList();
});

/// Selector: Count of active downloads
final downloadCountProvider = Provider<int>((ref) {
  return ref.watch(activeDownloadsProvider).length;
});

/// Selector: Count of active uploads
final uploadCountProvider = Provider<int>((ref) {
  return ref.watch(activeUploadsProvider).length;
});

/// Selector: Total bytes uploaded across all active transfers
final totalUploadedBytesProvider = Provider<int>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values.fold(0, (sum, t) => sum + t.uploadedBytes);
});

/// Selector: Check if ANY transfer is in progress
final isSyncingProvider = Provider<bool>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values.any((t) => t.status == TransferStatus.inProgress);
});
