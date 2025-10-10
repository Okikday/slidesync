import 'package:collection/collection.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/modify_content_card_actions.dart';
import 'package:slidesync/features/manage/presentation/contents/controllers/src/modify_contents_controller.dart';
import 'package:slidesync/features/manage/presentation/contents/controllers/state/modify_contents_state.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class ModifyContentsHeader extends ConsumerWidget {
  final String collectionTitle;
  final int? collectionLength;

  final VoidCallback? onMoveContents;
  const ModifyContentsHeader({super.key, required this.collectionTitle, this.collectionLength, this.onMoveContents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcvp = ref.watch(ModifyContentsController.modifyContentsStateProvider);
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: mcvp.selectedContentsNotifier,
      builder: (context, value, child) {
        return PinnedHeaderSliver(
          child: AnimatedContainer(
            duration: Durations.extralong1,
            curve: CustomCurves.defaultIosSpring,
            height: value.isNotEmpty ? 50 : 0,
            color: context.scaffoldBackgroundColor.withAlpha(225),
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CustomElevatedButton(
                  backgroundColor: theme.surface.withAlpha(200),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () {
                    mcvp.clearContents();
                  },
                  child: Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.cancel_rounded, color: theme.onSurface),
                      CustomText("Cancel", color: theme.onSurface),
                    ],
                  ),
                ),

                CustomElevatedButton(
                  backgroundColor: Colors.red.withAlpha(100),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () {
                    UiUtils.showCustomDialog(
                      context,
                      child: ConfirmDeletionDialog(
                        content:
                            "Are you sure you want to delete ${mcvp.selectedContentsNotifier.value.length} item(s) from \"${collectionTitle}\".",
                        onPop: () {
                          if (context.mounted) {
                            UiUtils.hideDialog(context);
                          } else {
                            rootNavigatorKey.currentContext?.pop();
                          }
                        },
                        onCancel: () {
                          rootNavigatorKey.currentContext?.pop();
                        },
                        onDelete: () async {
                          if (context.mounted) {
                            UiUtils.hideDialog(context);
                          } else {
                            rootNavigatorKey.currentContext?.pop();
                          }
                          UiUtils.showLoadingDialog(context, message: "Removing contents", canPop: false);

                          final String? outcome = (await Result.tryRunAsync(() async {
                            String? outcome;
                            for (final e in mcvp.selectedContentsNotifier.value) {
                              outcome = await ModifyContentCardActions.onDeleteContent(context, e, false);
                            }
                            return outcome;
                          })).data;
                          mcvp.clearContents();
                          rootNavigatorKey.currentContext?.pop();
                          if (context.mounted) {
                            if (outcome == null) {
                              UiUtils.showFlushBar(
                                context,
                                msg: "Successfully removed contents!",
                                vibe: FlushbarVibe.success,
                              );
                            } else if (outcome.toLowerCase().contains("error")) {
                              UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.error);
                            } else {
                              UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.warning);
                            }
                          }
                        },
                      ),
                    );
                  },
                  child: Row(
                    spacing: 4,
                    children: [
                      Icon(Iconsax.trash, color: Colors.red),
                      CustomText("Delete", color: Colors.red),
                    ],
                  ),
                ),

                CustomElevatedButton(
                  backgroundColor: theme.surface.withAlpha(200),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: onMoveContents,
                  child: CustomText("Move", color: theme.onSurface),
                ),

                CustomElevatedButton(
                  backgroundColor: theme.surface.withAlpha(200),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () async {
                    if (mcvp.selectedContentsNotifier.value.isEmpty) return;
                    final anyContent = mcvp.selectedContentsNotifier.value.firstWhereOrNull(
                      (c) => c.parentId.isNotEmpty,
                    );
                    if (anyContent == null) return;
                    final collection = await CourseCollectionRepo.getById(anyContent.parentId);
                    if (collection == null) return;
                    await collection.contents.load();
                    mcvp.selectAllContent(collection.contents.toList());
                  },
                  child: CustomText("Select All", color: theme.onSurface),
                ),
              ].map((e) => Padding(padding: EdgeInsets.only(right: 8), child: e)).toList(),
            ),
          ),
        );
      },
    );
  }
}
