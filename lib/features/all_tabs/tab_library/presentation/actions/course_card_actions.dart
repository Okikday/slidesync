import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/library_tab_controller.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/expand_card_dialog.dart';

class CourseCardActions {
  final WidgetRef ref;
  const CourseCardActions(this.ref);
  static CourseCardActions of(WidgetRef ref) => CourseCardActions(ref);

  BuildContext get context => ref.context;

  void onTapCourseCard(Course course) async {
    final isCourseCardAnimating = LibraryTabController.isCourseCardAnimating;
    if (isCourseCardAnimating) return;
    LibraryTabController.isCourseCardAnimating = true; // Tell that a course is currently opened
    await Future.delayed(Durations.short4);

    if (context.mounted) context.pushNamed(Routes.courseDetails.name, extra: course);
    LibraryTabController.isCourseCardAnimating = false;
  }

  void onHoldCourseCard(Course course) async {
    final Offset? tapPosition = LibraryTabController.cardTapPositionDetails;
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
