import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/providers/module_contents_provider.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_notifier/module_contents_notifier.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/content_card.dart';
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
    final pagingController = contentsNotifier.contentsPagination.link(ref).pagingController;
    final gridCrossAxisCount = isFullScreen
        ? context.deviceWidth ~/ 200
        : (context.deviceWidth / (DeviceUtils.isDesktop() ? 3 : 1)) ~/ 160;

    return SliverPadding(
      padding: EdgeInsetsGeometry.fromLTRB(16, 12, 16, 0),
      sliver: PagingListener(
        controller: pagingController,
        builder: (context, pagingState, fetchNextPage) {
          // If there are no items in the [pagingController]
          if (pagingState.items != null && pagingState.items!.isEmpty) {
            return EmptyContentsView(collectionId: collection.uid);
          }

          return AbsorberWatch(
            listenable: contentsProvider.select((s) => (s.cardViewType, s.isLoading)),
            builder: (context, contentsState, ref, _) {
              final cardViewType = contentsState.$1;
              return AbsorberWatch(
                listenable: contentsProvider,
                builder: (context, proState, ref, _) {
                  return switch (cardViewType) {
                    // For GRID
                    CardViewType.grid => PagedSliverGrid<int, ModuleContent>(
                      state: pagingState,
                      fetchNextPage: fetchNextPage,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: isFullScreen ? 30 : 12,
                        mainAxisSpacing: isFullScreen ? 40 : 20,
                      ),
                      builderDelegate: PagedChildBuilderDelegate(
                        // noMoreItemsIndicatorBuilder: (context) => const SizedBox(height: 56),
                        itemBuilder: (context, item, index) =>
                            ContentCard(
                              content: item,
                              select: select(
                                isSelecting: proState.hasSelectedContents,
                                moduleContentsNotifier: contentsNotifier,
                                item: item,
                              ),
                            ).animate().fadeIn().moveY(
                              begin: index.isEven ? 40 : 20,
                              end: 0,
                              curve: Curves.fastEaseInToSlowEaseOut,
                              duration: Durations.medium3,
                            ),
                      ),
                    ),

                    // FOR OTHERS
                    _ => PagedSliverList<int, ModuleContent>(
                      state: pagingState,
                      itemExtent: isFullScreen ? 400 : 200,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) => Padding(
                          padding: EdgeInsets.only(bottom: isFullScreen ? 24 : 16),
                          child:
                              ContentCard(
                                content: item,
                                select: select(
                                  isSelecting: proState.hasSelectedContents,
                                  moduleContentsNotifier: contentsNotifier,
                                  item: item,
                                ),
                              ).animate().fadeIn().moveY(
                                begin: index.isEven ? 40 : 20,
                                end: 0,
                                curve: Curves.fastEaseInToSlowEaseOut,
                                duration: Durations.medium3,
                              ),
                        ),
                      ),
                    ),
                  };
                },
              );
            },
          );
        },
      ),
    );
  }

  ({bool isSelected, void Function(ModuleContent item) onSelect})? select({
    required ModuleContent item,
    required bool isSelecting,
    required ModuleContentsNotifier moduleContentsNotifier,
  }) {
    return isSelecting
        ? (
            isSelected: moduleContentsNotifier.isContentSelected(item),
            onSelect: (content) => moduleContentsNotifier.isContentSelected(item)
                ? moduleContentsNotifier.unselectContent(item)
                : moduleContentsNotifier.selectContent(item),
          )
        : null;
  }
}

class ListMaterialCardLoadingShimmer extends ConsumerWidget {
  final int itemCount;
  const ListMaterialCardLoadingShimmer({super.key, this.itemCount = 2});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
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



  // if (isGrid == null) {
    //   return PagedSliverList<int, CourseContent>(
    //     state: state,
    //     fetchNextPage: fetchNextPage,
    //     builderDelegate: PagedChildBuilderDelegate(
    //       itemBuilder: (context, item, index) {
    //         return MaterialListCard(content: item).animate().fadeIn().moveY(
    //           begin: index.isEven ? 40 : 20,
    //           end: 0,
    //           curve: Curves.fastEaseInToSlowEaseOut,
    //           duration: Durations.medium3,
    //         );
    //       },
    //     ),
    //   );
    // }