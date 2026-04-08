import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';

import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/course_card_context_menu.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CourseCardActions {
  final WidgetRef ref;
  const CourseCardActions(this.ref);
  static CourseCardActions of(WidgetRef ref) => CourseCardActions(ref);

  BuildContext get context => ref.context;

  void onTapCourseCard(Course course) async {
    final libraryNotifier = MainProvider.from(ref, (r, v) => v.library.act(r));
    if (libraryNotifier.isAnyCardAnimating) return;
    libraryNotifier.isAnyCardAnimating = true; // Tell that a course is currently opened
    await Future.delayed(Durations.short4);

    if (context.mounted) {
      if (DeviceUtils.isDesktop()) {
        context.goNamed(Routes.courseDetails.name, extra: course.courseId);
      } else {
        context.pushNamed(Routes.courseDetails.name, extra: course.courseId);
      }
    }
    libraryNotifier.isAnyCardAnimating = false;
  }

  void onHoldCourseCard(Course course) async {
    final libraryNotifier = MainProvider.from(ref, (r, v) => v.library.act(r));
    final Offset? tapPosition = libraryNotifier.cardTapPositionDetails;
    if (tapPosition == null) return;
    UiUtils.showCustomDialog(
      context,
      blurSigma: Offset(2, 2),
      barrierColor: Colors.black26,
      child: CourseCardContextMenu(
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
