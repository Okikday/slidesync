import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/grouped_module_content.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class GroupedContentCard extends ConsumerWidget {
  const GroupedContentCard({super.key, required this.group});

  final GroupedModuleContent group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final shadowSurfaceColor = theme.surface.lightenColor(0.5).withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 200),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: shadowSurfaceColor),
          ),
          child: Column(
            children: [
              Expanded(child: _GroupedStackedCard(group: group)),
              _GroupedCardBottomStrip(group: group),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Stacked layers
// =============================================================================

class _GroupedStackedCard extends ConsumerWidget {
  const _GroupedStackedCard({required this.group});

  final GroupedModuleContent group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            for (int i = 0; i < 3; i++)
              Transform.translate(
                offset: Offset(0, -(100.0 * i)),
                child: Container(
                  height: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: theme.surface
                        .withValues(alpha: 0.4 + (i * 0.3))
                        .lightenColor(context.isDarkMode ? 0.3 : 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: i == 2 ? Border.all(color: theme.surface.lightenColor(0.5).withAlpha(40)) : null,
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 40),
                  margin: EdgeInsets.only(top: 4.5 * i, left: 4.0 * (2 - i), right: 4.0 * (2 - i)),
                  // Only the front layer carries content.
                  child: i == 2 ? _ThumbnailStrip(group: group) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Thumbnail strip — front layer content
// =============================================================================

class _ThumbnailStrip extends ConsumerWidget {
  const _ThumbnailStrip({required this.group});

  final GroupedModuleContent group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final thumbs = group.previewThumbnails;
    final count = thumbs.length.clamp(1, kGroupedThumbnailLimit);

    // Show only as many slots as we have thumbnails — let them expand.
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < count; i++)
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.isDarkMode
                      ? theme.surface.withAlpha(100)
                      : theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.5),
                  border: Border.all(color: theme.primary.withAlpha(20)),
                ),
                child: SizedBox.square(
                  dimension: 40,
                  child: BuildImagePathWidget(
                    width: 40,
                    height: 40,
                    fileDetails: thumbs[i],
                    fallbackWidget: Icon(
                      IconHelper.getContentTypeIconData(group.leadingType, false),
                      size: 16,
                      color: theme.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Right side: count badge + item label, matching the course card's
        // course-code + progress-indicator column.
        Expanded(
          child: SizedBox(
            height: 40,
            child: Column(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextButton(
                  backgroundColor: theme.altBackgroundSecondary,
                  pixelHeight: 16,
                  borderRadius: 8,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CustomText(
                    '${group.count} items',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: theme.secondary,
                  ),
                ),
                _SizeLabel(totalBytes: group.totalSizeInBytes, theme: theme),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Bottom strip
// =============================================================================

class _GroupedCardBottomStrip extends ConsumerWidget {
  const _GroupedCardBottomStrip({required this.group});

  final GroupedModuleContent group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.9)),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Flexible(
                  child: CustomText(
                    group.title,
                    color: theme.onBackground,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    fontSize: 13,
                    height: 1.1,
                  ),
                ),
                CustomText(
                  _formatLastModified(group.latestModified),
                  fontSize: 10,
                  color: theme.supportingText.withAlpha(200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastModified(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// =============================================================================
// Helpers
// =============================================================================

class _SizeLabel extends StatelessWidget {
  const _SizeLabel({required this.totalBytes, required this.theme});

  final int totalBytes;
  final WidgetRef theme;

  @override
  Widget build(BuildContext context) {
    return CustomText(_formatBytes(totalBytes), fontSize: 8, color: theme.supportingText);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
