import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/routes/app_router.dart';

import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/presentation/actions/content_card_actions.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/modify_contents_action.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/features/share/domain/usecases/share_content_uc.dart';

import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';

import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ContentCard extends ConsumerStatefulWidget {
  const ContentCard({super.key, required this.content, this.progress});

  final CourseContent content;
  final double? progress;

  @override
  ConsumerState<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends ConsumerState<ContentCard> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final content = widget.content;
    // final previewDataProvider = ref.watch(ContentCardProviders.fetchLinkPreviewDataProvider(content));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 440, height: 180),
            child: Stack(
              clipBehavior: Clip.antiAlias,
              fit: StackFit.expand,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.pushNamed(Routes.contentGate.name, extra: content);
                  },
                  child: Container(
                    // curve: CustomCurves.defaultIosSpring,
                    // duration: Durations.extralong1,
                    constraints: BoxConstraints(maxHeight: 200, maxWidth: 320),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.fromBorderSide(BorderSide(color: theme.altBackgroundSecondary.withAlpha(100))),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox.expand(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: ContentCardPreviewImage(content: content),
                            ),
                          ),
                        ),
                        LinearProgressIndicator(
                          value: (widget.progress?.clamp(0, 100) ?? 0.0),
                          color: theme.primaryColor,
                          backgroundColor: theme.background.lightenColor(theme.isDarkMode ? 0.15 : 0.85).withAlpha(200),
                        ),

                        Container(
                          color: theme.background.lightenColor(theme.isDarkMode ? 0.15 : 0.85).withAlpha(200),
                          padding: EdgeInsets.fromLTRB(12, 8, 4, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2.5,
                                  children: [
                                    Flexible(
                                      child: Tooltip(
                                        message: content.title,
                                        triggerMode: TooltipTriggerMode.tap,
                                        child: CustomText(
                                          content.title,
                                          color: theme.onBackground,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    CustomText(
                                      widget.progress == null || widget.progress == 0
                                          ? "Start reading!"
                                          : widget.progress == 1
                                          ? "Completed!"
                                          : "${((widget.progress?.clamp(0, 100) ?? 0.0) * 100.0).toInt()}% read",
                                      fontSize: 10,
                                      color: widget.progress == 1 ? theme.primary : theme.supportingText,
                                    ),
                                  ],
                                ),
                              ),

                              ContentCardPopUpMenuButton(content: content),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ContentTypeBadge(content: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ContentCardPopUpMenuButton extends StatelessWidget {
  const ContentCardPopUpMenuButton({super.key, required this.content});

  final CourseContent content;

  @override
  Widget build(BuildContext context) {
    return AppPopupMenuButton(
      iconSize: 16,
      actions: [
        PopupMenuAction(title: "Add to Group", iconData: Iconsax.additem, onTap: () {}),
        if (content.courseContentType == CourseContentType.link)
          PopupMenuAction(
            title: "Copy",
            iconData: Icons.copy,
            onTap: () {
              Clipboard.setData(ClipboardData(text: content.path.fileDetails.urlPath));
            },
          ),
        PopupMenuAction(
          title: "Share",
          iconData: Iconsax.share_copy,
          onTap: () {
            UiUtils.showFlushBar(context, msg: "Preparing content...");
            if (content.courseContentType == CourseContentType.document ||
                content.courseContentType == CourseContentType.image) {
              ShareContentUc().shareFile(context, File(content.path.filePath), filename: content.title);
            } else if (content.courseContentType == CourseContentType.link) {
              ShareContentUc().shareText(context, content.path.urlPath);
            } else {
              UiUtils.showFlushBar(context, msg: "Unable to share content!");
            }
          },
        ),
        PopupMenuAction(
          title: "Delete",
          iconData: Icons.delete,
          onTap: () async {
            UiUtils.showCustomDialog(
              context,
              child: ConfirmDeletionDialog(
                content: "Are you sure you want to delete this item?",
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
                  UiUtils.hideDialog(context);

                  if (context.mounted) {
                    UiUtils.showLoadingDialog(rootNavigatorKey.currentContext!, message: "Removing content");
                  }
                  final outcome = await ModifyContentsAction().onDeleteContent(content.contentId);

                  rootNavigatorKey.currentContext?.pop();

                  if (context.mounted) {
                    if (outcome == null) {
                      UiUtils.showFlushBar(context, msg: "Deleted content!", vibe: FlushbarVibe.success);
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
    );
  }
}

class ContentCardPreviewImage extends StatelessWidget {
  const ContentCardPreviewImage({super.key, required this.content});

  final CourseContent content;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ColorFilter.mode(Colors.black.withAlpha(10), BlendMode.color),
      child: BuildImagePathWidget(
        fileDetails: FileDetails(
          filePath: CreateContentPreviewImage.genPreviewImagePath(filePath: content.path.filePath),
        ),
        fit: BoxFit.cover,
        fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, false), size: 36),
      ),
    );
  }
}

class ContentTypeBadge extends ConsumerWidget {
  const ContentTypeBadge({super.key, required this.content});

  final CourseContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Positioned(
      top: 8,
      right: 8,
      child: Builder(
        builder: (context) {
          final res = ContentCardActions.resolveExtension(content);
          if (res.isEmpty) return const SizedBox();
          return DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.altBackgroundPrimary),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: CustomText(res, color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
