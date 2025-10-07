import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/presentation/providers/course_details_controller.dart';
import 'package:slidesync/features/browse/presentation/views/course_details/course_categories_card.dart';
import 'package:slidesync/features/manage/presentation/collections/views/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/manage/presentation/collections/views/modify_collections/empty_collections_view.dart';
import 'package:slidesync/shared/global/providers/collections_providers.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class CourseDetailsCollectionSection extends ConsumerWidget {
  const CourseDetailsCollectionSection({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCollectionsN = ref.watch(CollectionsProviders.collectionsProvider(courseId));

    return asyncCollectionsN.when(
      data: (data) {
        final collections = data;
        if (collections.isEmpty) {
          return EmptyCollectionsView(
            onClickAddCollection: () async {
              // AppRouteNavigator.to(context).modifyCollectionsRoute(course);
              // await Future.delayed(Durations.short1);
              if (context.mounted) {
                CustomDialog.show(
                  context,
                  canPop: true,
                  barrierColor: Colors.black.withAlpha(150),
                  child: CreateCollectionBottomSheet(courseId: courseId),
                );
              }
            },
          );
        }

        return Consumer(
          builder: (context, ref, child) {
            final searchCollectionTextNotifier = ref.watch(
              CourseDetailsController.courseDetailsStateProvider.select((s) => s.searchCollectionTextNotifier),
            );
            return ValueListenableBuilder(
              valueListenable: searchCollectionTextNotifier,
              builder: (context, value, child) {
                if (value.isNotEmpty) {
                  final filteredCollection = collections
                      .where((c) => c.collectionTitle.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                  return SliverList.builder(
                    itemCount: filteredCollection.length,
                    itemBuilder: (context, index) {
                      final list = filteredCollection;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                        child:
                            CourseCategoriesCard(
                              isDarkMode: context.isDarkMode,
                              title: list[index].collectionTitle,
                              contentCount: list[index].contents.length,

                              onTap: () {
                                context.pushNamed(Routes.courseMaterials.name, extra: list[index]);
                              },
                            ).animate().fadeIn().slideY(
                              begin: (index / collections.length + 1) * 0.4,
                              end: 0,
                              curve: Curves.fastEaseInToSlowEaseOut,
                              duration: Durations.extralong2,
                            ),
                      );
                    },
                  );
                }
                return SliverList.builder(
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final list = collections.toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                      child: CourseCategoriesCard(
                        isDarkMode: context.isDarkMode,
                        title: list[index].collectionTitle,
                        contentCount: list[index].contents.length,

                        onTap: () {
                          context.pushNamed(Routes.courseMaterials.name, extra: list[index]);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
      error: (error, st) => SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotatedBox(quarterTurns: 2, child: Icon(Iconsax.info_circle, size: 48)),
            CustomText("Error loading course!"),
          ],
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LoadingShimmerListView(count: 2)),
      ),
    );
  }
}

class LoadingShimmerListView extends ConsumerWidget {
  final int count;
  const LoadingShimmerListView({super.key, this.count = 4});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: count,
      shrinkWrap: true,
      itemBuilder: (context, index) => Skeletonizer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CourseCategoriesCard(isDarkMode: ref.isDarkMode, title: "_", onTap: () {}),
        ),
      ),
    );
  }
}
