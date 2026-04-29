import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/logic/src/collections/modify_collection_uc.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/content_thumbnail_creator.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/course_description_dialog.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/edit_course_bottom_sheet.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/preview_modify_course_image_dialog.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class ModifyCourseActions {
  /// When the course image is clicked, it shows some options in a dialog the user can choose from.
  static void onClickCourseImage(WidgetRef ref, {required String courseId}) async {
    final course = await CourseRepo.getByUid(courseId);
    if (course == null) return;
    final hasImage = await File(course.localThumbnailPath).exists();
    final context = ref.context;
    final iconColor = ref.supportingText;

    Future<void> closeAndWaitThenExecute({required void Function() operation}) {
      if (context.mounted) CustomDialog.hide(context);
      return Future.delayed(Durations.short1).then((_) => operation());
    }

    List<({String title, IconData iconData, void Function() onTap})> options = [
      (
        title: hasImage ? "View" : "Set Image",
        iconData: hasImage ? HugeIconsSolid.view : HugeIconsSolid.imageAdd02,
        onTap: () async => closeAndWaitThenExecute(
          operation: () => hasImage
              ? _previewImageActionRoute(courseImagePath: course.metadata.thumbnail ?? FilePath.empty())
              : _pickImageActionRoute(courseDbId: course.id),
        ),
      ),
      if (hasImage) ...[
        (
          title: "Change",
          iconData: HugeIconsSolid.imageUpload,
          onTap: () async => closeAndWaitThenExecute(operation: () => _pickImageActionRoute(courseDbId: course.id)),
        ),
        (
          title: "Remove image",
          iconData: HugeIconsSolid.delete02,
          onTap: () async => closeAndWaitThenExecute(operation: () => _deleteCourseImageAction(courseDbId: course.id)),
        ),
      ],
    ];

    final dialogModels = options.map((e) {
      final resolveColor = e.title.startsWith("Remove") ? Colors.red : iconColor;
      return AppActionDialogModel(
        title: e.title,
        titleColor: resolveColor,
        icon: Icon(e.iconData, size: 28, color: resolveColor),
        onTap: e.onTap,
      );
    }).toList();

    GlobalNav.withContext(
      (context) => CustomDialog.show(
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
                child: CustomText(
                  hasImage ? course.title : "No image set",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ref.onBackground,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              actions: dialogModels,
            ).animate().fadeIn().scaleXY(
              begin: 0.9,
              end: 1,
              alignment: Alignment.topRight,
              duration: Duration(milliseconds: 500),
              curve: CustomCurves.defaultIosSpring,
            ),
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

            GlobalNav.withContext(
              (context) => UiUtils.showLoadingDialog(context, message: "Deleting course...", canPop: false),
            );
            await _onDeleteCourse(courseId: courseId);
            GlobalNav.withContext((context) => context.pop());
            GlobalNav.withContext((context) => context.pop());
            GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Successfully deleted course"));
          },
        ),
      );
    });
  }

  /// This deletes the course image
  static Future<void> _deleteCourseImageAction({required int courseDbId}) async {
    GlobalNav.withContext((context) => CustomDialog.showLoadingDialog(context, msg: "Removing image", canPop: false));
    final course = await CourseRepo.getCourseById(courseDbId);
    if (course == null) return;
    final thumbnailPath = course.metadata.thumbnail;
    if (thumbnailPath != null && thumbnailPath.containsLocalPath) {
      await CourseRepo.addCourse(
        course.copyWith(
          metadata: course.metadata.copyWith(thumbnail: FilePath()),
          lastModified: DateTime.now(),
        ),
      );
      if (thumbnailPath.local != null) await FileUtils.deleteFileAtPath(thumbnailPath.local!);

      GlobalNav.withContext((context) => CustomDialog.hide(context));
    }
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
        transitionType: TransitionType.fade,
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
  static void _previewImageActionRoute({required FilePath courseImagePath}) {
    if (!courseImagePath.containsLocalPath) return;
    GlobalNav.withContext(
      (context) => CustomDialog.show(
        context,
        transitionDuration: Durations.short3,
        reverseTransitionDuration: Durations.short4,
        canPop: true,
        barrierColor: Colors.black.withAlpha(200),
        child: PreviewModifyCourseImageDialog(imagePath: courseImagePath),
      ),
    );
  }

  /// When the user Modifies image
  static Future<Result> _modifyCourseImageAction({required int id, required File newImageFile}) async {
    final Result<bool?> createCourseOutcome = await Result.tryRunAsync<bool>(() async {
      Course? course = await CourseRepo.getCourseById(id);
      if (course == null) return false;

      final oldPath = course.metadata.thumbnail?.local;
      if (oldPath != null && oldPath.isNotEmpty) await FileUtils.deleteFileAtPath(oldPath);
      final String? newPath = await ContentThumbnailCreator.createThumbnailForCourse(
        newImageFile.path,
        filename: course.uid,
      );
      if (newPath != null) {
        final newCourse = course.copyWith(
          metadata: course.metadata.copyWith(thumbnail: FilePath(local: newPath)),
          lastModified: DateTime.now(),
        );
        log("New course thumbnail path: ${newCourse.metadata}");
        await CourseRepo.addCourse(newCourse);
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

  /// This picks image from device, shows a loading dialog
  static Future<void> _pickImageActionRoute({required int courseDbId}) async {
    GlobalNav.withContext(
      (context) => UiUtils.showLoadingDialog(
        context,
        message: "Selecting image",
        backgroundColor: Colors.white10,
        blurSigma: Offset(2, 2),
        canPop: false,
      ),
    );
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      GlobalNav.withContext((context) {
        UiUtils.hideDialog(context);
        UiUtils.showFlushBar(context, msg: "Oops, You didn't select an image!", vibe: FlushbarVibe.warning);
      });
      return;
    }

    final result = await _modifyCourseImageAction(id: courseDbId, newImageFile: File(pickedImage.path));

    GlobalNav.withContext((context) {
      UiUtils.hideDialog(context);
      UiUtils.showFlushBar(
        context,
        msg: result.isSuccess ? "Successfully changed course Image!" : "Unable to change course Image!",
        vibe: result.isSuccess ? FlushbarVibe.success : FlushbarVibe.error,
      );
    });
  }

  /// When the user clicks to delete the course, on the Dialog
  static Future<void> _onDeleteCourse({required String courseId}) async {
    final course = await CourseRepo.getByUid(courseId);
    if (course == null) return;
    for (final item in course.modules) {
      await ModifyCollectionUc().deleteCollection(item);
    }

    await CourseRepo.delete(course.id);
  }
}
