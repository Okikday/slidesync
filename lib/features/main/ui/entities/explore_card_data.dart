import 'package:flutter/material.dart';
import 'package:slidesync/features/main/ui/widgets/explore_tab_view/explore_card.dart';

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
