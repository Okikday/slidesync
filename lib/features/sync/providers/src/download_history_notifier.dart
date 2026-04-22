import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/sync/providers/entities/download_history_entry.dart';
import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class DownloadHistoryNotifier extends HiveAsyncImpliedNotifierN<List<dynamic>, List<Map<String, dynamic>>> {
  DownloadHistoryNotifier()
    : super(
        HiveDataPathKey.downloadHistory.name,
        defaultKey: const [],
        builder: (data) {
          if (data is List) {
            return data.whereType<Map>().map((entry) => Map<String, dynamic>.from(entry)).toList(growable: false);
          }
          return const <Map<String, dynamic>>[];
        },
      );

  List<DownloadHistoryEntry> get entries {
    return (state.value ?? const <Map<String, dynamic>>[])
        .map(DownloadHistoryEntry.fromMap)
        .where((entry) => entry.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> addEntry(DownloadHistoryEntry entry) async {
    final current = List<Map<String, dynamic>>.from(state.value ?? const <Map<String, dynamic>>[]);
    current.insert(0, entry.toMap());
    await scheduleUpdating(current);
  }

  Future<void> removeEntry(String id) async {
    final current = List<Map<String, dynamic>>.from(state.value ?? const <Map<String, dynamic>>[])
      ..removeWhere((entry) => entry['id'] == id);
    await scheduleUpdating(current);
  }

  Future<void> clearEntries() async {
    await scheduleUpdating(const <Map<String, dynamic>>[]);
  }
}

final downloadHistoryProvider = AsyncNotifierProvider.autoDispose<DownloadHistoryNotifier, List<Map<String, dynamic>>?>(
  DownloadHistoryNotifier.new,
);

final downloadHistoryFilterProvider = StateProvider.autoDispose<SyncType?>((ref) => null);
