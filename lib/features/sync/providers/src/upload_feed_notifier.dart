import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/features/sync/providers/entities/upload_feed_state.dart';

class UploadFeedNotifier extends Notifier<Map<String, UploadFeedState>> {
  @override
  Map<String, UploadFeedState> build() => {};

  void start({
    required String id,
    required String title,
    required SyncType type,
    int totalBytes = 0,
    String? courseId,
    String? collectionId,
    String? contentId,
    String? logMessage,
  }) {
    final now = DateTime.now();
    state = {
      ...state,
      id: UploadFeedState(
        id: id,
        title: title,
        type: type,
        status: UploadFeedStatus.running,
        progress: 0.0,
        uploadedBytes: 0,
        totalBytes: totalBytes,
        startedAt: now,
        updatedAt: now,
        courseId: courseId,
        collectionId: collectionId,
        contentId: contentId,
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
    state = {...state, id: existing.copyWith(status: UploadFeedStatus.paused, updatedAt: DateTime.now())};
  }

  void resume(String id) {
    final existing = state[id];
    if (existing == null) return;
    state = {...state, id: existing.copyWith(status: UploadFeedStatus.running, updatedAt: DateTime.now())};
  }

  void complete(String id, {String? note, String? contentId, String? collectionId, String? courseId}) {
    final existing = state[id];
    if (existing == null) return;
    state = {
      ...state,
      id: existing.copyWith(
        status: UploadFeedStatus.completed,
        progress: 1.0,
        uploadedBytes: existing.totalBytes > 0 ? existing.totalBytes : existing.uploadedBytes,
        note: note ?? existing.note,
        contentId: contentId ?? existing.contentId,
        collectionId: collectionId ?? existing.collectionId,
        courseId: courseId ?? existing.courseId,
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
        status: UploadFeedStatus.failed,
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
        status: UploadFeedStatus.cancelled,
        note: message ?? existing.note,
        updatedAt: DateTime.now(),
        logs: message == null ? existing.logs : [...existing.logs, message],
      ),
    };
  }

  void clearInactive() {
    final retained = <String, UploadFeedState>{
      for (final entry in state.entries)
        if (entry.value.isActive) entry.key: entry.value,
    };
    state = retained;
  }
}

final uploadFeedProvider = NotifierProvider<UploadFeedNotifier, Map<String, UploadFeedState>>(UploadFeedNotifier.new);

final activeUploadFeedProvider = Provider<List<UploadFeedState>>((ref) {
  final uploads = ref.watch(uploadFeedProvider);
  final active = uploads.values.where((item) => item.isActive).toList(growable: false);
  active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return active;
});
