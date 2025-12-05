import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/modify/create_collection_bottom_sheet.dart';
import 'package:slidesync/routes/routes.dart';

class CourseDetailsActions {
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
