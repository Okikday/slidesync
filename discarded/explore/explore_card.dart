import 'package:flutter/material.dart';
// Enhanced ExploreCard Widget
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

class ExploreCardData {
  final String id;
  final String title;
  final String description;
  final ExploreCardType type;
  final List<String> tags;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime uploadedAt;
  final int viewCount;
  final int itemCount; // slides count for courses, items for collections
  final bool isFeatured;
  final String? thumbnailUrl;
  final Color? accentColor;

  const ExploreCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.tags = const [],
    required this.authorName,
    this.authorAvatarUrl,
    required this.uploadedAt,
    this.viewCount = 0,
    this.itemCount = 0,
    this.isFeatured = false,
    this.thumbnailUrl,
    this.accentColor,
  });

  // Helper to get type icon
  IconData get typeIcon {
    switch (type) {
      case ExploreCardType.course:
        return Icons.school;
      case ExploreCardType.collection:
        return Icons.collections;
      case ExploreCardType.content:
        return Icons.description;
    }
  }

  // Helper to get type label
  String get typeLabel {
    switch (type) {
      case ExploreCardType.course:
        return 'Course';
      case ExploreCardType.collection:
        return 'Collection';
      case ExploreCardType.content:
        return 'Content';
    }
  }

  // Helper to get relative time
  String get relativeTime {
    final difference = DateTime.now().difference(uploadedAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper to format view count
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }
}

enum ExploreCardType { course, collection, content }

class ExploreCard extends ConsumerWidget {
  final ExploreCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;

  const ExploreCard({super.key, required this.data, this.onTap, this.onAuthorTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final shadowSurfaceColor = theme.surface.lightenColor(0.5).withValues(alpha: 0.1);
    final accentColor = data.accentColor ?? theme.primary;

    return ScaleClickWrapper(
      borderRadius: 22,
      onTap: onTap ?? () {},
      child: Container(
        constraints: BoxConstraints(maxHeight: 180, maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: data.isFeatured ? accentColor.withValues(alpha: 0.3) : shadowSurfaceColor,
            width: data.isFeatured ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                Badge(
                  isLabelVisible: data.isFeatured,
                  label: Icon(Icons.star, size: 20, color: Colors.amber),
                  alignment: Alignment.topRight,
                  offset: Offset(-4, 4),
                  backgroundColor: Colors.transparent,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: accentColor.withValues(alpha: 0.1),
                    child: Icon(data.typeIcon, color: accentColor, size: 28),
                  ),
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
                              color: theme.onBackground,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ConstantSizing.rowSpacing(4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomText(
                              data.typeLabel,
                              fontSize: 10,
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      ConstantSizing.columnSpacing(4),
                      CustomText(
                        data.description,
                        fontSize: 12,
                        color: theme.supportingText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            ConstantSizing.columnSpacingMedium,

            // Tags section
            if (data.tags.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: data.tags.take(3).map((tag) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: CustomText(tag, fontSize: 11, color: accentColor, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (data.tags.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: CustomText(
                        '+${data.tags.length - 3}',
                        fontSize: 11,
                        color: theme.supportingText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

            Spacer(),

            // Footer with metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stats
                Row(
                  children: [
                    if (data.itemCount > 0) ...[
                      Icon(
                        data.type == ExploreCardType.course ? Icons.slideshow : Icons.content_copy,
                        size: 14,
                        color: theme.supportingText,
                      ),
                      ConstantSizing.rowSpacing(4),
                      CustomText('${data.itemCount}', fontSize: 11, color: theme.supportingText),
                      ConstantSizing.rowSpacing(8),
                    ],
                    if (data.viewCount > 0) ...[
                      Icon(Iconsax.eye, size: 14, color: theme.supportingText),
                      ConstantSizing.rowSpacing(4),
                      CustomText(data.formattedViewCount, fontSize: 11, color: theme.supportingText),
                    ],
                  ],
                ),

                // Author and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(data.relativeTime, fontSize: 11, color: theme.supportingText),
                      ConstantSizing.columnSpacing(4),
                      GestureDetector(
                        onTap: onAuthorTap,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: accentColor.withValues(alpha: 0.1),
                              backgroundImage: data.authorAvatarUrl != null
                                  ? NetworkImage(data.authorAvatarUrl!)
                                  : null,
                              child: data.authorAvatarUrl == null
                                  ? Icon(Iconsax.profile_2user, color: accentColor, size: 12)
                                  : null,
                            ),
                            ConstantSizing.rowSpacing(4),
                            Flexible(
                              child: CustomText(
                                data.authorName,
                                fontSize: 11,
                                color: theme.onBackground,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage:
final sampleData = ExploreCardData(
  id: '1',
  title: 'Advanced Flutter Development',
  description: 'Master Flutter with advanced techniques and best practices for building professional apps',
  type: ExploreCardType.content,
  tags: ['Flutter', 'Mobile', 'Advanced', 'Development'],
  authorName: 'Okikiola',
  uploadedAt: DateTime.now().subtract(Duration(days: 2)),
  viewCount: 1250,
  itemCount: 24,
  isFeatured: true,
);
