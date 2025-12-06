import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/collection/ui/widgets/collections_search_bar.dart';
import 'package:slidesync/features/browse/course/providers/course_details_provider.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_collection_section.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_header/course_details_header.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

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
        body: NotificationListener(
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
              child: SmoothCustomScrollView(
                slivers: [
                  if (!DeviceUtils.isDesktop()) const PinnedHeaderSliver(child: AdjustSpacing()),

                  PinnedHeaderSliver(
                    child: CollectionsViewSearchBar(
                      courseId: courseId,
                      onTap: () {
                        if (!DeviceUtils.isDesktop()) {
                          PrimaryScrollController.of(context).animateTo(
                            (courseDetailsAppBarHeight + 8),
                            duration: Durations.medium4,
                            curve: CustomCurves.defaultIosSpring,
                          );
                        }
                      },
                      showTrailing: true,
                    ),
                  ),

                  CourseDetailsCollectionSection(courseId: courseId),

                  SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdjustSpacing extends ConsumerWidget {
  const AdjustSpacing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = context.topPadding;
    final totalHeight = (courseDetailsAppBarHeight + topPadding);
    final maxHeight = (kToolbarHeight + context.topPadding);

    return Absorber.readValueNotifier(
      CourseDetailsProvider.state.select((s) => s.scrollOffsetNotifier),
      builder: (context, scrollOffset, _, _) =>
          ConstantSizing.columnSpacing(lerpDouble(0, maxHeight, (scrollOffset / totalHeight).clamp(0, 1)) ?? 0.0),
    );
  }
}
