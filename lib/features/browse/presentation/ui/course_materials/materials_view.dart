import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/browse/presentation/logic/course_materials_provider.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials/content_card.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials/course_material_list_card.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class MaterialsView extends ConsumerWidget {
  final String collectionId;

  const MaterialsView({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final streamedContents = ref.watch(CourseMaterialsController.watchContents(widget.collection.collectionId));
    final pagingControllerProvider = ref.watch(
      CourseMaterialsProvider.contentPaginationProvider(
        collectionId,
      ).select((s) => s.whenData((cb) => cb.pagingController)),
    );

    return SliverPadding(
      padding: EdgeInsetsGeometry.fromLTRB(16, 12, 16, 64 + context.bottomPadding + context.viewInsets.bottom),
      sliver: pagingControllerProvider.when(
        data: (data) {
          return Consumer(
            builder: (context, ref, child) {
              final int cardViewType = ref.watch(CourseMaterialsProvider.cardViewType).value ?? 0;
              final isGrid = cardViewType == 0
                  ? true
                  : cardViewType == 1
                  ? false
                  : null;
              return PagingListener(
                controller: data,
                builder: (context, state, fetchNextPage) {
                  return PagedSliverContentView(
                    state: state,
                    pagingController: data,
                    fetchNextPage: fetchNextPage,
                    collectionId: collectionId,
                    isGrid: isGrid,
                  );
                },
              );
            },
          );
        },
        error: (e, st) => const SliverToBoxAdapter(child: Icon(Icons.error)),
        loading: () => const SliverToBoxAdapter(child: LoadingLogo()),
      ),
    );
  }
}

class PagedSliverContentView extends ConsumerWidget {
  final PagingState<int, CourseContent> state;
  final VoidCallback fetchNextPage;
  final PagingController pagingController;
  final String collectionId;
  final bool? isGrid;
  const PagedSliverContentView({
    super.key,
    required this.state,
    required this.pagingController,
    required this.fetchNextPage,
    required this.collectionId,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isGrid == null) {
      return PagedSliverList<int, CourseContent>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) {
            return CourseMaterialListCard(content: item).animate().fadeIn().moveY(
              begin: index.isEven ? 40 : 20,
              end: 0,
              curve: Curves.fastEaseInToSlowEaseOut,
              duration: Durations.medium3,
            );
          },
        ),
      );
    }
    if (isGrid!) {
      return PagedSliverGrid<int, CourseContent>(
        state: state,
        fetchNextPage: fetchNextPage,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.deviceWidth ~/ 160,
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
        ),
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) {
            return ContentCard(content: item).animate().fadeIn().moveY(
              begin: index.isEven ? 40 : 20,
              end: 0,
              curve: Curves.fastEaseInToSlowEaseOut,
              duration: Durations.medium3,
            );
          },
        ),
      );
    } else {
      return PagedSliverList<int, CourseContent>(
        state: state,
        itemExtent: 180,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ContentCard(content: item).animate().fadeIn().moveY(
                begin: index.isEven ? 40 : 20,
                end: 0,
                curve: Curves.fastEaseInToSlowEaseOut,
                duration: Durations.medium3,
              ),
            );
          },
        ),
      );
    }
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
