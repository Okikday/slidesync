import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/entities/download_feed_state.dart';
import 'package:slidesync/features/sync/providers/entities/sync_type.dart';

class DownloadFeedNotifier extends Notifier<Map<String, DownloadFeedState>> {
  @override
  Map<String, DownloadFeedState> build() => {};

  void start({
    required String id,
    required String title,
    required SyncType type,
    int totalBytes = 0,
    String? collectionId,
    String? contentId,
    String? driveId,
    String? sourceName,
    String? logMessage,
  }) {
    final now = DateTime.now();
    state = {
      ...state,
      id: DownloadFeedState(
        id: id,
        title: title,
        type: type,
        status: DownloadFeedStatus.running,
        progress: 0.0,
        uploadedBytes: 0,
        totalBytes: totalBytes,
        startedAt: now,
        updatedAt: now,
        collectionId: collectionId,
        contentId: contentId,
        driveId: driveId,
        sourceName: sourceName,
        logs: logMessage == null ? const [] : [logMessage],
      ),
    };
  }

  void updateProgress({
    required String id,
    required double progress,
    required int uploadedBytes,
    int? totalBytes,
    String? logMessage,
  }) {
    final existing = state[id];
    if (existing == null) return;

    state = {
      ...state,
      id: existing.copyWith(
        progress: progress.clamp(0.0, 1.0),
        uploadedBytes: uploadedBytes,
        totalBytes: totalBytes ?? existing.totalBytes,
        updatedAt: DateTime.now(),
        logs: logMessage == null ? existing.logs : [...existing.logs, logMessage],
      ),
    };
  }

  void appendLog(String id, String message) {
    final existing = state[id];
    if (existing == null) return;

    state = {
      ...state,
      id: existing.copyWith(updatedAt: DateTime.now(), logs: [...existing.logs, message]),
    };
  }

  void pause(String id) {
    final existing = state[id];
    if (existing == null) return;
    state = {...state, id: existing.copyWith(status: DownloadFeedStatus.paused, updatedAt: DateTime.now())};
  }

  void resume(String id) {
    final existing = state[id];
    if (existing == null) return;
    state = {...state, id: existing.copyWith(status: DownloadFeedStatus.running, updatedAt: DateTime.now())};
  }

  void complete(String id, {String? note, String? contentId, String? collectionId, String? driveId}) {
    final existing = state[id];
    if (existing == null) return;
    state = {
      ...state,
      id: existing.copyWith(
        status: DownloadFeedStatus.completed,
        progress: 1.0,
        uploadedBytes: existing.totalBytes > 0 ? existing.totalBytes : existing.uploadedBytes,
        note: note ?? existing.note,
        contentId: contentId ?? existing.contentId,
        collectionId: collectionId ?? existing.collectionId,
        driveId: driveId ?? existing.driveId,
        updatedAt: DateTime.now(),
        logs: note == null ? existing.logs : [...existing.logs, note],
      ),
    };
  }

  void fail(String id, String message) {
    final existing = state[id];
    if (existing == null) return;
    state = {
      ...state,
      id: existing.copyWith(
        status: DownloadFeedStatus.failed,
        note: message,
        updatedAt: DateTime.now(),
        logs: [...existing.logs, message],
      ),
    };
  }

  void cancel(String id, {String? message}) {
    final existing = state[id];
    if (existing == null) return;
    state = {
      ...state,
      id: existing.copyWith(
        status: DownloadFeedStatus.cancelled,
        note: message ?? existing.note,
        updatedAt: DateTime.now(),
        logs: message == null ? existing.logs : [...existing.logs, message],
      ),
    };
  }

  void remove(String id) {
    state = {...state}..remove(id);
  }

  void clearAll() {
    state = {};
  }

  void clearInactive() {
    final retained = <String, DownloadFeedState>{
      for (final entry in state.entries)
        if (entry.value.isActive) entry.key: entry.value,
    };
    state = retained;
  }
}

final downloadFeedProvider = NotifierProvider<DownloadFeedNotifier, Map<String, DownloadFeedState>>(
  DownloadFeedNotifier.new,
);

final activeDownloadFeedProvider = Provider<List<DownloadFeedState>>((ref) {
  final downloads = ref.watch(downloadFeedProvider);
  final active = downloads.values.where((item) => item.isActive).toList(growable: false);
  active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return active;
});
