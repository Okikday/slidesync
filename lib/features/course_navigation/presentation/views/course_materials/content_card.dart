import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/content_card_providers.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/actions/modify_contents_action.dart';
import 'package:slidesync/features/share_contents/domain/usecases/share_content_uc.dart';
import 'package:slidesync/shared/common_widgets/app_popup_menu_button.dart';
import 'package:slidesync/shared/components/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';
import 'package:slidesync/shared/styles/theme/app_theme_model.dart';
import 'package:slidesync/shared/widgets/build_image_path_widget.dart';
import 'package:slidesync/shared/widgets/loading_view.dart';

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
            constraints: BoxConstraints.tightFor(width: 440, height: 160),
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
                              child: ImageFiltered(
                                imageFilter: ColorFilter.mode(Colors.black.withAlpha(10), BlendMode.color),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return ref
                                        .watch(ContentCardProviders.fetchLinkPreviewDataProvider(content))
                                        .when(
                                          data: (data) => BuildImagePathWidget(
                                            fileDetails: data,
                                            fit: BoxFit.cover,
                                            fallbackWidget: Icon(
                                              WidgetHelper.resolveIconData(content.courseContentType, false),
                                              size: 36,
                                            ),
                                          ),
                                          error: (e, st) => BuildImagePathWidget(
                                            fileDetails: FileDetails(),
                                            fallbackWidget: Icon(
                                              WidgetHelper.resolveIconData(content.courseContentType, false),
                                              size: 36,
                                            ),
                                          ),
                                          loading: () => LoadingView(msg: ''),
                                        );
                                  },
                                ),
                              ),
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

                              AppPopupMenuButton(
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
                                        ShareContentUc().shareFile(
                                          context,
                                          File(content.path.filePath),
                                          filename: content.title,
                                        );
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
                                              UiUtils.showLoadingDialog(
                                                rootNavigatorKey.currentContext!,
                                                message: "Removing content",
                                              );
                                            }
                                            final outcome = await ModifyContentsAction().onDeleteContent(content);

                                            rootNavigatorKey.currentContext?.pop();

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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Builder(
                    builder: (context) {
                      final res = resolveExtension(content);
                      if (res.isEmpty) return const SizedBox();
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: theme.altBackgroundPrimary,
                        ),
                        child: CustomText(res, color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String resolveExtension(CourseContent content) {
  final res = p.extension(content.path.filePath).replaceAll('.', '').toUpperCase();
  switch (content.courseContentType) {
    case CourseContentType.image:
      return res;
    case CourseContentType.document:
      return res;
    case CourseContentType.link:
      return "link";
    default:
      return '';
  }
}
