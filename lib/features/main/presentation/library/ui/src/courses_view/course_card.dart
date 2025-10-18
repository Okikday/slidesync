import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/main/presentation/library/actions/course_card_actions.dart';
import 'package:slidesync/features/main/presentation/library/logic/library_tab_provider.dart';
import 'package:slidesync/features/main/presentation/library/logic/src/library_tab_state.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/courses_view/course_card/grid_course_card.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/courses_view/course_card/list_course_card.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

class CourseCard extends ConsumerWidget {
  final Course course;
  final bool isGrid;
  final void Function(Course course)? onTap;
  const CourseCard(this.course, this.isGrid, {super.key, this.onTap});

  void updateTapDownDetailsProvider(WidgetRef ref, Offset det) {
    LibraryTabState.cardTapPositionDetails = det;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ScaleClickWrapper(
        borderRadius: isGrid ? 24 : 14,
        onTapDown: (details) {
          updateTapDownDetailsProvider(ref, details.globalPosition);
        },
        onLongPress: () {
          CourseCardActions.of(ref).onHoldCourseCard(course);
        },
        onTap: () {
          if (onTap != null) {
            onTap!(course);
            return;
          }
          CourseCardActions.of(ref).onTapCourseCard(course);
        },
        child: isGrid
            ? GridCourseCard(
                course,
                onTapIcon: () {
                  CourseCardActions.of(ref).onHoldCourseCard(course);
                },
              )
            : ListCourseCard(
                course,
                onTapIcon: () {
                  CourseCardActions.of(ref).onHoldCourseCard(course);
                },
              ),
      ),
    ).animate().fadeIn();
  }
}
