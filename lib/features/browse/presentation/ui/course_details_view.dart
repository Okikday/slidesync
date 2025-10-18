import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/presentation/logic/course_details_provider.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_details_collection_section.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_details_header.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/positioned_course_options.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections/collections_view_search_bar.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

const double courseDetailsAppBarHeight = 180;

class CourseDetailsView extends ConsumerWidget {
  final String courseId;
  const CourseDetailsView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context.scaffoldBackgroundColor,
        context.isDarkMode,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  final offset = notification.metrics.pixels;
                  ref.read(CourseDetailsProvider.state.select((s) => s.scrollOffsetNotifier)).value = offset;
                }
                return true;
              },
              child: NestedScrollView(
                physics: const NeverScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [CourseDetailsHeader(courseId: courseId)],
                body: NotificationListener(
                  onNotification: (notification) => true,
                  child: CustomScrollView(
                    slivers: [
                      const PinnedHeaderSliver(child: AdjustSpacing()),
                      PinnedHeaderSliver(
                        child: CollectionsViewSearchBar(
                          searchCollectionTextNotifier: ref
                              .watch(CourseDetailsProvider.state)
                              .searchCollectionTextNotifier,
                          onTap: () {
                            PrimaryScrollController.of(context).animateTo(
                              (courseDetailsAppBarHeight + 8),
                              duration: Durations.medium4,
                              curve: CustomCurves.defaultIosSpring,
                            );
                          },
                          trailing: CustomElevatedButton(
                            pixelHeight: 48,
                            pixelWidth: 48,
                            backgroundColor: ref.adjustBgAndPrimaryWithLerp,
                            shape: CircleBorder(side: BorderSide(color: ref.onBackground.withAlpha(10))),
                            onClick: () {
                              if (context.mounted) {
                                CustomDialog.show(
                                  context,
                                  canPop: true,
                                  barrierColor: Colors.black.withAlpha(150),
                                  child: CreateCollectionBottomSheet(courseId: courseId, title: "Create collection"),
                                );
                              }
                            },
                            child: Icon(Iconsax.add_circle, color: ref.onPrimary),
                          ),
                        ),
                      ),
                      CourseDetailsCollectionSection(courseId: courseId),

                      SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
                    ],
                  ),
                ),
              ),
            ),

            PositionedCourseOptions(),
          ],
        ),
      ),
    );
  }
}

class AdjustSpacing extends ConsumerStatefulWidget {
  const AdjustSpacing({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdjustSpacingState();
}

class _AdjustSpacingState extends ConsumerState<AdjustSpacing> {
  @override
  Widget build(BuildContext context) {
    final topPadding = context.topPadding;
    final totalHeight = (courseDetailsAppBarHeight + topPadding);
    final maxHeight = (kToolbarHeight + context.topPadding);

    return ValueListenableBuilder(
      valueListenable: ref.watch(CourseDetailsProvider.state.select((s) => s.scrollOffsetNotifier)),
      builder: (context, value, child) {
        final scrollOffset = value;
        final double percentScroll = (scrollOffset / totalHeight).clamp(0, 1);
        final spacing = lerpDouble(0, maxHeight, percentScroll) ?? 0.0;
        return ConstantSizing.columnSpacing(spacing);
      },
    );
  }
}
