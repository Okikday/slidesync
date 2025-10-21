import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/main/presentation/library/logic/src/library_tab_state.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';

import 'package:slidesync/features/main/presentation/library/ui/src/expand_card_dialog.dart';

class CourseCardActions {
  final WidgetRef ref;
  const CourseCardActions(this.ref);
  static CourseCardActions of(WidgetRef ref) => CourseCardActions(ref);

  BuildContext get context => ref.context;

  void onTapCourseCard(Course course) async {
    final isCourseCardAnimating = LibraryTabState.isCourseCardAnimating;
    if (isCourseCardAnimating) return;
    LibraryTabState.isCourseCardAnimating = true; // Tell that a course is currently opened
    await Future.delayed(Durations.short4);

    if (context.mounted) context.pushNamed(Routes.courseDetails.name, extra: course.courseId);
    LibraryTabState.isCourseCardAnimating = false;
  }

  void onHoldCourseCard(Course course) async {
    final Offset? tapPosition = LibraryTabState.cardTapPositionDetails;
    if (tapPosition == null) return;
    UiUtils.showCustomDialog(
      context,
      blurSigma: Offset(2, 2),
      barrierColor: Colors.black26,
      child: ExpandCardDialog(
        tapPosition: tapPosition,
        course: course,
        onOpen: () {
          UiUtils.hideDialog(context);
          onTapCourseCard(course);
        },
      ),
    );
  }
}
