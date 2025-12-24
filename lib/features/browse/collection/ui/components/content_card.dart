import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/retrieve_content_uc.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_content_card_actions.dart';
import 'package:slidesync/features/settings/logic/models/settings_model.dart';
import 'package:slidesync/features/settings/providers/settings_controller.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/routes/app_router.dart';

import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/collection/ui/actions/content_card_actions.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_contents_action.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';

import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ContentCard extends ConsumerStatefulWidget {
  const ContentCard({super.key, required this.content});

  final CourseContent content;

  @override
  ConsumerState<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends ConsumerState<ContentCard> {
  late Stream<double> progressStream;
  Future<PreviewLinkDetails?>? previewDetailsFuture;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    progressStream = ContentTrackRepo.watchByContentId(
      widget.content.contentId,
    ).map((c) => c?.progress ?? 0.0).asBroadcastStream();

    if (widget.content.courseContentType == CourseContentType.link) {
      previewDetailsFuture = RetriveContentUc.getLinkPreviewData(widget.content.path.urlPath);
    } else {
      previewDetailsFuture = null;
    }
  }

  @override
  void didUpdateWidget(covariant ContentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _initializeData();
      setState(() {});
    }
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
              constraints: BoxConstraints(maxHeight: 400, maxWidth: 700),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(40))),
                boxShadow: context.isDarkMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.05),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.04),
                          offset: Offset(0, 6),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
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
                            child: Opacity(
                              opacity: 0.6,
                              child: ContentCardPreviewImage(
                                content: content,
                                previewDetailsFuture: previewDetailsFuture,
                              ),
                            ),
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
                        padding: EdgeInsets.fromLTRB(8, 8, 4, 8),
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
                                    child: ContentCardTitle(
                                      content: content,
                                      previewDetailsFuture: previewDetailsFuture,
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
                                            : (progress != null && progress > .95)
                                            ? "Almost done!"
                                            : "${((progress?.clamp(0, 100) ?? 0.0) * 100.0).toInt()}% read",
                                        fontSize: 10,
                                        color: progress == 1.0 ? theme.primary : theme.supportingText,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            ContentCardPopUpMenuButton(content: content, previewDetailsFuture: previewDetailsFuture),
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

class ContentCardTitle extends ConsumerWidget {
  const ContentCardTitle({super.key, required this.content, required this.previewDetailsFuture});

  final CourseContent content;
  final Future<PreviewLinkDetails?>? previewDetailsFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return FutureBuilder(
      future: previewDetailsFuture,
      builder: (context, asyncSnapshot) {
        final resolveUrl =
            content.courseContentType == CourseContentType.link && content.title.toLowerCase() == "unknown"
            ? content.path.urlPath
            : content.title;
        final resolveTitle = previewDetailsFuture == null
            ? content.title
            : (asyncSnapshot.hasData && asyncSnapshot.data != null
                  ? (asyncSnapshot.data?.title ?? resolveUrl)
                  : resolveUrl);
        return Tooltip(
          showDuration: 4.inSeconds,
          message: resolveTitle,
          triggerMode: TooltipTriggerMode.tap,
          child: CustomText(
            resolveTitle,
            color: theme.onBackground,
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

class ContentCardPopUpMenuButton extends ConsumerWidget {
  const ContentCardPopUpMenuButton({super.key, required this.content, required this.previewDetailsFuture});

  final CourseContent content;
  final Future<PreviewLinkDetails?>? previewDetailsFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 26,
      height: 26,
      child: AppPopupMenuButton(
        iconSize: 22,
        padding: EdgeInsets.zero,
        icon: Iconsax.more_copy,
        actions: [
          PopupMenuAction(
            title: content.courseContentType == CourseContentType.link ? "Open link" : "Open",
            iconData: Iconsax.play,
            onTap: () {
              context.pushNamed(Routes.contentGate.name, extra: content);
            },
          ),
          if (content.courseContentType != CourseContentType.link)
            ...(() {
              final settingsModelProvider = ref.watch(SettingsController.settingsProvider);
              final settingsModel = settingsModelProvider.value == null
                  ? SettingsModel()
                  : SettingsModel.fromMap(settingsModelProvider.value!);
              return [
                if (settingsModel.useBuiltInViewer ?? !DeviceUtils.isDesktop())
                  PopupMenuAction(
                    title: "Open Outside App",
                    iconData: Iconsax.send,
                    onTap: () {
                      ContentViewGateActions.redirectToViewer(ref, content, popBefore: false, openOutsideApp: true);
                    },
                  )
                else
                  PopupMenuAction(
                    title: "Open Inside App",
                    iconData: Iconsax.received,
                    onTap: () {
                      ContentViewGateActions.redirectToViewer(ref, content, popBefore: false, openOutsideApp: false);
                    },
                  ),
              ];
            }()),

          if (content.courseContentType == CourseContentType.link)
            PopupMenuAction(
              title: "View link",
              iconData: Icons.remove_red_eye_outlined,
              onTap: () {
                UiUtils.showCustomDialog(
                  context,
                  child: PreviewLinkTypeDialog(previewDetailsFuture: previewDetailsFuture, content: content),
                );
              },
            ),

          if (content.courseContentType == CourseContentType.link)
            PopupMenuAction(
              title: "Copy",
              iconData: Iconsax.copy_copy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: content.path.fileDetails.urlPath));
              },
            ),
          PopupMenuAction(
            title: "Share",
            iconData: Iconsax.send_1_copy,
            onTap: () async {
              ShareContentActions.shareContent(context, content.contentId);
            },
          ),
          PopupMenuAction(
            title: "Rename",
            iconData: Iconsax.edit_2_copy,
            onTap: () async {
              ModifyContentCardActions.onRenameContent(context, content);
            },
          ),
          PopupMenuAction(
            title: content.courseContentType == CourseContentType.link ? "Remove" : "Delete",
            iconData: Iconsax.trash_copy,
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
      ),
    );
  }
}

class PreviewLinkTypeDialog extends ConsumerWidget {
  const PreviewLinkTypeDialog({super.key, required this.previewDetailsFuture, required this.content});

  final Future<PreviewLinkDetails?>? previewDetailsFuture;
  final CourseContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return AppCustomizableDialog(
      size: Size(400, 500),
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, right: 16, bottom: 12),
        child: CustomText(content.title, fontSize: 16, fontWeight: FontWeight.bold, color: theme.onBackground),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: theme.onBackground.withAlpha(10), height: 0),

          ConstantSizing.columnSpacingMedium,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              spacing: 12,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.altBackgroundPrimary,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(60))),
                  ),
                  child: SizedBox.square(
                    dimension: 60,
                    child: SizedBox.expand(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Opacity(
                          opacity: 0.6,
                          child: ContentCardPreviewImage(content: content, previewDetailsFuture: previewDetailsFuture),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        CustomText(content.path.urlPath, fontWeight: FontWeight.bold, color: theme.secondary),
                        Flexible(
                          child: Tooltip(
                            message: content.description.trim().isEmpty ? "No description" : content.description,
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: 4.inSeconds,
                            child: CustomText(
                              content.description.trim().isEmpty ? "No description" : content.description,
                              color: theme.onBackground.withValues(alpha: .5),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ConstantSizing.columnSpacingLarge,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 16,
              children: [
                Flexible(
                  child: CustomElevatedButton(
                    onClick: () async {
                      await Clipboard.setData(ClipboardData(text: content.path.fileDetails.urlPath));
                    },
                    pixelHeight: 44,
                    borderRadius: 44,

                    backgroundColor: theme.secondary.withValues(alpha: 0.2),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6.0,
                      children: [
                        Icon(Iconsax.link, color: theme.secondary, size: 20),
                        Flexible(child: CustomText("Copy link", color: theme.secondary)),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: CustomElevatedButton(
                    onClick: () {
                      context.pop();
                      ShareContentActions.shareContent(context, content.contentId);
                    },
                    pixelHeight: 44,
                    borderRadius: 44,

                    backgroundColor: theme.primary.withValues(alpha: 0.2),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6.0,
                      children: [
                        Icon(Icons.share_outlined, color: theme.primary, size: 20),
                        Flexible(child: CustomText("Share", color: theme.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstantSizing.columnSpacingSmall,
        ],
      ),
    );
  }
}

class ContentCardPreviewImage extends StatelessWidget {
  const ContentCardPreviewImage({super.key, required this.content, this.previewDetailsFuture});

  final CourseContent content;
  final Future<PreviewLinkDetails?>? previewDetailsFuture;

  @override
  Widget build(BuildContext context) {
    if (previewDetailsFuture == null) {
      return ImageFiltered(
        imageFilter: ColorFilter.mode(Colors.black.withAlpha(10), BlendMode.color),
        child: BuildImagePathWidget(
          fileDetails: content.courseContentType == CourseContentType.link
              ? FileDetails(urlPath: content.previewPath ?? '')
              : FileDetails(filePath: content.previewPath ?? ''),
          fit: BoxFit.cover,
          fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, false), size: 36),
        ),
      );
    }
    return FutureBuilder(
      future: previewDetailsFuture,
      builder: (context, dataSnapshot) {
        if (dataSnapshot.data != null && dataSnapshot.hasData) {
          final previewUrl = dataSnapshot.data!.previewUrl;
          return ImageFiltered(
            imageFilter: ColorFilter.mode(Colors.black.withAlpha(10), BlendMode.color),
            child: BuildImagePathWidget(
              fileDetails: previewUrl != null ? FileDetails(urlPath: previewUrl) : FileDetails(),
              fit: BoxFit.cover,
              fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, false), size: 36),
            ),
          );
        } else if (dataSnapshot.hasError) {
          return BuildImagePathWidget(
            fileDetails: FileDetails(),
            fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, false), size: 36),
          );
        } else {
          return const CircularLoadingIndicator();
        }
      },
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: theme.altBackgroundSecondary.withAlpha(200),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: CustomText(res, color: theme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
