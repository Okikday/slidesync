import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/browse/logic/src/courses/create_course_uc.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class CreateCourseButton extends ConsumerWidget {
  const CreateCourseButton({
    super.key,
    required this.courseNameController,
    required this.courseCodeController,
    required this.isCourseCodeFieldVisible,
    required this.courseImagePathNotifier,
    required this.pushToCreated,
  });

  final TextEditingController courseNameController;
  final TextEditingController courseCodeController;
  final ValueNotifier<bool> isCourseCodeFieldVisible;
  final ValueNotifier<String?> courseImagePathNotifier;
  final bool pushToCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomElevatedButton(
      backgroundColor: ref.primaryColor,
      label: "Create Course",
      textColor: ref.onPrimary,
      textSize: 14,
      pixelWidth: context.deviceWidth,
      pixelHeight: 48,
      borderRadius: 24,
      onClick: () async {
        final String courseName = courseNameController.text.trim();
        final String courseCode = courseCodeController.text.trim();
        final String? errorString = checkIfCanCreateCourse(courseName, courseCode, isCourseCodeFieldVisible.value);
        if (errorString != null) {
          UiUtils.showFlushBar(
            context,
            msg: errorString,
            vibe: FlushbarVibe.error,
            margin: EdgeInsets.only(left: 24, right: 24, bottom: context.bottomPadding + 60),
            barBlur: 2.0,
          );
          return;
        }
        FocusScope.of(context).unfocus();

        GlobalNav.withContext(
          (context) => UiUtils.showLoadingDialog(
            context,
            message: "Adding Course...",
            backgroundColor: Colors.white10,
            blurSigma: Offset(2, 2),
            canPop: false,
          ),
        );

        final Result<Course> createCourseOutcome = await CreateCourseUc().createCourseAction(
          courseName: courseName,
          courseCode: courseCode,
          courseImagePath: courseImagePathNotifier.value,
        );

        GlobalNav.withContext((context) => UiUtils.hideDialog(context));

        createCourseOutcome
            .doNext((value) async {
              GlobalNav.withContext((context) => context.pop());
              GlobalNav.withContextAsync((context) async {
                if (pushToCreated) {
                  DeviceUtils.isDesktop()
                      ? context.pushReplacementNamed(Routes.courseDetails.name, extra: value.uid)
                      : context.pushNamed(Routes.courseDetails.name, extra: value.uid);
                } else {
                  //
                }
                await Future.delayed(Durations.short4);
                // ignore: use_build_context_synchronously
                await UiUtils.showFlushBar(context, msg: "Successfully created course!", vibe: FlushbarVibe.success);
              });
            })
            .onError((error, [_]) async {
              await UiUtils.showFlushBar(
                context,
                msg: error,
                vibe: FlushbarVibe.error,
                margin: EdgeInsets.only(left: 24, right: 24, bottom: context.bottomPadding + 60),
              );
            });
      },
    );
  }
}

String? checkIfCanCreateCourse(
  String courseName,
  String courseCode,
  bool isCourseCodeVisible, {
  int minLength = 2,
  int maxLength = 64,
}) {
  if (courseName.isEmpty ||
      courseName.length < minLength ||
      courseName.length > maxLength ||
      double.tryParse(courseName) != null) {
    if (courseName.isEmpty) return "Kindly fill the course title field!";
    if (courseName.length < 2) return "Course title too short!";
    if (courseName.length > 64) return "Course title too long!";
    return "Kindly input a valid course title!";
  } else if (isCourseCodeVisible && (courseCode.length < 2 || courseCode.length > 16)) {
    return "Kindly input a valid course code or hide it";
  }
  return null;
}
