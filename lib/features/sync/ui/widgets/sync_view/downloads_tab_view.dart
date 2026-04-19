import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/features/sync/ui/components/transfer_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';

/// Tab showing active and completed downloads
class DownloadsTabView extends ConsumerWidget {
  const DownloadsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final downloads = ref.watch(activeDownloadsProvider);
    final allTransfers = ref.watch(transferStateProvider);

    // Get completed downloads from all transfers
    final completedDownloads = allTransfers.values
        .where((t) => t.direction == TransferDirection.download && t.status == TransferStatus.completed)
        .toList();

    // Combine active and recently completed
    final visibleDownloads = [
      ...downloads,
      ...completedDownloads.take(5), // Show last 5 completed
    ];

    if (visibleDownloads.isEmpty) {
      return _buildEmptyState(ref);
    }

    return SmoothCustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList.builder(
            itemCount: visibleDownloads.length,
            itemBuilder: (context, index) {
              final transfer = visibleDownloads[index];
              return TransferCard(
                transfer: transfer,
                onPause: transfer.status == TransferStatus.inProgress ? () => _pauseDownload(ref, transfer.id) : null,
                onResume: transfer.status == TransferStatus.paused ? () => _resumeDownload(ref, transfer.id) : null,
                onCancel: transfer.status != TransferStatus.completed && transfer.status != TransferStatus.failed
                    ? () => _cancelDownload(ref, transfer.id)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build empty state widget showing no active downloads
  Widget _buildEmptyState(WidgetRef ref) {
    final theme = ref;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.cloud_download_outlined, size: 48, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            CustomText('No Active Downloads', fontSize: 18, fontWeight: FontWeight.w600, color: theme.onBackground),
            const SizedBox(height: 8),
            CustomText(
              'Downloaded files will appear here',
              fontSize: 12,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _pauseDownload(WidgetRef ref, String transferId) {
    // TODO: Implement pause functionality with download manager
    ref.read(transferStateProvider.notifier).updateStatus(id: transferId, status: TransferStatus.paused);
  }

  void _resumeDownload(WidgetRef ref, String transferId) {
    // TODO: Implement resume functionality with download manager
    ref.read(transferStateProvider.notifier).updateStatus(id: transferId, status: TransferStatus.inProgress);
  }

  void _cancelDownload(WidgetRef ref, String transferId) {
    // TODO: Implement cancel functionality with download manager
    ref.read(transferStateProvider.notifier).removeTransfer(transferId);
  }
}
