import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/grid_course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/list_course_card.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

class CourseCard extends ConsumerWidget {
  final Course course;
  final CardViewType type;
  final void Function()? onTap;
  final void Function(TapDownDetails det)? onTapDown;
  final void Function()? onLongPress;
  const CourseCard(this.course, this.type, {super.key, this.onTap, this.onTapDown, this.onLongPress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ScaleClickWrapper(
        // borderRadius: isGrid ? 24 : 14,
        borderRadius: 24,
        onTapDown: onTapDown,
        onLongPress: onLongPress,
        onTap: onTap,
        child: type == CardViewType.grid
            ? GridCourseCard(course, onTapIcon: onLongPress ?? () {})
            : ListCourseCard(course, onTapIcon: onLongPress ?? () {}),
      ),
    ).animate().fadeIn();
  }
}
