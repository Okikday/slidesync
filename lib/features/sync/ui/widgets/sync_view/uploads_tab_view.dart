import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/features/sync/providers/upload_feed_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class UploadsTabView extends ConsumerWidget {
  const UploadsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploads = ref.watch(uploadFeedProvider).values.toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return SmoothCustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Expanded(child: CustomText('Uploads', fontSize: 15, fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: () => ref.read(uploadFeedProvider.notifier).clearInactive(),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: const CustomText('Clear Finished', fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (uploads.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyUploadsState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
            sliver: SliverList.builder(
              itemCount: uploads.length,
              itemBuilder: (context, index) {
                final item = uploads[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UploadCard(item: item),
                );
              },
            ),
          ),

        const SliverToBoxAdapter(child: BottomPadding()),
      ],
    );
  }
}

class _UploadCard extends ConsumerWidget {
  final UploadFeedState item;

  const _UploadCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final feedNotifier = ref.read(uploadFeedProvider.notifier);
    final transferNotifier = ref.read(transferStateProvider.notifier);

    return ScaleClickWrapper(
      borderRadius: 16,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.background.lightenColor(theme.isDarkMode ? 0.08 : 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.onBackground.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusIcon(item),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        item.title,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      CustomText(_statusLabel(item), fontSize: 11, color: theme.supportingText),
                    ],
                  ),
                ),
                if (item.status == UploadFeedStatus.running)
                  IconButton(
                    icon: const Icon(Icons.pause_circle_outline_rounded),
                    onPressed: () {
                      feedNotifier.pause(item.id);
                      transferNotifier.updateStatus(id: item.id, status: TransferStatus.paused);
                    },
                  ),
                if (item.status == UploadFeedStatus.paused)
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    onPressed: () {
                      feedNotifier.resume(item.id);
                      transferNotifier.updateStatus(id: item.id, status: TransferStatus.inProgress);
                    },
                  ),
                if (item.status == UploadFeedStatus.running ||
                    item.status == UploadFeedStatus.paused ||
                    item.status == UploadFeedStatus.queued)
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () {
                      feedNotifier.cancel(item.id, message: 'Cancelled');
                      transferNotifier.removeTransfer(item.id);
                    },
                  ),
              ],
            ),
            if (_showProgress(item)) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: item.progress,
                  backgroundColor: theme.onBackground.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 6),
              CustomText(
                '${(item.progress * 100).toStringAsFixed(0)}% • ${_formatBytes(item.uploadedBytes)} / ${_formatBytes(item.totalBytes)}',
                fontSize: 11,
                color: theme.supportingText,
              ),
            ],
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              CustomText(item.note!, fontSize: 11, color: theme.supportingText),
            ],
            if (item.logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              CustomText(item.logs.last, fontSize: 11, color: theme.supportingText, maxLines: 2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(UploadFeedState item) {
    if (item.status == UploadFeedStatus.failed) {
      return Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 18);
    }
    if (item.status == UploadFeedStatus.completed) {
      return Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade500, size: 18);
    }
    if (item.status == UploadFeedStatus.paused) {
      return Icon(Icons.pause_circle_outline_rounded, color: Colors.orange.shade500, size: 18);
    }
    return const Icon(Icons.upload_rounded, size: 18);
  }

  String _statusLabel(UploadFeedState item) {
    final time = _timeAgo(item.updatedAt);
    switch (item.status) {
      case UploadFeedStatus.queued:
        return 'Queued • $time';
      case UploadFeedStatus.running:
        return 'Uploading • $time';
      case UploadFeedStatus.paused:
        return 'Paused • $time';
      case UploadFeedStatus.completed:
        return 'Completed • $time';
      case UploadFeedStatus.failed:
        return 'Failed • $time';
      case UploadFeedStatus.cancelled:
        return 'Cancelled • $time';
    }
  }

  bool _showProgress(UploadFeedState item) {
    return item.status == UploadFeedStatus.running ||
        item.status == UploadFeedStatus.paused ||
        item.status == UploadFeedStatus.queued;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _timeAgo(DateTime dateTime) {
    final delta = DateTime.now().difference(dateTime);
    if (delta.inSeconds < 60) return '${delta.inSeconds}s ago';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}

class _EmptyUploadsState extends ConsumerWidget {
  const _EmptyUploadsState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 42, color: theme.supportingText.withValues(alpha: 0.8)),
            const SizedBox(height: 10),
            CustomText('No uploads yet', fontSize: 16, fontWeight: FontWeight.w700, color: theme.onBackground),
            const SizedBox(height: 6),
            CustomText(
              'Uploads in progress and completed uploads will show here.',
              fontSize: 12,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
