import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroine/heroine.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_content_card_actions.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_contents_action.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ContentCardContextMenu extends ConsumerStatefulWidget {
  final CourseContent content;
  const ContentCardContextMenu({super.key, required this.content});

  @override
  ConsumerState<ContentCardContextMenu> createState() => _ContentCardContextMenuState();
}

class _ContentCardContextMenuState extends ConsumerState<ContentCardContextMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;

    var divider = Divider(color: theme.onSurface.withAlpha(20), height: 0);

    return Stack(
      children: [
        Positioned.fill(
          child: SizedBox.expand(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: Heroine(
                tag: widget.content.contentId,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  constraints: BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    color: theme.background.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.fromBorderSide(
                      BorderSide(color: theme.supportingText.withAlpha(40), strokeAlign: BorderSide.strokeAlignOutside),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          spacing: 8,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.onSurface.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: BuildImagePathWidget(
                                fileDetails: widget.content.thumbnailDetails,
                                fallbackWidget: Icon(
                                  WidgetHelper.resolveIconData(widget.content.courseContentType),
                                  size: 20,
                                ),
                              ),
                            ),
                            Expanded(
                              child: CustomText(
                                widget.content.title,
                                fontSize: 14,
                                color: theme.onSurface,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstantSizing.columnSpacingMedium,
                      divider,
                      ConstantSizing.columnSpacingSmall,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLeadingMenuOption(
                              "Open",
                              iconData: HugeIconsStroke.playCircle,
                              onTap: () {
                                Navigator.pop(context);
                                ContentViewGateActions.redirectToViewer(ref, widget.content, openOutsideApp: false);
                              },
                            ),
                            widget.content.courseContentType == CourseContentType.link
                                ? _buildLeadingMenuOption(
                                    "Copy",
                                    iconData: HugeIconsStroke.copyLink,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Clipboard.setData(ClipboardData(text: widget.content.path.fileDetails.urlPath));
                                      UiUtils.showFlushBar(context, msg: "Link copied to clipboard");
                                    },
                                  )
                                : _buildLeadingMenuOption(
                                    "Launch",
                                    iconData: HugeIconsStroke.sendToMobile,
                                    onTap: () {
                                      Navigator.pop(context);
                                      ContentViewGateActions.redirectToViewer(
                                        ref,
                                        widget.content,
                                        openOutsideApp: true,
                                      );
                                    },
                                  ),
                            _buildLeadingMenuOption(
                              "Share",
                              iconData: HugeIconsStroke.share01,
                              onTap: () {
                                Navigator.pop(context);
                                ShareContentActions.shareContent(context, widget.content.contentId);
                              },
                            ),
                          ],
                        ),
                      ),
                      divider,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BuildPlainActionButton(
                              title: "Select",
                              icon: Icon(HugeIconsStroke.checkmarkCircle01, color: theme.onSurface),
                              onTap: () {
                                ref.read(CollectionMaterialsProvider.modState.notifier).selectContent(widget.content);
                                Navigator.pop(context);
                              },
                            ),
                            divider,
                            BuildPlainActionButton(
                              title: "Rename",
                              icon: Icon(HugeIconsStroke.cursorEdit01, color: theme.onSurface),
                              onTap: () {
                                Navigator.pop(context);
                                ModifyContentCardActions.onRenameContent(context, widget.content);
                              },
                            ),
                            divider,
                            BuildPlainActionButton(
                              title: "Delete",
                              textStyle: TextStyle(fontSize: 14, color: Colors.red),
                              icon: Icon(HugeIconsSolid.delete02, color: Colors.red.withAlpha(200)),
                              onTap: () {
                                Navigator.pop(context);
                                UiUtils.showCustomDialog(
                                  context,
                                  child: ConfirmDeletionDialog(
                                    content: "Are you sure you want to delete this item?",
                                    onPop: () {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      } else {
                                        GlobalNav.popGlobal();
                                      }
                                    },
                                    onCancel: () {
                                      GlobalNav.popGlobal();
                                    },
                                    onDelete: () async {
                                      Navigator.pop(context);

                                      if (context.mounted) {
                                        UiUtils.showLoadingDialog(context, message: "Removing content");
                                      }
                                      final outcome = await ModifyContentsAction().onDeleteContent(
                                        widget.content.contentId,
                                      );

                                      GlobalNav.popGlobal();

                                      if (context.mounted) {
                                        if (outcome == null) {
                                          UiUtils.showFlushBar(
                                            context,
                                            msg: "Deleted content!",
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // .animate().fadeIn().scaleXY(
                //   alignment: Alignment.topCenter,
                //   begin: 0.4,
                //   end: 1,
                //   curve: CustomCurves.defaultIosSpring,
                //   duration: Duration(milliseconds: 550),
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadingMenuOption(String title, {required IconData iconData, required void Function() onTap}) {
    final theme = ref;
    return Expanded(
      child: CustomElevatedButton(
        contentPadding: EdgeInsets.zero,
        pixelWidth: 100,
        pixelHeight: 60,
        onClick: onTap,
        backgroundColor: Colors.transparent,
        child: Column(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 24, color: theme.onBackground.withAlpha(200)),
            CustomText(
              title,
              fontSize: 14,
              color: theme.onBackground,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
