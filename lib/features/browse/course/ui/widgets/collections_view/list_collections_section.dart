import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/features/browse/course/ui/components/collection_card.dart';
import 'package:slidesync/shared/global/providers/collections_providers.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_collection_section.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/features/browse/course/ui/widgets/shared/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/browse/course/ui/widgets/collections_view/empty_collections_view.dart';

class ListCollectionsSection extends ConsumerWidget {
  const ListCollectionsSection({super.key, required this.courseId, required this.searchCollectionTextNotifier});
  final String courseId;
  final ValueNotifier<String> searchCollectionTextNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsProvider = CollectionsProviders.collectionsProvider(courseId);
    final collectionsN = ref.watch(collectionsProvider);
    final isDarkMode = context.isDarkMode;

    return ValueListenableBuilder(
      valueListenable: searchCollectionTextNotifier,
      builder: (context, value, child) {
        log("Search collection updated");
        return collectionsN.when(
          data: (data) {
            if (data.isEmpty) {
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

            final searchText = searchCollectionTextNotifier.value;
            final collections =
                (searchText.trim().isEmpty
                        ? data
                        : data.where(
                            (e) => e.collectionTitle.toLowerCase().contains(
                              searchCollectionTextNotifier.value.toLowerCase(),
                            ),
                          ))
                    .toList();

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 64),
              sliver: SliverList.separated(
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final CourseCollection collection = collections[index];
                  return CollectionCard(
                    collection: collection,
                    onTap: () {
                      context.pushNamed(Routes.courseMaterials.name, extra: collection);
                    },
                  ).animate().fadeIn().slideY(
                    begin: (index / collections.length + 1) * 0.4,
                    end: 0,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: Durations.extralong2,
                  );
                },
                separatorBuilder: (BuildContext context, int index) => ConstantSizing.columnSpacingMedium,
              ),
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
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: LoadingShimmerListView()),
          ),
        );
      },
    );
  }
}
