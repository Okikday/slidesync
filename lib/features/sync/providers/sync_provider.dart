import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

enum SyncType { done, course, collection, content }

// Providers
final _downloadingProvider = AsyncNotifierProvider(
  () => HiveAsyncImpliedNotifierN<Map<String, String>>(HiveDataPathKey.downloads.name, defaultKey: <String, String>{}),
);

final _uploadingProvider = AsyncNotifierProvider(
  () => HiveAsyncImpliedNotifierN<Map<String, String>>(HiveDataPathKey.uploads.name, defaultKey: <String, String>{}),
);

class SyncProvider {
  SyncProvider._();
  static final instance = SyncProvider._();

  // =========================================================================
  // Provider Accessors
  // =========================================================================

  static AsyncNotifierProvider<HiveAsyncImpliedNotifierN<Map<String, String>>, Map<String, String>?>
  get downloadingProvider => _downloadingProvider;

  static AsyncNotifierProvider<HiveAsyncImpliedNotifierN<Map<String, String>>, Map<String, String>?>
  get uploadingProvider => _uploadingProvider;

  // =========================================================================
  // Download Operations
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
    if (toDownload.isEmpty) return;

    final currentMap = ref.read(_downloadingProvider).value ?? <String, String>{};
    final updatedMap = {...currentMap, ...toDownload.map((k, v) => MapEntry(k, v.name))};

    await ref.read(_downloadingProvider.notifier).scheduleUpdating(updatedMap);
  }

  Future<void> removeFromDownloadingQueue(WidgetRef ref, {required List<String> ids}) async {
    if (ids.isEmpty) return;

    final currentMap = ref.read(_downloadingProvider).value ?? <String, String>{};
    final updatedMap = Map<String, String>.from(currentMap)..removeWhere((key, _) => ids.contains(key));

    await ref.read(_downloadingProvider.notifier).scheduleUpdating(updatedMap);
  }

  Future<void> clearDownloadingQueue(WidgetRef ref) async {
    await ref.read(_downloadingProvider.notifier).scheduleUpdating(<String, String>{});
  }

  Future<void> updateDownloadType(WidgetRef ref, {required String id, required SyncType type}) async {
    final currentMap = ref.read(_downloadingProvider).value ?? <String, String>{};
    if (!currentMap.containsKey(id)) return;

    final updatedMap = Map<String, String>.from(currentMap)..[id] = type.name;
    await ref.read(_downloadingProvider.notifier).scheduleUpdating(updatedMap);
  }

  // =========================================================================
  // Upload Operations
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
    if (toUpload.isEmpty) return;

    final currentMap = ref.read(_uploadingProvider).value ?? <String, String>{};
    final updatedMap = {...currentMap, ...toUpload.map((k, v) => MapEntry(k, v.name))};

    await ref.read(_uploadingProvider.notifier).scheduleUpdating(updatedMap);
  }

  Future<void> removeFromUploadingQueue(WidgetRef ref, {required List<String> ids}) async {
    if (ids.isEmpty) return;

    final currentMap = ref.read(_uploadingProvider).value ?? <String, String>{};
    final updatedMap = Map<String, String>.from(currentMap)..removeWhere((key, _) => ids.contains(key));

    await ref.read(_uploadingProvider.notifier).scheduleUpdating(updatedMap);
  }

  Future<void> clearUploadingQueue(WidgetRef ref) async {
    await ref.read(_uploadingProvider.notifier).scheduleUpdating(<String, String>{});
  }

  Future<void> updateUploadType(WidgetRef ref, {required String id, required SyncType type}) async {
    final currentMap = ref.read(_uploadingProvider).value ?? <String, String>{};
    if (!currentMap.containsKey(id)) return;

    final updatedMap = Map<String, String>.from(currentMap)..[id] = type.name;
    await ref.read(_uploadingProvider.notifier).scheduleUpdating(updatedMap);
  }

  // =========================================================================
  // Combined Operations
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
