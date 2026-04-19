import 'dart:math' as math;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/browse/course/ui/actions/modify_course_actions.dart';
import 'package:slidesync/features/browse/course/ui/widgets/shared/edit_course_bottom_sheet.dart';
import 'package:slidesync/features/share/ui/screens/export/course_export_manager.dart';
import 'package:slidesync/core/apis/abstract/sync_coordinator.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_header/animated_shape.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';

class MoreOptionsDialog extends ConsumerStatefulWidget {
  final Course course;

  const MoreOptionsDialog({super.key, required this.course});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MoreOptionsDialogState();
}

class _MoreOptionsDialogState extends ConsumerState<MoreOptionsDialog> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late final RoundedPolygon shape;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.text = widget.course.courseTitle;
    focusNode = FocusNode();
    shape = materialShapes[math.Random().nextInt(materialShapes.length)].shape;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final course = widget.course;
    // final mca = ModifyCollectionActions();
    return AppActionDialog(
      blurSigma: Offset(4, 4),
      backgroundColor: theme.surface.withAlpha(200),

      leading: Padding(
        padding: const EdgeInsets.only(bottom: ConstantSizing.spaceMedium),
        child: Row(
          children: [
            ConstantSizing.rowSpacingMedium,

            Expanded(
              child: GestureDetector(
                onTap: () {
                  // CustomDialog.hide(context);
                  // UiUtils.showCustomDialog(context, child: EditCollectionTitleBottomSheet(collection: collection));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CustomText(
                    course.courseName,
                    decorationColor: theme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.onBackground,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            ConstantSizing.rowSpacingMedium,
          ],
        ),
      ),
      actions: [
        // AppActionDialogModel(
        //   title: "Create a new collection",
        //   icon: Icon(HugeIconsSolid.addCircle, size: 24, color: theme.onBackground),
        //   onTap: () {
        //     context.pop();
        //     CourseDetailsActions.showNewCollectionDialog(context, course.courseId);
        //   },
        // ),
        AppActionDialogModel(
          title: "Edit Course",
          icon: Icon(HugeIconsSolid.edit01, size: 24, color: theme.onBackground),
          onTap: () async {
            context.pop();
            await showModalBottomSheet(
              context: context,
              enableDrag: false,
              showDragHandle: false,
              isScrollControlled: true,
              builder: (context) => EditCourseBottomSheet(courseId: course.courseId),
            );
          },
        ),

        AppActionDialogModel(
          title: "See all collections",
          icon: Icon(HugeIconsSolid.magicWand01, size: 24, color: theme.onBackground),
          onTap: () {
            context.pop();
            context.pushNamed(Routes.collectionsView.name, extra: course.courseId);
          },
        ),

        AppActionDialogModel(
          title: "Upload to Public repository",
          icon: Icon(Iconsax.export_1, size: 24, color: theme.onBackground),
          onTap: () async {
            context.pop();
            if (course.courseId.isEmpty) return;

            // Show loading dialog
            UiUtils.showLoadingDialog(context, message: "Uploading course...", canPop: false);

            try {
              // Get user ID
              final userIdResult = await UserDataFunctions().getUserId();
              if (!userIdResult.isSuccess || userIdResult.data == null) {
                GlobalNav.withContext((c) => c.pop());
                UiUtils.showFlushBar(context, msg: 'User not authenticated', vibe: FlushbarVibe.error);
                return;
              }

              // Use SyncCoordinator to upload the course
              final coordinator = SyncCoordinator();
              final result = await coordinator.syncCourse(
                course: course,
                userId: userIdResult.data!,
                vaultLinks: [], // TODO: Get vault links from config
              );

              // Close loading dialog
              GlobalNav.withContext((c) => c.pop());

              if (result.data?.success ?? false) {
                UiUtils.showFlushBar(context, msg: 'Course uploaded successfully!');
              } else {
                UiUtils.showFlushBar(context, msg: result.data?.error ?? 'Upload failed', vibe: FlushbarVibe.error);
              }
            } catch (e) {
              // Close loading dialog
              GlobalNav.withContext((c) => c.pop());
              UiUtils.showFlushBar(context, msg: 'Upload failed: $e', vibe: FlushbarVibe.error);
            }
          },
        ),

        AppActionDialogModel(
          title: "Export",
          icon: Icon(Iconsax.export_3, size: 24, color: Colors.blueAccent),
          titleColor: Colors.blueAccent,
          onTap: () async {
            context.pop();
            if (course.courseId.isEmpty) return;
            CourseFolderExportManager.showExportScreen(context, course.courseId);
          },
        ),
        AppActionDialogModel(
          title: "Delete",
          icon: Icon(Iconsax.box_remove_copy, size: 24, color: Colors.redAccent),
          titleColor: Colors.redAccent,
          onTap: () async {
            context.pop();
            if (course.courseId.isEmpty) return;
            ModifyCourseActions().showDeleteCourseDialog(course.courseId);
          },
        ),
      ],
    ).animate().fadeIn().scaleXY(
      begin: 0.6,
      end: 1,
      alignment: Alignment.topRight,
      duration: Durations.extralong1,
      curve: CustomCurves.defaultIosSpring,
    );
  }
}
