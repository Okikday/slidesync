import 'package:flutter/foundation.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';

/// Maximum thumbnails surfaced on a grouped card.
const int kGroupedThumbnailLimit = 3;

/// A view-model produced during the pagination grouping pass.
/// All fields are eagerly computed so the widget tree never iterates [items].
class GroupedModuleContent {
  /// The shared [ModuleContentMetadata.groupId] — also used as the display title.
  final String groupId;

  /// Ordered members of this group (page-local, not globally complete).
  final List<ModuleContent> items;

  /// Up to [kGroupedThumbnailLimit] thumbnails from the first members that
  /// carry one. Computed once; safe to read in build().
  final List<FilePath> previewThumbnails;

  /// [DateTime] of the most-recently modified item — useful for sorting groups
  /// against each other and surfacing "last updated" on the card.
  final DateTime latestModified;

  /// Aggregate byte-size of all [items]. Decorative; shown in card footer.
  final int totalSizeInBytes;

  /// Number of items in this group. Explicit so widgets never call
  /// [items.length] on every frame.
  final int count;

  const GroupedModuleContent({
    required this.groupId,
    required this.items,
    required this.previewThumbnails,
    required this.latestModified,
    required this.totalSizeInBytes,
    required this.count,
  });

  /// Display title — identical to [groupId] by design.
  String get title => groupId;

  /// Type of the first item; used for icon/badge fallback on the card.
  ModuleContentType get leadingType => items.first.type;

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Builds a [GroupedModuleContent] from an already-collected list of items
  /// that share the same non-null, non-empty [groupId].
  ///
  /// Runs in O(n) on [items]; call once per group during the grouping pass.
  factory GroupedModuleContent.fromItems(String groupId, List<ModuleContent> items) {
    assert(items.isNotEmpty, 'GroupedModuleContent must contain at least one item');

    final thumbnails = <FilePath>[];
    DateTime latest = items.first.lastModified;
    int totalSize = 0;

    for (final item in items) {
      // Collect up to [kGroupedThumbnailLimit] thumbnails eagerly.
      if (thumbnails.length < kGroupedThumbnailLimit) {
        final thumb = item.metadata?.thumbnail;
        if (thumb != null && (thumb.containsUrlPath || thumb.local?.isNotEmpty == true)) {
          thumbnails.add(thumb);
        }
      }

      if (item.lastModified.isAfter(latest)) latest = item.lastModified;
      totalSize += item.fileSizeInBytes;
    }

    return GroupedModuleContent(
      groupId: groupId,
      items: items,
      previewThumbnails: thumbnails,
      latestModified: latest,
      totalSizeInBytes: totalSize,
      count: items.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality — identity is the groupId + item ids so Riverpod diffing works.
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupedModuleContent && other.groupId == groupId && listEquals(other.items, items);
  }

  @override
  int get hashCode => groupId.hashCode ^ Object.hashAll(items);

  @override
  String toString() => 'GroupedModuleContent(groupId: $groupId, count: $count)';
}

// -----------------------------------------------------------------------------
// Grouping helper — lives here so it's co-located with the model.
// -----------------------------------------------------------------------------

/// Partitions [rawItems] into a list of [GroupedModuleContent] (for items that
/// share a non-null, non-empty groupId) and solo [ModuleContent] entries
/// (for ungrouped items), returned as a flat [List<Object>] preserving the
/// original insertion order.
///
/// Complexity: O(n) via [LinkedHashMap].
/// Call this inside [ModuleContentsPaginationNotifier.fetchPage] after the DB
/// query returns, only when [CardViewType.organized] is active.
List<Object> groupModuleContents(List<ModuleContent> rawItems) {
  // Map groupId → ordered members seen on this page.
  final groupMap = <String, List<ModuleContent>>{};
  // Tracks insertion order of first appearance per groupId / solo item.
  final orderedKeys = <Object>[];

  for (final item in rawItems) {
    final gid = item.metadata?.groupId;
    final isGrouped = gid != null && gid.isNotEmpty;

    if (isGrouped) {
      if (!groupMap.containsKey(gid)) {
        groupMap[gid] = [];
        orderedKeys.add(gid); // placeholder preserving order
      }
      groupMap[gid]!.add(item);
    } else {
      orderedKeys.add(item); // solo card
    }
  }

  // Replace groupId placeholders with built GroupedModuleContent objects.
  return orderedKeys
      .map((key) {
        if (key is String) {
          return GroupedModuleContent.fromItems(key, groupMap[key]!);
        }
        return key as ModuleContent;
      })
      .toList(growable: false);
}
