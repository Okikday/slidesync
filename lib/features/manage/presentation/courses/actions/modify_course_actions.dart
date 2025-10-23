import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/collections/modify_collection_uc.dart';
import 'package:slidesync/features/manage/domain/usecases/courses/create_course_uc.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/modify_course/course_description_dialog.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/modify_course/edit_course_bottom_sheet.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/modify_course/modify_course_header/preview_modify_course_image_dialog.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class ModifyCourseActions {
  /// When the user clicks to delete the course, on the Dialog
  Future<void> onDeleteCourse({required String courseId}) async {
    final course = await CourseRepo.getCourseById(courseId);
    if (course == null) return;
    for (final item in course.collections) {
      await ModifyCollectionUc().deleteCollection(item);
    }

    await CourseRepo.deleteCourseById(courseId);
  }

  /// When the user Modifies image
  Future<Result> modifyCourseImageAction({required int id, required File newImageFile}) async {
    final Result<bool?> createCourseOutcome = await Result.tryRunAsync<bool>(() async {
      Course? course = await CourseRepo.getCourseByDbId(id);
      if (course == null) return false;
      if (course.imageLocationJson.containsAnyFilePath) {
        await FileUtils.deleteFileAtPath(course.imageLocationJson.filePath);
      }
      final String? newPath = await CreateCourseUc.compressImageToPath(
        newImageFile.path,
        folderPath: "courses/${course.courseId}",
      );
      if (newPath != null) {
        course = course.setImageLocation(FileDetails(filePath: newPath));
        await CourseRepo.addCourse(course);
        log("Successfully changed image ");
        return true;
      }
      return false;
    });

    if (createCourseOutcome.isSuccess) {
      return Result.success(createCourseOutcome.data!);
    }
    return Result.error("Unable to create course");
  }

  /// This deletes the course image
  Future<bool> deleteCourseImageAction({required int courseDbId}) async {
    Course? course = await CourseRepo.getCourseByDbId(courseDbId);
    if (course == null) return false;
    if (course.imageLocationJson.containsAnyFilePath) {
      await CourseRepo.addCourse(course.setImageLocation(FileDetails()));
      await FileUtils.deleteFileAtPath(course.imageLocationJson.filePath);
      return true;
    }
    return false;
  }

  /// When user clicks Add Description.
  /// If there's a description, it shows the Description
  /// else, it brings the option to add description
  void onClickAddDescription(BuildContext context, {required String courseId, required String currDescription}) {
    if (currDescription.isNotEmpty) {
      CustomDialog.show(
        context,
        canPop: true,
        reverseTransitionDuration: Durations.short4,
        transitionType: TransitionType.cupertinoDialog,
        curve: CustomCurves.defaultIosSpring,
        barrierColor: Colors.black54,
        child: CourseDescriptionDialog(
          description: currDescription,
        ).animate().scale(begin: Offset(0.5, 0.5), duration: Durations.extralong1, curve: CustomCurves.bouncySpring),
      );
    } else {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        showDragHandle: false,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        builder: (context) {
          return EditCourseBottomSheet(courseId: courseId, isEditingDescription: true);
        },
      );
    }
  }

  /// Navigates to dialog to preview image
  Future<void> previewImageActionRoute(BuildContext context, {required String courseImagePath}) async {
    if (!courseImagePath.fileDetails.containsFilePath) return;
    CustomDialog.show(
      context,
      transitionDuration: Durations.short3,
      reverseTransitionDuration: Durations.short4,
      canPop: true,
      barrierColor: Colors.black.withAlpha(200),
      child: PreviewModifyCourseImageDialog(imagePath: courseImagePath),
    );
  }

  /// This picks image from device, shows a loading dialog
  Future<void> pickImageActionRoute(BuildContext context, {required int courseDbId}) async {
    UiUtils.showLoadingDialog(
      context,
      message: "Selecting image",
      backgroundColor: Colors.white10,
      blurSigma: Offset(2, 2),
    );
    ImagePicker imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (context.mounted) CustomDialog.hide(context);
    if (pickedImage == null) {
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: "Oops, You didn't select an image!", vibe: FlushbarVibe.warning);
      }
      return;
    }

    final Result result = await modifyCourseImageAction(id: courseDbId, newImageFile: File(pickedImage.path));

    if (context.mounted) {
      CustomDialog.hide(context);
      if (result.isSuccess) {
        UiUtils.showFlushBar(context, msg: "Successfully changed course Image!", vibe: FlushbarVibe.success);
      } else {
        UiUtils.showFlushBar(context, msg: "Unable to change course Image!", vibe: FlushbarVibe.error);
      }
    }
  }

  /// When the course image is clicked, it shows some options in a dialog the user can choose from.
  void onClickCourseImage(WidgetRef ref, {required Course course}) {
    final context = ref.context;
    final iconColor = ref.supportingText;
    final List<AppActionDialogModel> dialogModels = [
      AppActionDialogModel(
        title: "View image",
        icon: Icon(Iconsax.crop, size: 28, color: iconColor),
        onTap: () async {
          CustomDialog.hide(context);
          await Future.delayed(Durations.short2);
          if (context.mounted) previewImageActionRoute(context, courseImagePath: course.imageLocationJson);
        },
      ),
      AppActionDialogModel(
        title: "Change image",
        icon: Icon(Iconsax.edit, size: 28, color: iconColor),
        onTap: () async {
          CustomDialog.hide(context);
          await Future.delayed(Durations.short2);
          if (context.mounted) await pickImageActionRoute(context, courseDbId: course.id);
        },
      ),
      AppActionDialogModel(
        title: "Remove image",
        icon: Icon(Iconsax.trash, size: 28, color: iconColor),
        onTap: () async {
          CustomDialog.hide(context);
          await Future.delayed(Durations.short2);
          if (context.mounted) CustomDialog.showLoadingDialog(context, msg: "Removing image");
          await deleteCourseImageAction(courseDbId: course.id);
          if (context.mounted) CustomDialog.hide(context);
        },
      ),
    ];
    CustomDialog.show(
      context,
      canPop: true,
      transitionDuration: Durations.medium2,
      reverseTransitionDuration: Durations.short2,
      curve: CustomCurves.defaultIosSpring,
      barrierColor: Colors.black.withAlpha(220),
      child:
          AppActionDialog(
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 16),
              child: CustomText("Adjust image", fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: dialogModels,
          ).animate().fadeIn().scaleXY(
            begin: 0.9,
            end: 1,
            alignment: Alignment.topRight,
            duration: Duration(milliseconds: 500),
            curve: CustomCurves.defaultIosSpring,
          ),
    );
  }

  void showDeleteCourseDialog(String courseId) {
    GlobalNav.withContext((context) {
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

            GlobalNav.withContext((context) => UiUtils.showLoadingDialog(context, message: "Deleting course..."));
            await ModifyCourseActions().onDeleteCourse(courseId: courseId);
            GlobalNav.withContext((context) => context.pop());
            GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Successfully deleted course"));
          },
        ),
      );
    });
  }
}
