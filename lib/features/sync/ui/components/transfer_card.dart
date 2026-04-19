import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

/// Themed transfer card displaying upload/download progress
/// Follows the glassmorphism design from BottomNavBar
class TransferCard extends ConsumerWidget {
  final TransferState transfer;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const TransferCard({super.key, required this.transfer, this.onPause, this.onResume, this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final isCompleted = transfer.status == TransferStatus.completed;
    final isFailed = transfer.status == TransferStatus.failed;
    final isPaused = transfer.status == TransferStatus.paused;
    final isInProgress = transfer.status == TransferStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.onBackground.withValues(alpha: 0.15),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title, Type Badge, Status Icon
                Row(
                  children: [
                    // Transfer direction icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transfer.status, theme).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transfer.direction == TransferDirection.upload
                            ? HugeIconsSolid.upload01
                            : HugeIconsSolid.download01,
                        color: _getStatusColor(transfer.status, theme),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            transfer.title,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.onBackground,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomText(
                              transfer.type.name.toUpperCase(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status indicator
                    _buildStatusIndicator(theme, isFailed, isCompleted, isInProgress),
                  ],
                ),
                const SizedBox(height: 12),

                // Size and Speed info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(transfer.sizeString, fontSize: 12, color: theme.supportingText),
                    if (isInProgress)
                      CustomText(
                        transfer.speedString,
                        fontSize: 12,
                        color: theme.supportingText,
                        fontWeight: FontWeight.w500,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: isCompleted ? 1.0 : transfer.progress,
                    minHeight: 6,
                    backgroundColor: theme.onBackground.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(transfer.status, theme)),
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom row: Progress text + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Progress percentage or status text
                    CustomText(
                      isCompleted
                          ? 'Complete'
                          : isFailed
                          ? 'Failed'
                          : isPaused
                          ? 'Paused'
                          : '${(transfer.progress * 100).toStringAsFixed(1)}%',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCompleted || isFailed ? _getStatusColor(transfer.status, theme) : theme.onBackground,
                    ),
                    // Time remaining or no. of bytes
                    if (transfer.estimatedTimeRemaining != null && isInProgress)
                      CustomText(
                        _formatDuration(transfer.estimatedTimeRemaining!),
                        fontSize: 12,
                        color: theme.supportingText,
                      ),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPaused && onResume != null) ...[
                          _buildActionButton(icon: HugeIconsSolid.play, color: theme.primaryColor, onTap: onResume!),
                          const SizedBox(width: 8),
                        ],
                        if (isInProgress && onPause != null) ...[
                          _buildActionButton(icon: HugeIconsSolid.pause, color: Colors.orangeAccent, onTap: onPause!),
                          const SizedBox(width: 8),
                        ],
                        if (onCancel != null && !isCompleted && !isFailed) ...[
                          _buildActionButton(icon: HugeIconsSolid.cancel01, color: Colors.redAccent, onTap: onCancel!),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build status indicator icon
  Widget _buildStatusIndicator(WidgetRef theme, bool isFailed, bool isCompleted, bool isInProgress) {
    if (isCompleted) {
      return Icon(HugeIconsSolid.checkmarkCircle02, color: Colors.greenAccent, size: 24);
    } else if (isFailed) {
      return Icon(HugeIconsSolid.alertCircle, color: Colors.redAccent, size: 24);
    } else if (isInProgress) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor)),
      );
    }
    return const SizedBox(width: 24);
  }

  /// Format duration to readable string (e.g., "2h 15m", "45s")
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      return '${duration.inHours}h ${minutes}m';
    } else if (duration.inMinutes > 0) {
      final seconds = duration.inSeconds % 60;
      return '${duration.inMinutes}m ${seconds}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get color for transfer status
  Color _getStatusColor(TransferStatus status, WidgetRef theme) {
    switch (status) {
      case TransferStatus.completed:
        return Colors.greenAccent;
      case TransferStatus.failed:
      case TransferStatus.cancelled:
        return Colors.redAccent;
      case TransferStatus.paused:
        return Colors.orangeAccent;
      case TransferStatus.inProgress:
      case TransferStatus.pending:
        return theme.primaryColor;
    }
  }

  /// Build small action button
  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
