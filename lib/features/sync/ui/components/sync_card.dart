import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

// Transfer type enum
enum TransferType { course, collection, content }

// Transfer state enum
enum TransferState { queued, downloading, uploading, paused, completed, failed, cancelled }

// Transfer direction enum
enum TransferDirection { download, upload }

// Data model for transfers
class TransferCardData {
  final String id;
  final String title;
  final String? description;
  final TransferType type;
  final TransferDirection direction;
  final TransferState state;
  final double progress; // 0.0 to 1.0
  final int totalSize; // in bytes
  final int downloadedSize; // in bytes
  final int? speed; // bytes per second
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final String? thumbnailUrl;
  final int itemCount; // number of slides/items

  const TransferCardData({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.direction,
    required this.state,
    this.progress = 0.0,
    required this.totalSize,
    this.downloadedSize = 0,
    this.speed,
    required this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.thumbnailUrl,
    this.itemCount = 0,
  });

  // Helper to get type icon
  IconData get typeIcon {
    switch (type) {
      case TransferType.course:
        return Icons.school;
      case TransferType.collection:
        return Icons.collections;
      case TransferType.content:
        return Icons.description;
    }
  }

  // Helper to get type label
  String get typeLabel {
    switch (type) {
      case TransferType.course:
        return 'Course';
      case TransferType.collection:
        return 'Collection';
      case TransferType.content:
        return 'Content';
    }
  }

  // Helper to get state icon
  IconData get stateIcon {
    switch (state) {
      case TransferState.queued:
        return Iconsax.clock;
      case TransferState.downloading:
      case TransferState.uploading:
        return direction == TransferDirection.download ? Iconsax.arrow_down_1 : Iconsax.arrow_up_3;
      case TransferState.paused:
        return Iconsax.pause;
      case TransferState.completed:
        return Iconsax.tick_circle;
      case TransferState.failed:
        return Iconsax.close_circle;
      case TransferState.cancelled:
        return Iconsax.close_square;
    }
  }

  // Helper to get state color
  Color getStateColor(WidgetRef ref) {
    switch (state) {
      case TransferState.queued:
        return ref.supportingText;
      case TransferState.downloading:
      case TransferState.uploading:
        return ref.primary;
      case TransferState.paused:
        return Colors.orange;
      case TransferState.completed:
        return Colors.green;
      case TransferState.failed:
        return Colors.red;
      case TransferState.cancelled:
        return ref.supportingText;
    }
  }

  // Helper to get state label
  String get stateLabel {
    switch (state) {
      case TransferState.queued:
        return 'Queued';
      case TransferState.downloading:
        return 'Downloading';
      case TransferState.uploading:
        return 'Uploading';
      case TransferState.paused:
        return 'Paused';
      case TransferState.completed:
        return 'Completed';
      case TransferState.failed:
        return 'Failed';
      case TransferState.cancelled:
        return 'Cancelled';
    }
  }

  // Format file size
  String formatSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$bytes B';
  }

  // Format speed
  String get formattedSpeed {
    if (speed == null || speed == 0) return '--';

    if (speed! >= 1048576) {
      return '${(speed! / 1048576).toStringAsFixed(2)} MB/s';
    } else if (speed! >= 1024) {
      return '${(speed! / 1024).toStringAsFixed(2)} KB/s';
    }
    return '$speed B/s';
  }

  // Get remaining time estimate
  String get estimatedTimeRemaining {
    if (speed == null || speed == 0 || state != TransferState.downloading && state != TransferState.uploading) {
      return '--';
    }

    final remaining = totalSize - downloadedSize;
    final secondsRemaining = remaining ~/ speed!;

    if (secondsRemaining >= 3600) {
      final hours = secondsRemaining ~/ 3600;
      return '${hours}h ${(secondsRemaining % 3600) ~/ 60}m';
    } else if (secondsRemaining >= 60) {
      return '${secondsRemaining ~/ 60}m ${secondsRemaining % 60}s';
    }
    return '${secondsRemaining}s';
  }

  // Get size progress string
  String get sizeProgress {
    return '${formatSize(downloadedSize)} / ${formatSize(totalSize)}';
  }

  TransferCardData copyWith({
    String? id,
    String? title,
    String? description,
    TransferType? type,
    TransferDirection? direction,
    TransferState? state,
    double? progress,
    int? totalSize,
    int? downloadedSize,
    int? speed,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    String? thumbnailUrl,
    int? itemCount,
  }) {
    return TransferCardData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      totalSize: totalSize ?? this.totalSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      speed: speed ?? this.speed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

// Transfer Card Widget
class TransferCard extends ConsumerWidget {
  final TransferCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;

  const TransferCard({
    super.key,
    required this.data,
    this.onTap,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateColor = data.getStateColor(ref);
    final shadowSurfaceColor = ref.surface.lightenColor(0.5).withValues(alpha: 0.1);
    final isActive = data.state == TransferState.downloading || data.state == TransferState.uploading;

    return ScaleClickWrapper(
      borderRadius: 20,
      onTap: onTap ?? () {},
      child: Container(
        constraints: BoxConstraints(maxHeight: 200, maxWidth: 450),
        decoration: BoxDecoration(
          color: ref.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? stateColor.withValues(alpha: 0.3) : shadowSurfaceColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon, title, and type badge
            Row(
              children: [
                // Icon with state indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: stateColor.withValues(alpha: 0.1),
                      child: Icon(data.typeIcon, color: stateColor, size: 26),
                    ),
                    if (isActive)
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: data.progress,
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(stateColor),
                          backgroundColor: stateColor.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
                ConstantSizing.rowSpacingMedium,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: CustomText(
                              data.title,
                              fontSize: 14,
                              color: ref.onBackground,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      ConstantSizing.columnSpacing(4),
                      Row(
                        children: [
                          // Type badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ref.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomText(
                              data.typeLabel,
                              fontSize: 10,
                              color: ref.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ConstantSizing.rowSpacing(6),
                          // State badge
                          Icon(data.stateIcon, size: 12, color: stateColor),
                          ConstantSizing.rowSpacing(4),
                          CustomText(data.stateLabel, fontSize: 11, color: stateColor, fontWeight: FontWeight.w500),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                _buildActionButtons(ref, stateColor),
              ],
            ),

            ConstantSizing.columnSpacing(12),

            // Progress bar (only for active transfers)
            if (isActive || data.state == TransferState.paused) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: data.progress,
                  minHeight: 6,
                  backgroundColor: stateColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(stateColor),
                ),
              ),
              ConstantSizing.columnSpacing(8),
            ],

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - size and items
                Expanded(
                  child: Row(
                    children: [
                      if (data.itemCount > 0) ...[
                        Icon(
                          data.type == TransferType.course ? Icons.slideshow : Icons.content_copy,
                          size: 13,
                          color: ref.supportingText,
                        ),
                        ConstantSizing.rowSpacing(4),
                        CustomText('${data.itemCount}', fontSize: 11, color: ref.supportingText),
                        ConstantSizing.rowSpacing(10),
                      ],
                      Icon(Iconsax.document_download, size: 13, color: ref.supportingText),
                      ConstantSizing.rowSpacing(4),
                      CustomText(data.sizeProgress, fontSize: 11, color: ref.supportingText),
                    ],
                  ),
                ),

                // Right side - speed and time
                if (isActive)
                  Row(
                    children: [
                      Icon(Iconsax.flash_1, size: 13, color: ref.supportingText),
                      ConstantSizing.rowSpacing(4),
                      // CustomText(data.formattedSpeed, fontSize: 11, color: ref.supportingText),
                      // ConstantSizing.rowSpacing(10),
                      // Icon(Iconsax.clock, size: 13, color: ref.supportingText),
                      // ConstantSizing.rowSpacing(4),
                      // CustomText(data.estimatedTimeRemaining, fontSize: 11, color: ref.supportingText),
                    ],
                  ),
              ],
            ),

            // Error message for failed state
            if (data.state == TransferState.failed && data.errorMessage != null) ...[
              ConstantSizing.columnSpacing(8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.danger, size: 14, color: Colors.red),
                    ConstantSizing.rowSpacing(6),
                    Expanded(
                      child: CustomText(
                        data.errorMessage!,
                        fontSize: 11,
                        color: Colors.red,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Completion info
            if (data.state == TransferState.completed && data.completedAt != null) ...[
              ConstantSizing.columnSpacing(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.tick_circle, size: 14, color: Colors.green),
                      ConstantSizing.rowSpacing(4),
                      CustomText('Completed', fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                    ],
                  ),
                  CustomText(_formatCompletionTime(data.completedAt!), fontSize: 11, color: ref.supportingText),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, Color stateColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pause/Resume button
        if (data.state == TransferState.downloading || data.state == TransferState.uploading)
          _ActionButton(icon: Iconsax.pause, color: Colors.orange, onTap: onPause)
        else if (data.state == TransferState.paused)
          _ActionButton(icon: Iconsax.play, color: ref.primary, onTap: onResume),

        // Retry button for failed
        if (data.state == TransferState.failed)
          _ActionButton(icon: Iconsax.refresh, color: ref.primary, onTap: onRetry),

        ConstantSizing.rowSpacing(8),

        // Cancel/Delete button
        if (data.state == TransferState.downloading ||
            data.state == TransferState.uploading ||
            data.state == TransferState.paused ||
            data.state == TransferState.queued)
          _ActionButton(icon: Iconsax.close_circle, color: Colors.red.withValues(alpha: 0.8), onTap: onCancel)
        else if (data.state == TransferState.completed ||
            data.state == TransferState.failed ||
            data.state == TransferState.cancelled)
          _ActionButton(icon: Iconsax.trash, color: ref.supportingText, onTap: onDelete),
      ],
    );
  }

  String _formatCompletionTime(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }
}

// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// Example usage:
final downloadData = TransferCardData(
  id: '1',
  title: 'Advanced Flutter Development Course',
  type: TransferType.course,
  direction: TransferDirection.download,
  state: TransferState.downloading,
  progress: 0.65,
  totalSize: 524288000, // 500 MB
  downloadedSize: 340787200, // 325 MB
  speed: 2097152, // 2 MB/s
  startedAt: DateTime.now().subtract(Duration(minutes: 5)),
  itemCount: 24,
);
