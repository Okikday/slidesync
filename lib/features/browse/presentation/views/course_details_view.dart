import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/presentation/providers/course_details_controller.dart';
import 'package:slidesync/features/browse/presentation/views/course_details/course_details_collection_section.dart';
import 'package:slidesync/features/browse/presentation/views/course_details/course_details_header.dart';
import 'package:slidesync/features/browse/presentation/views/course_details/positioned_course_options.dart';
import 'package:slidesync/features/manage/presentation/collections/views/modify_collections/collections_view_search_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

const double courseDetailsAppBarHeight = 180;

class CourseDetailsView extends ConsumerWidget {
  final int courseDbId;
  const CourseDetailsView({super.key, required this.courseDbId});

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
                  ref
                          .read(
                            CourseDetailsController.courseDetailsStateProvider.select((s) => s.scrollOffsetNotifier),
                          )
                          .value =
                      offset;
                }
                return true;
              },
              child: NestedScrollView(
                physics: const NeverScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [CourseDetailsHeader(courseDbId: courseDbId)],
                body: NotificationListener(
                  onNotification: (notification) => true,
                  child: CustomScrollView(
                    slivers: [
                      const PinnedHeaderSliver(child: AdjustSpacing()),
                      PinnedHeaderSliver(
                        child: CollectionsViewSearchBar(
                          searchCollectionTextNotifier: ref
                              .watch(CourseDetailsController.courseDetailsStateProvider)
                              .searchCollectionTextNotifier,
                          onTap: () {
                            PrimaryScrollController.of(context).animateTo(
                              (courseDetailsAppBarHeight + 8),
                              duration: Durations.medium4,
                              curve: CustomCurves.defaultIosSpring,
                            );
                          },
                        ),
                      ),
                      CourseDetailsCollectionSection(courseDbId: courseDbId),

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
      valueListenable: ref.watch(
        CourseDetailsController.courseDetailsStateProvider.select((s) => s.scrollOffsetNotifier),
      ),
      builder: (context, value, child) {
        final scrollOffset = value;
        final double percentScroll = (scrollOffset / totalHeight).clamp(0, 1);
        final spacing = lerpDouble(0, maxHeight, percentScroll) ?? 0.0;
        return ConstantSizing.columnSpacing(spacing);
      },
    );
  }
}
