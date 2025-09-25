import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/actions/modify_course_actions.dart';
import 'package:slidesync/shared/components/dialogs/confirm_deletion_dialog.dart';

class ModifyCourseViewActions {
  void showDeleteCourseDialog(BuildContext context, Course course) {
    UiUtils.showCustomDialog(
      context,
      barrierColor: Colors.black.withAlpha(140),
      child: ConfirmDeletionDialog(
        content: "Deleting this course will delete it's collections and contents",
        animateFrom: Alignment.topRight,
        onCancel: () {
          log("Cancelled");
          context.pop();
        },
        onDelete: () async {
          context.pop();

          if (context.mounted) {
            UiUtils.showLoadingDialog(context, message: "Deleting course...");
          }
          await ModifyCourseActions().onDeleteCourse(courseId: course.courseId);
          if (context.mounted) UiUtils.hideDialog(context);
          if (context.mounted) context.pop();
          if (context.mounted) UiUtils.showFlushBar(context, msg: "Successfully deleted course");
        },
      ),
    );
  }
}
