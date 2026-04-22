import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'entities/sync_type.dart';
export 'entities/sync_type.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';

// ============================================================================
// LEGACY: Queue-based notifiers (for backward compatibility)
// ============================================================================

class _DownloadingQueueNotifier extends AsyncNotifier<Map<String, String>> {
  static const _hiveKey = 'downloads';

  @override
  Future<Map<String, String>> build() async {
    final stored = await AppHiveData.instance.getData<Map<dynamic, dynamic>>(key: _hiveKey);
    if (stored == null) return <String, String>{};
    return Map<String, String>.from(stored);
  }

  Future<void> _persist(Map<String, String> value) async {
    state = AsyncData(value);
    await AppHiveData.instance.setData(key: _hiveKey, value: value);
  }

  Future<void> addItems(Map<String, SyncType> items) async {
    if (items.isEmpty) return;
    final current = state.value ?? <String, String>{};
    final updated = {...current, ...items.map((k, v) => MapEntry(k, v.name))};
    await _persist(updated);
  }

  Future<void> removeItems(List<String> ids) async {
    if (ids.isEmpty) return;
    final current = state.value ?? <String, String>{};
    final updated = Map<String, String>.from(current)..removeWhere((key, _) => ids.contains(key));
    await _persist(updated);
  }

  Future<void> clear() async {
    await _persist(<String, String>{});
  }

  Future<void> updateType(String id, SyncType type) async {
    final current = state.value ?? <String, String>{};
    if (!current.containsKey(id)) return;
    final updated = Map<String, String>.from(current)..[id] = type.name;
    await _persist(updated);
  }
}

class _UploadingQueueNotifier extends AsyncNotifier<Map<String, String>> {
  static const _hiveKey = 'uploads';

  @override
  Future<Map<String, String>> build() async {
    final stored = await AppHiveData.instance.getData<Map<dynamic, dynamic>>(key: _hiveKey);
    if (stored == null) return <String, String>{};
    return Map<String, String>.from(stored);
  }

  Future<void> _persist(Map<String, String> value) async {
    state = AsyncData(value);
    await AppHiveData.instance.setData(key: _hiveKey, value: value);
  }

  Future<void> addItems(Map<String, SyncType> items) async {
    if (items.isEmpty) return;
    final current = state.value ?? <String, String>{};
    final updated = {...current, ...items.map((k, v) => MapEntry(k, v.name))};
    await _persist(updated);
  }

  Future<void> removeItems(List<String> ids) async {
    if (ids.isEmpty) return;
    final current = state.value ?? <String, String>{};
    final updated = Map<String, String>.from(current)..removeWhere((key, _) => ids.contains(key));
    await _persist(updated);
  }

  Future<void> clear() async {
    await _persist(<String, String>{});
  }

  Future<void> updateType(String id, SyncType type) async {
    final current = state.value ?? <String, String>{};
    if (!current.containsKey(id)) return;
    final updated = Map<String, String>.from(current)..[id] = type.name;
    await _persist(updated);
  }
}

final _downloadingProvider = AsyncNotifierProvider<_DownloadingQueueNotifier, Map<String, String>>(
  _DownloadingQueueNotifier.new,
);

final _uploadingProvider = AsyncNotifierProvider<_UploadingQueueNotifier, Map<String, String>>(
  _UploadingQueueNotifier.new,
);

class SyncProvider {
  SyncProvider._();
  static final instance = SyncProvider._();

  // =========================================================================
  // Download Operations (Legacy)
  // =========================================================================

  bool isDownloading(WidgetRef ref) {
    return ref.watch(_downloadingProvider.select((state) => state.value?.isNotEmpty ?? false));
  }

  bool hasDownload(WidgetRef ref, String id) {
    return ref.watch(_downloadingProvider.select((state) => state.value?.containsKey(id) ?? false));
  }

  SyncType? getDownloadType(WidgetRef ref, String id) {
    final typeName = ref.watch(_downloadingProvider.select((state) => state.value?[id]));
    return typeName != null ? SyncType.values.firstWhere((e) => e.name == typeName) : null;
  }

  int downloadCount(WidgetRef ref) {
    return ref.watch(_downloadingProvider.select((state) => state.value?.length ?? 0));
  }

  Future<void> addToDownloadingQueue(WidgetRef ref, {required Map<String, SyncType> toDownload}) async {
    await ref.read(_downloadingProvider.notifier).addItems(toDownload);
  }

  Future<void> removeFromDownloadingQueue(WidgetRef ref, {required List<String> ids}) async {
    await ref.read(_downloadingProvider.notifier).removeItems(ids);
  }

  Future<void> clearDownloadingQueue(WidgetRef ref) async {
    await ref.read(_downloadingProvider.notifier).clear();
  }

  Future<void> updateDownloadType(WidgetRef ref, {required String id, required SyncType type}) async {
    await ref.read(_downloadingProvider.notifier).updateType(id, type);
  }

  // =========================================================================
  // Upload Operations (Legacy)
  // =========================================================================

  bool isUploading(WidgetRef ref) {
    return ref.watch(_uploadingProvider.select((state) => state.value?.isNotEmpty ?? false));
  }

  bool hasUpload(WidgetRef ref, String id) {
    return ref.watch(_uploadingProvider.select((state) => state.value?.containsKey(id) ?? false));
  }

  SyncType? getUploadType(WidgetRef ref, String id) {
    final typeName = ref.watch(_uploadingProvider.select((state) => state.value?[id]));
    return typeName != null ? SyncType.values.firstWhere((e) => e.name == typeName) : null;
  }

  int uploadCount(WidgetRef ref) {
    return ref.watch(_uploadingProvider.select((state) => state.value?.length ?? 0));
  }

  Future<void> addToUploadingQueue(WidgetRef ref, {required Map<String, SyncType> toUpload}) async {
    await ref.read(_uploadingProvider.notifier).addItems(toUpload);
  }

  Future<void> removeFromUploadingQueue(WidgetRef ref, {required List<String> ids}) async {
    await ref.read(_uploadingProvider.notifier).removeItems(ids);
  }

  Future<void> clearUploadingQueue(WidgetRef ref) async {
    await ref.read(_uploadingProvider.notifier).clear();
  }

  Future<void> updateUploadType(WidgetRef ref, {required String id, required SyncType type}) async {
    await ref.read(_uploadingProvider.notifier).updateType(id, type);
  }

  // =========================================================================
  // Combined Operations (Legacy)
  // =========================================================================

  bool isSyncing(WidgetRef ref) {
    return isDownloading(ref) || isUploading(ref);
  }

  int totalSyncCount(WidgetRef ref) {
    return downloadCount(ref) + uploadCount(ref);
  }

  Future<void> clearAllQueues(WidgetRef ref) async {
    await Future.wait([clearDownloadingQueue(ref), clearUploadingQueue(ref)]);
  }
}

// ============================================================================
// Extension for easier access
// ============================================================================

extension SyncProviderExtension on WidgetRef {
  SyncProvider get sync => SyncProvider.instance;
}
