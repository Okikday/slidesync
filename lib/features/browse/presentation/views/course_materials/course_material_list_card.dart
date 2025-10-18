
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/modify_contents_action.dart';
import 'package:slidesync/features/share/presentation/actions/share_content_actions.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/formatter.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class CourseMaterialListCard extends ConsumerStatefulWidget {
  final CourseContent content;
  final void Function()? onTapCard;
  final void Function()? onLongPressed;

  const CourseMaterialListCard({super.key, required this.content, this.onTapCard, this.onLongPressed});

  @override
  ConsumerState<CourseMaterialListCard> createState() => _CourseMaterialListCardState();
}

class _CourseMaterialListCardState extends ConsumerState<CourseMaterialListCard> with SingleTickerProviderStateMixin {
  late final Stream<double> progressStream;
  late final ValueNotifier<bool> isCardExpandedNotifier;
  late AnimationController expandAnimationController;
  late Animation<double> expandAnim;

  @override
  void initState() {
    super.initState();
    isCardExpandedNotifier = ValueNotifier(false);
    isCardExpandedNotifier.addListener(cardExpandListener);
    expandAnimationController = AnimationController(
      vsync: this,
      duration: Durations.extralong2,
      reverseDuration: Durations.medium1,
    );
    expandAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: expandAnimationController,
        curve: CustomCurves.bouncySpring,
        reverseCurve: CustomCurves.defaultIosSpring,
      ),
    );
    progressStream = ContentTrackRepo.watchByContentId(
      widget.content.contentId,
    ).map((c) => c?.progress ?? 0.0).asBroadcastStream();
  }

  void cardExpandListener() {
    isCardExpandedNotifier.value ? expandAnimationController.forward() : expandAnimationController.reverse();
  }

  @override
  void dispose() {
    isCardExpandedNotifier.removeListener(cardExpandListener);
    isCardExpandedNotifier.dispose();
    expandAnimationController.dispose();
    progressStream.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CourseContent content = widget.content;
    List<CourseMaterialListCardActionModel> courseMaterialListCardActionModels = [
      CourseMaterialListCardActionModel(
        label: "Open",
        icon: Iconsax.play_circle,
        onTap: () {
          context.pushNamed(Routes.contentGate.name, extra: content);
        },
      ),
      if (content.courseContentType == CourseContentType.link)
        CourseMaterialListCardActionModel(
          label: "Copy",
          icon: Icons.copy,
          onTap: () {
            Clipboard.setData(ClipboardData(text: content.path.fileDetails.urlPath));
          },
        ),
      CourseMaterialListCardActionModel(
        label: "Delete",
        icon: Icons.delete,
        onTap: () async {
          UiUtils.showCustomDialog(
            context,
            child: ConfirmDeletionDialog(
              content: "Are you sure you want to delete this item?",
              onPop: () {
                if (context.mounted) {
                  UiUtils.hideDialog(context);
                } else {
                  GlobalNav.popGlobal();
                }
              },
              onCancel: () {
                GlobalNav.popGlobal();
              },
              onDelete: () async {
                UiUtils.hideDialog(context);

                if (context.mounted) {
                  UiUtils.showLoadingDialog(context, message: "Removing content");
                }
                final outcome = await ModifyContentsAction().onDeleteContent(content.contentId);

                GlobalNav.popGlobal();

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
      CourseMaterialListCardActionModel(
        label: "Share",
        icon: Iconsax.share_copy,
        onTap: () {
          ShareContentActions.shareContent(context, content.contentId);
        },
      ),
    ];

    final theme = ref;
    return AnimatedContainer(
      duration: Durations.extralong4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(BorderSide(width: 2, color: theme.onBackground.withAlpha(10))),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Tooltip(
          message: content.title,
          triggerMode: TooltipTriggerMode.longPress,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            overlayColor: WidgetStatePropertyAll(theme.altBackgroundPrimary),
            onTap: () {
              if (widget.onTapCard != null) {
                widget.onTapCard!();
                return;
              }
              isCardExpandedNotifier.value = !isCardExpandedNotifier.value;
              // context.pushNamed(Routes.contentGate.name, extra: courseContent);
            },
            onLongPress: widget.onLongPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          // boxShadow: [BoxShadow(color: theme.primaryColor.withAlpha(80), blurRadius: 2, spreadRadius: 2)],
                        ),
                        child: BuildImagePathWidget(
                          fileDetails: FileDetails(
                            filePath: CreateContentPreviewImage.genPreviewImagePath(filePath: content.path.filePath),
                          ),
                          fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, true), size: 20),
                        ),
                      ),
                      ConstantSizing.rowSpacingMedium,
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 100),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: CustomText(
                                  content.courseContentType == CourseContentType.link
                                      ? content.path.urlPath
                                      : content.title + p.extension(content.path.filePath),
                                  fontSize: 13,
                                  color: theme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              // ConstantSizing.columnSpacing(2),
                              CustomText(
                                Formatter.formatEnumName(content.courseContentType.name),
                                fontSize: 11,
                                color: theme.supportingText,
                              ),
                              ConstantSizing.columnSpacing(8),
                              StreamBuilder(
                                stream: progressStream,
                                builder: (context, asyncSnapshot) {
                                  return Row(
                                    spacing: 4.0,
                                    children: [
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(36),
                                          value: asyncSnapshot.data,
                                          backgroundColor: Colors.black.withAlpha(40),
                                          color: theme.primaryColor, //.withAlpha(40)
                                        ),
                                      ),
                                      CustomText(
                                        "${asyncSnapshot.data == null ? 0.0 : (asyncSnapshot.data! * 100).truncate()}%",
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primary,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      ConstantSizing.rowSpacingMedium,
                      CustomElevatedButton(
                        backgroundColor: theme.onSurface.withAlpha(10),
                        contentPadding: EdgeInsets.all(8.0),
                        child: Icon(Iconsax.arrow_circle_right, color: theme.onSurface),
                      ),
                    ],
                  ),

                  SizeTransition(sizeFactor: expandAnim, child: ConstantSizing.columnSpacingMedium),

                  AnimatedCourseMaterialListCardMenu(
                    courseMaterialListCardActionModels: courseMaterialListCardActionModels,
                    expandAnim: expandAnim,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCourseMaterialListCardMenu extends ConsumerStatefulWidget {
  const AnimatedCourseMaterialListCardMenu({
    super.key,
    required this.courseMaterialListCardActionModels,
    required this.expandAnim,
  });

  final List<CourseMaterialListCardActionModel> courseMaterialListCardActionModels;
  final Animation<double> expandAnim;

  @override
  ConsumerState<AnimatedCourseMaterialListCardMenu> createState() => _AnimatedCourseMaterialListCardMenuState();
}

class _AnimatedCourseMaterialListCardMenuState extends ConsumerState<AnimatedCourseMaterialListCardMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return Builder(
      builder: (context) {
        final cam = widget.courseMaterialListCardActionModels;
        final List<Widget> genCardFuncs = List.generate(cam.length, (index) {
          return ScaleTransition(
            scale: widget.expandAnim,
            child: CustomElevatedButton(
              borderRadius: 24,
              backgroundColor: theme.primaryColor.withAlpha(40),
              onClick: cam[index].onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cam[index].icon, color: theme.supportingText),
                  ConstantSizing.rowSpacingSmall,
                  CustomText(cam[index].label, color: theme.onBackground),
                ],
              ),
            ),
          );
        });
        return SizeTransition(
          sizeFactor: widget.expandAnim,
          child: FadeTransition(
            opacity: widget.expandAnim,
            child: Padding(
              padding: EdgeInsets.only(left: context.deviceWidth * 0.2),
              child: Wrap(runAlignment: WrapAlignment.start, spacing: 8.0, runSpacing: 8.0, children: genCardFuncs),
            ),
          ),
        );
      },
    );
  }
}

// class CourseMaterialListCardModel {
//   final String title;
//   final double progress;
//   final Widget? previewImage;
//   final void Function()? onOpen;
//   final List<CourseMaterialListCardActionModel> CourseMaterialListCardActionModels;

//   CourseMaterialListCardModel({
//     required this.title,
//     required this.progress,
//     this.previewImage,
//     this.onOpen,
//     required this.CourseMaterialListCardActionModels,
//   });

//   CourseMaterialListCardModel copyWith({
//     String? title,
//     double? progress,
//     Widget? previewImage,
//     void Function()? onOpen,
//     List<CourseMaterialListCardActionModel>? CourseMaterialListCardActionModels,
//   }) {
//     return CourseMaterialListCardModel(
//       title: title ?? this.title,
//       progress: progress ?? this.progress,
//       previewImage: previewImage ?? this.previewImage,
//       onOpen: onOpen ?? this.onOpen,
//       CourseMaterialListCardActionModels: CourseMaterialListCardActionModels ?? this.CourseMaterialListCardActionModels,
//     );
//   }
// }

class CourseMaterialListCardActionModel {
  final String label;
  final IconData icon;
  final void Function() onTap;

  CourseMaterialListCardActionModel({required this.label, required this.icon, required this.onTap});

  CourseMaterialListCardActionModel copyWith({String? label, IconData? icon, void Function()? onTap}) {
    return CourseMaterialListCardActionModel(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
    );
  }
}
