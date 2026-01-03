import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/logic/sync_service.dart';
import 'package:slidesync/features/sync/providers/sync_provider.dart';
import 'package:slidesync/features/sync/ui/components/sync_card.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class DownloadsTabView extends ConsumerStatefulWidget {
  const DownloadsTabView({super.key});

  @override
  ConsumerState<DownloadsTabView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends ConsumerState<DownloadsTabView> {
  @override
  Widget build(BuildContext context) {
    final syncService = SyncService.instance;
    final downloadingMap = ref.watch(SyncProvider.downloadingProvider).value ?? {};

    if (downloadingMap.isEmpty) {
      return Center(child: Text('No active downloads'));
    }

    return SmoothCustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: downloadingMap.length,
          itemBuilder: (context, index) {
            final entry = downloadingMap.entries.elementAt(index);
            final id = entry.key;
            final syncType = SyncType.values.firstWhere((e) => e.name == entry.value);

            // Create TransferCardData from download state
            final data = TransferCardData(
              id: id,
              title: 'Downloading ${syncType.name}',
              type: _mapSyncTypeToTransferType(syncType),
              direction: TransferDirection.download,
              state: TransferState.downloading,
              progress: 0.5, // TODO: Get real progress
              totalSize: 1000000,
              startedAt: DateTime.now(),
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TransferCard(
                data: data,
                onPause: () => syncService.pauseDownload(id),
                onResume: () => syncService.resumeDownload(id),
                onCancel: () => syncService.cancelDownload(ref, id),
              ),
            );
          },
        ),
      ],
    );
  }

  TransferType _mapSyncTypeToTransferType(SyncType syncType) {
    switch (syncType) {
      case SyncType.course:
        return TransferType.course;
      case SyncType.collection:
        return TransferType.collection;
      case SyncType.content:
        return TransferType.content;
      default:
        return TransferType.content;
    }
  }
}
