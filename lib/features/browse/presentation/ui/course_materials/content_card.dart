import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/share/presentation/actions/share_content_actions.dart';
import 'package:slidesync/routes/app_router.dart';

import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/presentation/actions/content_card_actions.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/modify_contents_action.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';

import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ContentCard extends ConsumerStatefulWidget {
  const ContentCard({super.key, required this.content});

  final CourseContent content;

  @override
  ConsumerState<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends ConsumerState<ContentCard> {
  late final Stream<double> progressStream;

  @override
  void initState() {
    super.initState();
    progressStream = ContentTrackRepo.watchByContentId(
      widget.content.contentId,
    ).map((c) => c?.progress ?? 0.0).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final content = widget.content;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              context.pushNamed(Routes.contentGate.name, extra: content);
            },
            child: Container(
              // curve: CustomCurves.defaultIosSpring,
              // duration: Durations.extralong1,
              constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(40))),
              ),
              child: Stack(
                // clipBehavior: Clip.antiAlias,
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Opacity(opacity: 0.6, child: ContentCardPreviewImage(content: content)),
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: progressStream,
                        builder: (context, asyncSnapshot) {
                          return LinearProgressIndicator(
                            value: asyncSnapshot.hasData && asyncSnapshot.data != null ? asyncSnapshot.data : 0.0,
                            color: theme.primaryColor,
                            backgroundColor: theme.background
                                .lightenColor(theme.isDarkMode ? 0.15 : 0.85)
                                .withAlpha(200),
                          );
                        },
                      ),

                      Container(
                        padding: EdgeInsets.fromLTRB(12, 8, 4, 8),
                        decoration: BoxDecoration(
                          color: theme.background.lightenColor(theme.isDarkMode ? 0.15 : 0.85).withAlpha(200),
                          borderRadius: BorderRadius.only(
                            bottomLeft: const Radius.circular(16),
                            bottomRight: const Radius.circular(16),
                          ),
                        ),
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
                                  StreamBuilder(
                                    stream: progressStream,
                                    builder: (context, asyncSnapshot) {
                                      final progress = asyncSnapshot.hasData && asyncSnapshot.data != null
                                          ? asyncSnapshot.data
                                          : 0.0;
                                      return CustomText(
                                        progress == 0.0
                                            ? "Start reading!"
                                            : progress == 1.0
                                            ? "Completed!"
                                            : "${((progress?.clamp(0, 100) ?? 0.0) * 100.0).toInt()}% read",
                                        fontSize: 10,
                                        color: progress == 1.0 ? theme.primary : theme.supportingText,
                                      );
                                    },
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
                  ContentTypeBadge(content: content),
                ],
              ),
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
          onTap: () async {
            ShareContentActions.shareContent(context, content.contentId);
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
        fileDetails: FileDetails(filePath: content.previewPath ?? ''),
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
              child: CustomText(res, color: theme.onBackground, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
