import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections/collections_list_view/mod_collection_card_tile.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections/collections_list_view/mod_collection_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

/// COLLECTION SECTION
class CollectionsSection extends ConsumerStatefulWidget {
  final String courseId;
  final List<CourseCollection> collections;
  const CollectionsSection({super.key, required this.courseId, required this.collections});

  @override
  ConsumerState createState() => _CollectionsSectionState();
}

class _CollectionsSectionState extends ConsumerState<CollectionsSection> {
  late final NotifierProvider<DoubleNotifier, double> scrollOffsetNotifier;
  int maxCards = 3;
  // late final NotifierProvider<BoolNotifier, bool> canScrollNotifier;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    scrollOffsetNotifier = NotifierProvider<DoubleNotifier, double>(DoubleNotifier.new, isAutoDispose: true);
    pageController = PageController(initialPage: maxCards);
    // canScrollNotifier = NotifierProvider<BoolNotifier, bool>((ref) => false);
    // widget.pageController.addListener(updateScrollOffset);
    pageController.addListener(updateScrollProgress);
  }

  // void updateScrollOffset() {
  //   final scrollOffsetNotif = ref.read(scrollOffsetNotifier.notifier);
  //   final newUpdate = widget.pageController.position.maxScrollExtent - widget.pageController.offset;
  //   if (newUpdate == scrollOffsetNotif.state) return;
  //   scrollOffsetNotif.update((cb) => widget.pageController.position.maxScrollExtent - widget.pageController.offset);
  //   if (widget.pageController.page == 0) ref.read(canScrollNotifier.notifier).update((cb) => true);
  // }

  void updateScrollProgress() {
    final scrollOffsetNotif = ref.read(scrollOffsetNotifier);
    final double progress = (pageController.page ?? 0.0) / (widget.collections.length - 1).clamp(0, maxCards);
    if (progress == scrollOffsetNotif) return;
    ref.read(scrollOffsetNotifier.notifier).update((cb) => progress);
  }

  @override
  void dispose() {
    // widget.pageController.removeListener(updateScrollOffset);
    pageController.removeListener(updateScrollProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final int count = 10;

    if (widget.collections.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: _buildNewCollectionTile(
          ref,
          onTap: () {
            if (widget.collections.isEmpty) {
              CustomDialog.show(
                context,
                canPop: true,
                barrierColor: Colors.black.withAlpha(150),
                child: CreateCollectionBottomSheet(courseId: widget.courseId),
              ).then((value) {
                if (widget.collections.isNotEmpty) {
                  if (context.mounted) context.pushNamed(Routes.modifyCollections.name, extra: widget.courseId);
                }
              });
              return;
            }
            context.pushNamed(Routes.modifyCollections.name, extra: widget.courseId);
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NotificationListener(
              onNotification: (notification) => true,
              child: ClipRRect(
                child: AnimatedSize(
                  duration: Durations.extralong4,
                  curve: CustomCurves.bouncySpring,
                  reverseDuration: Durations.extralong1,
                  child: Builder(
                    builder: (context) {
                      final double safeHeight =
                          double.parse(
                            (88.0 *
                                    widget.collections.length.clamp(0, maxCards) *
                                    (1.0 - ref.watch(scrollOffsetNotifier)))
                                .toStringAsFixed(2),
                          ).clamp(
                            (88.0 + 88 / (5 - widget.collections.length.clamp(0, maxCards))),
                            (88.0 * widget.collections.length).clamp(
                              (88.0 + 88 / (5 - widget.collections.length.clamp(0, maxCards))),
                              double.infinity,
                            ),
                          );

                      return SizedBox(
                        height: safeHeight,

                        // height:
                        //     (88 +
                        //     88 / (5 - widget.collections.length.clamp(0, 3)) +
                        //     (ref.watch(scrollOffsetNotifier) / 2).clamp(0.0, 88 * (widget.collections.length.clamp(0, 3) - 1))),
                        child: RotatedBox(
                          quarterTurns: 0,
                          child: StackedCardCarousel(
                            initialOffset: 0,
                            spaceBetweenItems: 72,
                            pageController: pageController,
                            items: [
                              for (int index = 0; index < widget.collections.length.clamp(0, maxCards); index++)
                                Builder(
                                  builder: (context) {
                                    final collection = widget.collections[index];
                                    return RotatedBox(
                                      quarterTurns: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: ModCollectionCardTile(
                                          title: widget.collections[index].collectionTitle,
                                          contentCount: widget.collections[index].contents.length,
                                          onSelected: () {
                                            UiUtils.showCustomDialog(
                                              context,
                                              child: ModCollectionDialog(
                                                courseId: widget.courseId,
                                                collection: collection,
                                              ),
                                            );
                                          },
                                          onTap: () async {
                                            context.pushNamed(
                                              Routes.modifyContents.name,
                                              extra: collection.collectionId,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ).animate().fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildNewCollectionTile(WidgetRef ref, {required void Function() onTap}) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        overlayColor: WidgetStatePropertyAll(ref.primaryColor.withAlpha(40)),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: ref.altBackgroundPrimary, borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          child: Row(
            children: [
              Icon(Iconsax.add_circle, size: 30),
              ConstantSizing.rowSpacingMedium,
              Expanded(child: CustomText("New Collection", color: ref.onBackground)),
            ],
          ),
        ),
      ),
    ),
  );
}
