import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_pagination_entities/grouped_module_content.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_state.dart';
import 'package:slidesync/features/browse/providers/module_contents_provider.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_notifier/module_contents_notifier.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_pagination_notifier/module_contents_pagination_notifier.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/content_card.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/grouped_content_card.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/modify_contents/empty_contents_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

class ContentsView extends ConsumerWidget {
  final Module collection;
  final bool isFullScreen;

  const ContentsView({super.key, required this.collection, required this.isFullScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsProvider = ModuleContentsProvider.state(collection.id);
    ref.emptyListenMany([ContentCard.refreshedLinksNotifier(collection.uid)]);

    final contentsNotifier = contentsProvider.link(ref);
    final paginationNotifier = contentsNotifier.contentsPagination.link(ref);

    final gridCrossAxisCount = isFullScreen
        ? context.deviceWidth ~/ 200
        : (context.deviceWidth / (DeviceUtils.isDesktop() ? 3 : 1)) ~/ 160;

    return AbsorberWatch(
      listenable: contentsProvider.select((s) => (s.cardViewType, s.isLoading)),
      builder: (context, contentsState, ref, _) {
        final cardViewType = contentsState.$1;

        return switch (cardViewType) {
          CardViewType.organized => _OrganizedContentsView(
            collection: collection,
            paginationNotifier: paginationNotifier,
            isFullScreen: isFullScreen,
          ),
          _ => _FlatContentsView(
            collection: collection,
            contentsProvider: contentsProvider,
            contentsNotifier: contentsNotifier,
            paginationNotifier: paginationNotifier,
            cardViewType: cardViewType,
            isFullScreen: isFullScreen,
            gridCrossAxisCount: gridCrossAxisCount,
          ),
        };
      },
    );
  }
}

// =============================================================================
// Flat view  (list / grid)
// =============================================================================

class _FlatContentsView extends StatelessWidget {
  const _FlatContentsView({
    required this.collection,
    required this.contentsProvider,
    required this.contentsNotifier,
    required this.paginationNotifier,
    required this.cardViewType,
    required this.isFullScreen,
    required this.gridCrossAxisCount,
  });

  final Module collection;
  final NotifierProvider<ModuleContentsNotifier, ModuleContentsState> contentsProvider;
  final ModuleContentsNotifier contentsNotifier;
  final ModuleContentsPaginationNotifier paginationNotifier;
  final CardViewType cardViewType;
  final bool isFullScreen;
  final int gridCrossAxisCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsetsGeometry.fromLTRB(16, 12, 16, 0),
      sliver: PagingListener(
        controller: paginationNotifier.pagingController,
        builder: (context, pagingState, fetchNextPage) {
          if (pagingState.items != null && pagingState.items!.isEmpty) {
            return EmptyContentsView(collectionId: collection.uid);
          }

          return AbsorberWatch(
            listenable: contentsProvider,
            builder: (context, proState, ref, _) {
              return switch (cardViewType) {
                CardViewType.grid => PagedSliverGrid<int, ModuleContent>(
                  state: pagingState,
                  fetchNextPage: fetchNextPage,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCrossAxisCount,
                    crossAxisSpacing: isFullScreen ? 30 : 12,
                    mainAxisSpacing: isFullScreen ? 40 : 20,
                  ),
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) => ContentCard(
                      content: item,
                      select: _resolveSelect(
                        isSelecting: proState.hasSelectedContents,
                        notifier: contentsNotifier,
                        item: item,
                      ),
                    ),
                  ),
                ),
                _ => PagedSliverList<int, ModuleContent>(
                  state: pagingState,
                  itemExtent: isFullScreen ? 400 : 200,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) => Padding(
                      padding: EdgeInsets.only(bottom: isFullScreen ? 24 : 20),
                      child: ContentCard(
                        content: item,
                        select: _resolveSelect(
                          isSelecting: proState.hasSelectedContents,
                          notifier: contentsNotifier,
                          item: item,
                        ),
                      ),
                    ),
                  ),
                ),
              };
            },
          );
        },
      ),
    );
  }

  ContentCardSelectRecord? _resolveSelect({
    required bool isSelecting,
    required ModuleContentsNotifier notifier,
    required ModuleContent item,
  }) {
    if (!isSelecting) return null;
    return (
      isSelected: notifier.isContentSelected(item),
      onSelect: (content) =>
          notifier.isContentSelected(item) ? notifier.unselectContent(item) : notifier.selectContent(item),
    );
  }
}

// =============================================================================
// Organized view  (masonry, mixed grouped + solo items)
// =============================================================================

class _OrganizedContentsView extends StatelessWidget {
  const _OrganizedContentsView({
    required this.collection,
    required this.paginationNotifier,
    required this.isFullScreen,
  });

  final Module collection;
  final ModuleContentsPaginationNotifier paginationNotifier;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsetsGeometry.fromLTRB(16, 12, 16, 0),
      sliver: PagingListener(
        controller: paginationNotifier.organizedPagingController,
        builder: (context, pagingState, fetchNextPage) {
          if (pagingState.items != null && pagingState.items!.isEmpty) {
            return EmptyContentsView(collectionId: collection.uid);
          }

          return PagedSliverMasonryGrid<int, Object>(
            state: pagingState,
            fetchNextPage: fetchNextPage,
            // gridDelegateBuilder takes (childCount) → SliverSimpleGridDelegate.
            gridDelegateBuilder: (_) =>
                SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: isFullScreen ? 3 : 2),
            mainAxisSpacing: isFullScreen ? 24 : 16,
            crossAxisSpacing: isFullScreen ? 24 : 12,
            builderDelegate: PagedChildBuilderDelegate<Object>(
              itemBuilder: (context, item, index) => switch (item) {
                GroupedModuleContent g => GroupedContentCard(group: g),
                ModuleContent c => ContentCard(content: c),
                _ => const SizedBox.shrink(),
              },
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Loading shimmer (unchanged)
// =============================================================================

class ListMaterialCardLoadingShimmer extends ConsumerWidget {
  final int itemCount;

  const ListMaterialCardLoadingShimmer({super.key, this.itemCount = 2});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (context, index) => Skeletonizer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ContentCard(content: defaultContent),
        ),
      ),
    );
  }
}
