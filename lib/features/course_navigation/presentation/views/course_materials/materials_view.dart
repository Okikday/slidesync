import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_materials_controller.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/content_card.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/modify_contents/empty_contents_view.dart';
import 'package:slidesync/shared/components/loading_logo.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class MaterialsView extends ConsumerStatefulWidget {
  final CourseCollection collection;

  const MaterialsView({super.key, required this.collection});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MaterialsViewState();
}

class _MaterialsViewState extends ConsumerState<MaterialsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int cardViewType = ref.watch(CourseMaterialsController.cardViewType).value ?? 0;
    final isGrid = cardViewType == 0 ? true : false;
    // final streamedContents = ref.watch(CourseMaterialsController.watchContents(widget.collection.collectionId));
    final pagingControllerProvider = ref.watch(
      CourseMaterialsController.contentPaginationProvider(
        widget.collection.collectionId,
      ).select((s) => s.whenData((cb) => cb.pagingController)),
    );

    return SliverPadding(
      padding: EdgeInsetsGeometry.fromLTRB(16, 12, 16, 64 + context.bottomPadding + context.viewInsets.bottom),
      sliver: pagingControllerProvider.when(
        data: (data) {
          return Consumer(
            builder: (context, ref, child) {
              return PagingListener(
                controller: data,
                builder: (context, state, fetchNextPage) {
                  if (isGrid) {
                    return PagedSliverGridView(
                      state: state,
                      pagingController: data,
                      fetchNextPage: fetchNextPage,
                      collectionId: widget.collection.collectionId,
                    );
                  } else {
                    return PagedSliverList<int, CourseContent>(
                      state: state,
                      itemExtent: 160,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ContentCard(content: item),
                            // .animate().fadeIn().slideY(
                            //   begin: (index / (20) + 1) * 0.4,
                            //   end: 0,
                            //   curve: Curves.fastEaseInToSlowEaseOut,
                            //   duration: Durations.extralong2,
                            // ),
                          );
                        },
                        // noItemsFoundIndicatorBuilder: (context) {
                        //   return SliverToBoxAdapter(child: EmptyContentsView(collection: widget.collection));
                        // },
                      ),
                    );
                  }
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

class PagedSliverGridView extends ConsumerWidget {
  final PagingState<int, CourseContent> state;
  final VoidCallback fetchNextPage;
  final PagingController pagingController;
  final String collectionId;
  const PagedSliverGridView({
    super.key,
    required this.state,
    required this.pagingController,
    required this.fetchNextPage,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(CourseMaterialsController.watchContentsChange(collectionId), (prev, next) {
      next.whenData((_) {
        log("Contents stream signal");
        pagingController.refresh();
      });
    });
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
          return ContentCard(content: item);
        },
      ),
    );
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
