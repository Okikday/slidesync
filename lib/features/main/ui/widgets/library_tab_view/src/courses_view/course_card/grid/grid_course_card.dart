import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/grid/src/grid_course_card_bottom_stack.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/grid/src/image_and_progress_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class GridCourseCard extends ConsumerWidget {
  const GridCourseCard(
    this.course, {
    super.key,
    this.progress = 0.0,
    this.dotColor = Colors.transparent,
    this.isStarred = false,
    required this.onTapIcon,
  });

  final Course course;
  final double progress;
  final Color dotColor;
  final bool isStarred;
  final void Function() onTapIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).custom;
    final shadowSurfaceColor = theme.surface
        .lightenColor(0.5)
        .withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: shadowSurfaceColor),
          ),
          child: Stack(
            // fit: StackFit.expand,
            // clipBehavior: Clip.antiAlias,
            alignment: .bottomCenter,
            children: [
              GridCourseCardStackedCard(course: course),
              GridCourseCardBottomStack(course: course),
            ],
          ),
        ),
      ),
    );
  }
}

class GridCourseCardStackedCard extends ConsumerWidget {
  const GridCourseCardStackedCard({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
      child: BoxStacks(course: course),
    );
  }
}

class BoxStacks extends StatelessWidget {
  const BoxStacks({super.key, required this.course, this.count = 3});

  final Course course;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).custom;
    return Padding(
      padding: const .only(bottom: 40),
      child: Stack(
        children: List.generate(
          count,
          (i) => Container(
            height: 100,
            clipBehavior: .antiAlias,
            decoration: BoxDecoration(
              color: theme.surface
                  .withValues(alpha: 0.4 + (i * 0.3))
                  .lightenColor(context.isDarkMode ? 0.3 : 0.75)
                  .blendColor(course.metadata.color ?? theme.primary, 0.05),
              borderRadius: .circular(20),
              border: (i == count - 1)
                  ? .all(color: theme.surface.lightenColor(0.5).withAlpha(40))
                  : null,
            ),
            padding: .fromLTRB(12, 8, 12, 40),
            margin: .only(
              top: 4.5 * i,
              left: 4.0 * (2 - i),
              right: 4.0 * (2 - i),
            ),

            child: (i == count - 1)
                ? ImageAndProgressWidget(course: course)
                : null,
          ),
        ),
      ),
    );
  }
}
