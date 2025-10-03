import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/global_providers/data_providers/course_providers.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/shared/components/dialogs/app_alert_dialog.dart';
import 'package:slidesync/shared/helpers/course_formatter.dart';

class EditCourseActions {
  final WidgetRef ref;
  const EditCourseActions(this.ref);
  static EditCourseActions of(WidgetRef ref) => EditCourseActions(ref);

  /// Logic to check if the inputs are valid
  String? checkIfCanUpdateCourse({
    required String courseName,
    required String courseCode,
    required String description,
    required bool isVisible,
  }) {
    if (courseName.isEmpty || courseName.length < 2 || courseName.length > 64 || double.tryParse(courseName) != null) {
      if (courseName.isEmpty) return "Kindly fill the course title field!";
      if (courseName.length < 2) return "Course title too short!";
      if (courseName.length > 64) return "Course title too long!";
      return "Kindly input a valid course title!";
    } else if (isVisible && (courseCode.length < 2 || courseCode.length > 16)) {
      return "Kindly input a valid course code or hide it";
    } else if (description.length > 10000) {
      return "Kindly input a shorter description!";
    }
    return null;
  }

  /// Logic to call when user tries to pop page. It'll ask if user wants to exit without saving
  void onPopInvokedWithResult(BuildContext context, NotifierProvider<BoolNotifier, bool> canExitProvider) {
    if (ref.read(canExitProvider)) return;
    UiUtils.showCustomDialog(
      context,
      transitionType: TransitionType.cupertinoDialog,
      transitionDuration: Durations.medium2,
      child: AppAlertDialog(
        title: "Confirm exit",
        content: "Are you sure you want to exit without saving?",
        onCancel: () {
          CustomDialog.hide(context);
        },
        onConfirm: () async {
          CustomDialog.hide(context);

          ref.read(canExitProvider.notifier).update((cb) => true);
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Logic to call when user is trying to update details or saving changes
  Future<void> onUpdateDetails({
    required String courseName,
    required String courseCode,
    required String description,
    required bool isCourseCodeFieldVisible,
    required NotifierProvider<BoolNotifier, bool> canExitProvider,
    required StreamNotifierProvider<CourseStreamNotifier, Course> modifyCourseProvider,
  }) async {
    final context = ref.context;
    final String? errorMsg = checkIfCanUpdateCourse(
      courseName: courseName,
      courseCode: courseCode,
      description: description,
      isVisible: isCourseCodeFieldVisible,
    );
    if (errorMsg != null) {
      log("Cant update");
      UiUtils.showFlushBar(context, msg: errorMsg, flushbarPosition: FlushbarPosition.TOP);
      return;
    }
    final String courseTitle = CourseFormatter.joinCodeToTitle(courseCode, courseName);
    final Course? currCourse = await (ref.read(modifyCourseProvider.future));
    final Course? updatedCourse = currCourse?.copyWith(courseTitle: courseTitle, description: description);
    if (updatedCourse != null) {
      await CourseRepo.addCourse(updatedCourse);
    }

    ref.read(canExitProvider.notifier).update((cb) => true);
    if (context.mounted) Navigator.pop(context);
  }
}
