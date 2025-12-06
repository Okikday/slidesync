import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/course/ui/widgets/shared/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/more_options_dialog.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class CourseDetailsActions {
  static void showMoreOptionsDialog(BuildContext context, {required String courseId}) async {
    final course = await CourseRepo.getCourseById(courseId);
    if (course == null) return;
    GlobalNav.withContext(
      (c) => CustomDialog.show(
        (context.mounted ? context : c),
        canPop: true,
        barrierColor: Colors.black.withAlpha(150),
        child: MoreOptionsDialog(course: course),
      ),
    );
  }

  static void showNewCollectionDialog(BuildContext context, String courseId) {
    CustomDialog.show(
      context,
      canPop: true,
      barrierColor: Colors.black.withAlpha(150),
      child: CreateCollectionBottomSheet(courseId: courseId),
    );
    return;
  }
}
