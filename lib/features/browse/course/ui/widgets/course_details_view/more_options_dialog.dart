import 'dart:math' as math;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/browse/course/ui/actions/course_details_actions.dart';
import 'package:slidesync/features/browse/course/ui/actions/modify_course_actions.dart';
import 'package:slidesync/features/browse/course/ui/widgets/shared/edit_course_bottom_sheet.dart';
import 'package:slidesync/features/share/ui/screens/export/course_export_manager.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_header/animated_shape.dart';
import 'package:slidesync/features/browse/course/ui/actions/modify_collection_actions.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

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
        AppActionDialogModel(
          title: "Create a new collection",
          icon: Icon(Iconsax.add_circle, size: 24, color: theme.secondary),
          onTap: () {
            context.pop();
            CourseDetailsActions.showNewCollectionDialog(context, course.courseId);
          },
        ),

        AppActionDialogModel(
          title: "Edit Course",
          icon: Icon(Iconsax.edit_2, size: 24, color: theme.supportingText),
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
          icon: Icon(Iconsax.magic_star, size: 24, color: theme.supportingText),
          onTap: () {
            context.pop();
            context.pushNamed(Routes.collectionsView.name, extra: course.courseId);
          },
        ),

        AppActionDialogModel(
          title: "Export",
          icon: Icon(Iconsax.export_3, size: 24, color: theme.supportingText),
          onTap: () async {
            context.pop();
            if (course.courseId.isEmpty) return;
            CourseFolderExportManager.showExportScreen(context, course.courseId);
          },
        ),
        AppActionDialogModel(
          title: "Delete",
          icon: Icon(Iconsax.box_remove_copy, size: 24, color: Colors.redAccent),
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
