import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/mixins/scroll_offset_notifier_mixin.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_fab.dart';
import 'package:slidesync/features/browse/ui/widgets/module/modules_list/modules_list_with_search_sliver.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_header/course_view_header.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

const double courseDetailsAppBarHeight = 180;

class CourseView extends ConsumerStatefulWidget {
  final String courseId;
  const CourseView({super.key, required this.courseId});

  @override
  ConsumerState<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends ConsumerState<CourseView> with ScrollOffsetNotifierMixin {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "",
      systemUiOverlayStyle: UiUtils.getSystemUiOverlayStyle(
        context.scaffoldBackgroundColor,
        context.isDarkMode,
        statusBarColor: Colors.transparent,
      ),
      extendBody: true,
      floatingActionButton: CourseViewFAB(courseId: widget.courseId),
      body: NestedScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CourseViewHeader(courseId: widget.courseId, scrollOffsetNotifier: scrollOffsetNotifier),
          if (!DeviceUtils.isDesktop())
            PinnedHeaderSliver(child: AdjustSpacing(scrollOffsetNotifier: scrollOffsetNotifier)),
        ],
        body: ModulesListWithSearchScrollViwe(
          courseId: widget.courseId,
          topPadding: null,
          isPinned: true,
          showMoreOptionsButton: true,
        ),
      ),
    );
  }
}

class AdjustSpacing extends ConsumerWidget {
  final ValueNotifier<double> scrollOffsetNotifier;
  const AdjustSpacing({super.key, required this.scrollOffsetNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = context.topPadding;
    final totalHeight = (courseDetailsAppBarHeight + topPadding);
    final maxHeight = (kToolbarHeight + context.topPadding);

    return ValueListenableBuilder(
      valueListenable: scrollOffsetNotifier,
      builder: (context, scrollOffset, child) =>
          ConstantSizing.columnSpacing(lerpDouble(0, maxHeight, (scrollOffset / totalHeight).clamp(0, 1)) ?? 0.0),
    );
  }
}
