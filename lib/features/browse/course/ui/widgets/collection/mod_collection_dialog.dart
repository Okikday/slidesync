import 'dart:math' as math;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/share/presentation/actions/share_content_actions.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_header/animated_shape.dart';
import 'package:slidesync/features/browse/course/ui/widgets/collection/edit_collection_title_bottom_sheet.dart';
import 'package:slidesync/features/browse/course/ui/actions/modify_collection_actions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ModCollectionDialog extends ConsumerStatefulWidget {
  final String courseId;
  final CourseCollection collection;

  const ModCollectionDialog({super.key, required this.courseId, required this.collection});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ModCollectionDialogState();
}

class _ModCollectionDialogState extends ConsumerState<ModCollectionDialog> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late final RoundedPolygon shape;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.text = widget.collection.collectionTitle;
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
    final collection = widget.collection;
    final mca = ModifyCollectionActions();
    return AppActionDialog(
      blurSigma: Offset(4, 4),
      backgroundColor: theme.surface.withAlpha(200),

      leading: Padding(
        padding: const EdgeInsets.only(bottom: ConstantSizing.spaceLarge),
        child: Row(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(left: 4.0),
            //   child: Container(
            //     padding: EdgeInsets.all(16),
            //     alignment: Alignment.center,
            //     margin: EdgeInsets.only(left: 12),
            //     decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primaryColor.withAlpha(40)),
            //     child: BuildImagePathWidget(
            //       fileDetails: FileDetails(),
            //       fallbackWidget: SizedBox.square(
            //         dimension: 30,
            //         child: ClipPath(
            //           clipper: MorphClipper(path: shape.toPath(), size: Size(20, 20)),
            //           child: ColoredBox(color: theme.primaryColor),
            //         ),
            //       )
            //     ),
            //   ),
            // ),
            ConstantSizing.rowSpacingMedium,

            Expanded(
              child: GestureDetector(
                onTap: () {
                  CustomDialog.hide(context);
                  UiUtils.showCustomDialog(context, child: EditCollectionTitleBottomSheet(collection: collection));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CustomText(
                    collection.collectionTitle,
                    decorationStyle: TextDecorationStyle.wavy,
                    textDecoration: TextDecoration.underline,
                    decorationColor: theme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.onBackground,
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
        //   title: "Select",
        //   icon: Icon(Iconsax.tick_circle_copy, size: 24, color: theme.supportingText),
        //   onTap: () {},
        // ),
        AppActionDialogModel(
          title: "View contents",
          icon: Icon(Iconsax.forward_copy, size: 24, color: theme.supportingText),
          onTap: () {
            CustomDialog.hide(context);
            context.pushNamed(Routes.modifyContents.name, extra: collection.collectionId);
          },
        ),

        AppActionDialogModel(
          title: "Share",
          icon: Icon(Icons.share_outlined, size: 24, color: theme.supportingText),
          onTap: () async {
            GlobalNav.popGlobal();
            await ShareContentActions.shareCollection(context, collection.collectionId);
          },
        ),
        AppActionDialogModel(
          title: "Delete",
          icon: Icon(Iconsax.box_remove_copy, size: 24, color: Colors.redAccent),
          onTap: () async {
            GlobalNav.popGlobal();

            if (context.mounted) {
              CustomDialog.show(
                context,
                canPop: true,
                barrierColor: Colors.black.withValues(alpha: 0.6),
                transitionType: TransitionType.cupertinoDialog,
                transitionDuration: Durations.medium2,
                child: ConfirmDeletionDialog(
                  content:
                      "This will delete \"${collection.collectionTitle}\"."
                      "\n\nAre you sure you want to delete this collection?",
                  onPop: () {
                    GlobalNav.popGlobal();
                  },
                  onCancel: () {
                    GlobalNav.popGlobal();
                  },
                  onDelete: () async {
                    await mca.onDeleteCollection(context, collection: collection);
                  },
                ),
              );
            }
          },
        ),
      ],
    ).animate().fadeIn().scaleXY(
      begin: 0.4,
      end: 1,
      alignment: Alignment.centerRight,
      duration: Durations.extralong1,
      curve: CustomCurves.defaultIosSpring,
    );
  }
}
