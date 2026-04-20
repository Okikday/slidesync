import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/actions/library/course_card_actions.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/grid_course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/list_course_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

class CourseCard extends ConsumerWidget with CourseCardActions {
  final Course course;
  final bool isGrid;
  final void Function(Course course)? onTap;
  const CourseCard(this.course, this.isGrid, {super.key, this.onTap});

  void updateTapDownDetailsProvider(WidgetRef ref, Offset det) {
    MainProvider.library.act(ref).cardTapPositionDetails = det;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ScaleClickWrapper(
        // borderRadius: isGrid ? 24 : 14,
        borderRadius: 24,
        onTapDown: (details) {
          updateTapDownDetailsProvider(ref, details.globalPosition);
        },
        onLongPress: () {
          onHoldCourseCard(ref, course: course);
        },
        onTap: () {
          if (onTap != null) {
            onTap!(course);
            return;
          }
          onTapCourseCard(ref, course: course);
        },
        child: isGrid
            ? GridCourseCard(
                course,
                onTapIcon: () {
                  onHoldCourseCard(ref, course: course);
                },
              )
            : ListCourseCard(
                course,
                onTapIcon: () {
                  onHoldCourseCard(ref, course: course);
                },
              ),
      ),
    ).animate().fadeIn();
  }
}
