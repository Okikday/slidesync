import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/features/sync/providers/download_feed_provider.dart';
import 'package:slidesync/features/sync/providers/download_history_provider.dart';
import 'package:slidesync/features/sync/providers/sync_provider.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class DownloadsTabView extends ConsumerWidget {
  const DownloadsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(downloadHistoryFilterProvider);

    final feedItems = ref.watch(downloadFeedProvider).values.toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final historyState = ref.watch(downloadHistoryProvider);
    final historyEntries = (historyState.value ?? const <Map<String, dynamic>>[])
        .map(DownloadHistoryEntry.fromMap)
        .where((entry) => entry.id.isNotEmpty)
        .toList(growable: false);

    final items = <_UnifiedDownloadItem>[
      ...feedItems
          .where((item) => selectedType == null || item.type == selectedType)
          .map(_UnifiedDownloadItem.fromFeed),
      ...historyEntries
          .where((entry) => selectedType == null || entry.type == selectedType)
          .map(_UnifiedDownloadItem.fromHistory),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SmoothCustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: _HeaderRow(selectedType: selectedType),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _EmptyState(selectedType: selectedType))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DownloadTile(item: item),
                );
              },
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmAndClearHistory(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const CustomText('Clear History', fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: BottomPadding()),
      ],
    );
  }

  Future<void> _confirmAndClearHistory(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear download history?'),
        content: const Text('This removes persisted download history entries. Active downloads are not cancelled.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Clear')),
        ],
      ),
    );

    if (result != true) return;

    await ref.read(downloadHistoryProvider.notifier).clearEntries();
    ref.read(downloadFeedProvider.notifier).clearInactive();
  }
}

class _HeaderRow extends ConsumerWidget {
  final SyncType? selectedType;

  const _HeaderRow({required this.selectedType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.onBackground.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          if (selectedType != null)
            IconButton(
              tooltip: 'Reset filter',
              onPressed: () => ref.read(downloadHistoryFilterProvider.notifier).state = null,
              icon: Icon(Icons.close_rounded, color: theme.primaryColor),
            )
          else
            const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              selectedType == null ? 'All downloads' : 'Filtered: ${_labelForType(selectedType!)}',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.onBackground,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<SyncType?>(
            tooltip: 'Filter downloads',
            initialValue: selectedType,
            onSelected: (value) => ref.read(downloadHistoryFilterProvider.notifier).state = value,
            itemBuilder: (context) => const [
              PopupMenuItem<SyncType?>(value: null, child: Text('All')),
              PopupMenuItem<SyncType?>(value: SyncType.course, child: Text('Course')),
              PopupMenuItem<SyncType?>(value: SyncType.collection, child: Text('Collections')),
              PopupMenuItem<SyncType?>(value: SyncType.content, child: Text('Materials')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 17, color: theme.supportingText),
                  const SizedBox(width: 6),
                  CustomText('Filter', fontSize: 12, color: theme.supportingText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _labelForType(SyncType type) {
    switch (type) {
      case SyncType.course:
        return 'Course';
      case SyncType.collection:
        return 'Collections';
      case SyncType.content:
      case SyncType.done:
        return 'Materials';
    }
  }
}

class _DownloadTile extends ConsumerWidget {
  final _UnifiedDownloadItem item;

  const _DownloadTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final transferNotifier = ref.read(transferStateProvider.notifier);
    final feedNotifier = ref.read(downloadFeedProvider.notifier);

    return ScaleClickWrapper(
      borderRadius: 16,
      onTap: item.canOpenContent ? () => _openCompletedContent(context, ref, item.contentId) : null,
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
                _statusIcon(theme),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        item.title,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.onBackground,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        '${item.statusLabel} • ${_timeAgo(item.timestamp)}',
                        fontSize: 11,
                        color: theme.supportingText,
                      ),
                    ],
                  ),
                ),
                if (item.isFeed)
                  Row(
                    children: [
                      if (item.feedStatus == DownloadFeedStatus.running)
                        IconButton(
                          icon: const Icon(Icons.pause_circle_outline_rounded),
                          onPressed: () {
                            feedNotifier.pause(item.feedId!);
                            transferNotifier.updateStatus(id: item.feedId!, status: TransferStatus.paused);
                          },
                        ),
                      if (item.feedStatus == DownloadFeedStatus.paused)
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          onPressed: () {
                            feedNotifier.resume(item.feedId!);
                            transferNotifier.updateStatus(id: item.feedId!, status: TransferStatus.inProgress);
                          },
                        ),
                      if (item.feedStatus != DownloadFeedStatus.completed &&
                          item.feedStatus != DownloadFeedStatus.failed &&
                          item.feedStatus != DownloadFeedStatus.cancelled)
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          onPressed: () {
                            feedNotifier.cancel(item.feedId!, message: 'Cancelled');
                            transferNotifier.removeTransfer(item.feedId!);
                          },
                        ),
                    ],
                  )
                else if (item.canOpenContent)
                  Icon(Icons.open_in_new_rounded, size: 18, color: theme.primaryColor),
              ],
            ),
            if (item.showProgress) ...[
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
                '${(item.progress * 100).toStringAsFixed(0)}% • ${_formatBytes(item.downloadedBytes)} / ${_formatBytes(item.totalBytes)}',
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

  Widget _statusIcon(WidgetRef theme) {
    if (item.feedStatus == DownloadFeedStatus.failed) {
      return Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 18);
    }
    if (item.feedStatus == DownloadFeedStatus.completed || item.feedStatus == null) {
      return Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade500, size: 18);
    }
    if (item.feedStatus == DownloadFeedStatus.paused) {
      return Icon(Icons.pause_circle_outline_rounded, color: Colors.orange.shade500, size: 18);
    }
    return Icon(Icons.downloading_rounded, color: theme.primaryColor, size: 18);
  }

  Future<void> _openCompletedContent(BuildContext context, WidgetRef ref, String? contentId) async {
    if (contentId == null || contentId.isEmpty) {
      _showSnack(context, 'This download has no linked content yet.');
      return;
    }

    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) {
      GlobalNav.withContext((context) => _showSnack(context, 'Could not find the content record.'));
      return;
    }

    final localPath = content.path.local;
    if (localPath == null || localPath.isEmpty || !await File(localPath).exists()) {
      GlobalNav.withContext((context) => _showSnack(context, 'The downloaded file is missing.'));
      return;
    }

    try {
      final hash = await CryptoUtils.calculateFileHashXXH3(localPath);
      final resolved = await ModuleContentRepo.getByHash(hash);
      if (resolved != null) {
        await ContentViewGateActions.redirectToViewer(ref, resolved);
        return;
      }

      // Fallback: open the indexed content when hash lookup is stale/missing.
      await ContentViewGateActions.redirectToViewer(ref, content);
    } catch (_) {
      try {
        await ContentViewGateActions.redirectToViewer(ref, content);
      } catch (_) {
        GlobalNav.withContext((context) => _showSnack(context, 'Failed to open content: ${content.title}'));
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

class _EmptyState extends ConsumerWidget {
  final SyncType? selectedType;

  const _EmptyState({required this.selectedType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_outlined, size: 42, color: theme.supportingText.withValues(alpha: 0.8)),
            const SizedBox(height: 10),
            CustomText(
              selectedType == null ? 'No downloads yet' : 'No downloads in this filter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.onBackground,
            ),
            const SizedBox(height: 6),
            CustomText(
              selectedType == null
                  ? 'Your imported/downloaded items will show up here.'
                  : 'Tap the x on the left of the filter to reset to all.',
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

class _UnifiedDownloadItem {
  final String id;
  final String title;
  final SyncType type;
  final DateTime timestamp;
  final bool isFeed;
  final DownloadFeedStatus? feedStatus;
  final String? feedId;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final String? contentId;
  final String? note;
  final List<String> logs;

  const _UnifiedDownloadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.timestamp,
    required this.isFeed,
    this.feedStatus,
    this.feedId,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.contentId,
    this.note,
    this.logs = const [],
  });

  factory _UnifiedDownloadItem.fromFeed(DownloadFeedState item) {
    return _UnifiedDownloadItem(
      id: item.id,
      title: item.title,
      type: item.type,
      timestamp: item.updatedAt,
      isFeed: true,
      feedStatus: item.status,
      feedId: item.id,
      progress: item.progress,
      downloadedBytes: item.uploadedBytes,
      totalBytes: item.totalBytes,
      contentId: item.contentId,
      note: item.note,
      logs: item.logs,
    );
  }

  factory _UnifiedDownloadItem.fromHistory(DownloadHistoryEntry item) {
    return _UnifiedDownloadItem(
      id: item.id,
      title: item.title,
      type: item.type,
      timestamp: item.createdAt,
      isFeed: false,
      feedStatus: DownloadFeedStatus.completed,
      progress: 1.0,
      downloadedBytes: item.totalBytes,
      totalBytes: item.totalBytes,
      contentId: item.contentId,
      note: item.note,
    );
  }

  bool get showProgress =>
      isFeed &&
      (feedStatus == DownloadFeedStatus.running ||
          feedStatus == DownloadFeedStatus.paused ||
          feedStatus == DownloadFeedStatus.queued);

  bool get canOpenContent =>
      contentId != null && contentId!.isNotEmpty && (feedStatus == DownloadFeedStatus.completed || (!isFeed));

  String get statusLabel {
    if (!isFeed) return 'Completed';
    switch (feedStatus) {
      case DownloadFeedStatus.queued:
        return 'Queued';
      case DownloadFeedStatus.running:
        return 'Downloading';
      case DownloadFeedStatus.paused:
        return 'Paused';
      case DownloadFeedStatus.completed:
        return 'Completed';
      case DownloadFeedStatus.failed:
        return 'Failed';
      case DownloadFeedStatus.cancelled:
        return 'Cancelled';
      case null:
        return 'Completed';
    }
  }
}
