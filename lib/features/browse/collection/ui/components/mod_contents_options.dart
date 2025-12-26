import 'package:collection/collection.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_content_card_actions.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class ModContentsOptions extends ConsumerWidget {
  final String collectionTitle;
  final int? collectionLength;

  final void Function(List<CourseContent> contents) onMoveContents;
  const ModContentsOptions({
    super.key,
    required this.collectionTitle,
    this.collectionLength,
    required this.onMoveContents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcvp = ref.read(CollectionMaterialsProvider.modState);
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: mcvp.selectSignal,
      builder: (context, _, child) {
        return PinnedHeaderSliver(
          child: AnimatedContainer(
            duration: Durations.extralong1,
            curve: CustomCurves.defaultIosSpring,
            height: mcvp.selectedContents.isNotEmpty ? 50 : 0,

            margin: EdgeInsets.symmetric(horizontal: 20),
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: theme.background.lightenColor(context.isDarkMode ? 0.2 : 0.9),
              border: Border.all(color: theme.supportingText.withAlpha(20)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                CustomElevatedButton(
                  backgroundColor: theme.secondary.withAlpha(60),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () {
                    mcvp.clearContents();
                  },
                  child: Icon(Icons.cancel_rounded, color: theme.onSurface),
                ),

                CustomElevatedButton(
                  backgroundColor: theme.supportingText.withAlpha(20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () {
                    final contents = mcvp.selectedContents.toList();
                    mcvp.clearContents();
                    onMoveContents(contents);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(PhosphorIcons.scissors(), color: theme.onSurface),
                      CustomText("Move", color: theme.onSurface),
                    ],
                  ),
                ),

                CustomElevatedButton(
                  backgroundColor: theme.supportingText.withAlpha(20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () async {
                    final contents = mcvp.selectedContents.toList();
                    mcvp.clearContents();

                    await ShareContentActions.shareContents(context, contents.map((e) => e.contentId).toList());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(PhosphorIcons.share(), color: theme.onSurface),
                      CustomText("Share", color: theme.onSurface),
                    ],
                  ),
                ),

                CustomElevatedButton(
                  backgroundColor: theme.supportingText.withAlpha(20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: ConstantSizing.borderRadiusCircle,
                  onClick: () async {
                    if (mcvp.selectedContents.isEmpty) return;
                    final anyContent = mcvp.selectedContents.firstWhereOrNull((c) => c.parentId.isNotEmpty);
                    if (anyContent == null) return;
                    final collection = await CourseCollectionRepo.getById(anyContent.parentId);
                    if (collection == null) return;
                    await collection.contents.load();
                    mcvp.selectAllContent(collection.contents.toList());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(PhosphorIcons.listBullets(), color: theme.onSurface),
                      CustomText("Select All", color: theme.onSurface),
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
                            "Are you sure you want to delete ${mcvp.selectedContents.length == 1 ? "this" : "${mcvp.selectedContents.length} item(s)"} from \"$collectionTitle\".",
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
                            for (final e in mcvp.selectedContents) {
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
              ].map((e) => Padding(padding: EdgeInsets.only(right: 8), child: e)).toList(),
            ),
          ),
        );
      },
    );
  }
}
