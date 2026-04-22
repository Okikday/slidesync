import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/entities/transfer_state.dart';

class TransferStateNotifier extends Notifier<Map<String, TransferState>> {
  @override
  Map<String, TransferState> build() => {};

  void upsertTransfer(TransferState transfer) {
    state = {...state, transfer.id: transfer};
  }

  void updateProgress({required String id, required double progress, required int uploadedBytes, int? totalBytes}) {
    final existing = state[id];
    if (existing != null) {
      state = {
        ...state,
        id: existing.copyWith(
          progress: progress.clamp(0.0, 1.0),
          uploadedBytes: uploadedBytes,
          totalBytes: totalBytes ?? existing.totalBytes,
        ),
      };
    }
  }

  void updateStatus({required String id, required TransferStatus status}) {
    final existing = state[id];
    if (existing != null) {
      state = {...state, id: existing.copyWith(status: status)};
    }
  }

  void removeTransfer(String id) {
    state = {...state}..remove(id);
  }

  void clearAll() {
    state = {};
  }

  TransferState? getTransfer(String id) => state[id];

  List<TransferState> getTransfersByDirection(TransferDirection direction) {
    return state.values.where((t) => t.direction == direction).toList();
  }

  bool get hasInProgress => state.values.any((t) => t.status == TransferStatus.inProgress);

  bool hasTransferWithSourceKey(String sourceKey) {
    return state.values.any((transfer) => transfer.sourceKey != null && transfer.sourceKey == sourceKey);
  }
}

final transferStateProvider = NotifierProvider<TransferStateNotifier, Map<String, TransferState>>(
  TransferStateNotifier.new,
);

final activeDownloadsProvider = Provider<List<TransferState>>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values
      .where((t) => t.direction == TransferDirection.download && t.status == TransferStatus.inProgress)
      .toList();
});

final activeUploadsProvider = Provider<List<TransferState>>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values
      .where((t) => t.direction == TransferDirection.upload && t.status == TransferStatus.inProgress)
      .toList();
});

final activeSyncProvider = Provider<List<TransferState>>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values.where((t) => t.status == TransferStatus.inProgress).toList();
});

final downloadCountProvider = Provider<int>((ref) {
  return ref.watch(activeDownloadsProvider).length;
});

final uploadCountProvider = Provider<int>((ref) {
  return ref.watch(activeUploadsProvider).length;
});

final totalUploadedBytesProvider = Provider<int>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values.fold(0, (sum, t) => sum + t.uploadedBytes);
});

final isSyncingProvider = Provider<bool>((ref) {
  final transfers = ref.watch(transferStateProvider);
  return transfers.values.any((t) => t.status == TransferStatus.inProgress);
});
