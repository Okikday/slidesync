import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/features/sync/providers/selection_provider.dart';
import 'package:slidesync/features/sync/ui/components/transfer_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';

/// Tab showing active and completed uploads
class UploadsTabView extends ConsumerStatefulWidget {
  const UploadsTabView({super.key});

  @override
  ConsumerState<UploadsTabView> createState() => _UploadsTabViewState();
}

class _UploadsTabViewState extends ConsumerState<UploadsTabView> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final uploads = ref.watch(activeUploadsProvider);
    final allTransfers = ref.watch(transferStateProvider);
    final selection = ref.watch(uploadSelectionProvider);

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
        // Selection chips when items are selected
        if (selection.count > 0)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: CustomText('${selection.count} selected', fontSize: 12, fontWeight: FontWeight.w600),
                    onDeleted: () => ref.read(uploadSelectionProvider.notifier).clearSelection(),
                  ),
                  ActionChip(
                    label: const CustomText('Clear', fontSize: 12),
                    onPressed: () => ref.read(uploadSelectionProvider.notifier).clearSelection(),
                  ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList.builder(
            itemCount: visibleUploads.length,
            itemBuilder: (context, index) {
              final transfer = visibleUploads[index];
              final isSelected = selection.isSelected(transfer.id);
              return InkWell(
                onLongPress: () => ref.read(uploadSelectionProvider.notifier).toggleSelect(transfer.id),
                child: Container(
                  decoration: BoxDecoration(
                    border: isSelected ? Border.all(color: theme.primaryColor, width: 2) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      TransferCard(
                        transfer: transfer,
                        onPause: transfer.status == TransferStatus.inProgress
                            ? () => _pauseUpload(ref, transfer.id)
                            : null,
                        onResume: transfer.status == TransferStatus.paused
                            ? () => _resumeUpload(ref, transfer.id)
                            : null,
                        onCancel:
                            transfer.status != TransferStatus.completed && transfer.status != TransferStatus.failed
                            ? () => _cancelUpload(ref, transfer.id)
                            : null,
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                            child: Icon(Icons.check, color: theme.onPrimary, size: 20),
                          ),
                        ),
                    ],
                  ),
                ),
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

  void _showUploadDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText('Upload Content', fontSize: 18, fontWeight: FontWeight.w600),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const CustomText('Select what to upload:', fontSize: 14),
            ListTile(
              leading: Icon(HugeIconsSolid.book01, color: theme.primaryColor),
              title: const CustomText('Select Course', fontSize: 14),
              subtitle: const CustomText('Upload entire course', fontSize: 12, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show course selection dialog
              },
            ),
            Divider(color: theme.dividerColor),
            ListTile(
              leading: Icon(HugeIconsSolid.folders, color: theme.primaryColor),
              title: const CustomText('Select Collection', fontSize: 14),
              subtitle: const CustomText('Upload collection contents', fontSize: 12, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show collection selection dialog
              },
            ),
            Divider(color: theme.dividerColor),
            ListTile(
              leading: Icon(HugeIconsSolid.fileAttachment, color: theme.primaryColor),
              title: const CustomText('Select Content', fontSize: 14),
              subtitle: const CustomText('Upload individual content', fontSize: 12, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show content selection dialog
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const CustomText('Cancel', fontSize: 14))],
      ),
    );
  }
}
