import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/more_options_dialog.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class CourseViewActions {
  static void showMoreOptionsDialog(BuildContext context, {required String courseId}) async {
    final course = await CourseRepo.getCourseByUid(courseId);
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

  static void showNewModuleDialog(BuildContext context, String courseId) {
    CustomDialog.show(
      context,
      canPop: true,
      barrierColor: Colors.black.withAlpha(150),
      child: CreateCollectionBottomSheet(courseId: courseId),
    );
    return;
  }
}
