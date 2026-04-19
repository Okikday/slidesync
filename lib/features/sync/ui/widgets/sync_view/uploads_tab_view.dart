import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/features/sync/ui/components/transfer_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';

/// Tab showing active and completed uploads
class UploadsTabView extends ConsumerWidget {
  const UploadsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uploads = ref.watch(activeUploadsProvider);
    final allTransfers = ref.watch(transferStateProvider);

    // Get completed uploads from all transfers
    final completedUploads = allTransfers.values
        .where((t) => t.direction == TransferDirection.upload && t.status == TransferStatus.completed)
        .toList();

    // Combine active and recently completed
    final visibleUploads = [
      ...uploads,
      ...completedUploads.take(5), // Show last 5 completed
    ];

    if (visibleUploads.isEmpty) {
      return _buildEmptyState(ref);
    }

    return SmoothCustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList.builder(
            itemCount: visibleUploads.length,
            itemBuilder: (context, index) {
              final transfer = visibleUploads[index];
              return TransferCard(
                transfer: transfer,
                onPause: transfer.status == TransferStatus.inProgress ? () => _pauseUpload(ref, transfer.id) : null,
                onResume: transfer.status == TransferStatus.paused ? () => _resumeUpload(ref, transfer.id) : null,
                onCancel: transfer.status != TransferStatus.completed && transfer.status != TransferStatus.failed
                    ? () => _cancelUpload(ref, transfer.id)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build empty state widget showing no active uploads
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
              child: Icon(Icons.cloud_upload_outlined, size: 48, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            CustomText('No Active Uploads', fontSize: 18, fontWeight: FontWeight.w600, color: theme.onBackground),
            const SizedBox(height: 8),
            CustomText(
              'Uploaded files will appear here',
              fontSize: 12,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _pauseUpload(WidgetRef ref, String transferId) {
    // TODO: Implement pause functionality with upload manager
    ref.read(transferStateProvider.notifier).updateStatus(id: transferId, status: TransferStatus.paused);
  }

  void _resumeUpload(WidgetRef ref, String transferId) {
    // TODO: Implement resume functionality with upload manager
    ref.read(transferStateProvider.notifier).updateStatus(id: transferId, status: TransferStatus.inProgress);
  }

  void _cancelUpload(WidgetRef ref, String transferId) {
    // TODO: Implement cancel functionality with upload manager
    ref.read(transferStateProvider.notifier).removeTransfer(transferId);
  }
}
