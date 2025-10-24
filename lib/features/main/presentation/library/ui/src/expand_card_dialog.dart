import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/manage/presentation/courses/actions/modify_course_actions.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ExpandCardDialog extends ConsumerWidget {
  final Offset tapPosition;
  final Course course;
  final void Function() onOpen;

  const ExpandCardDialog({super.key, required this.tapPosition, required this.course, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final Size widgetSize = const Size(180, 150);
    final boundedOffset = repositionOffset(
      tapPosition: tapPosition,
      screenSize: context.screenSize,
      widgetSize: widgetSize,
    );
    final double dimension = (context.deviceWidth > context.deviceHeight
        ? context.deviceWidth * 0.12
        : context.deviceWidth * 0.12);
    final divider = Divider(color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9), height: 0);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: SizedBox.expand(
            child: GestureDetector(
              onTap: () {
                log("Clicked outside");
                UiUtils.hideDialog(context);
              },
            ),
          ),
        ),
        Positioned(
          top: boundedOffset.dy - (kToolbarHeight + 4) - 12,
          left: 20,
          right: 20,
          child: Column(
            spacing: 12,
            children: [
              ScaleClickWrapper(
                onTap: onOpen,
                borderRadius: 16,
                child:
                    Container(
                      constraints: BoxConstraints(maxHeight: kToolbarHeight * 1.5),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.background.lightenColor(theme.isDarkMode ? .12 : .88),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 2,
                          color: theme.background.lightenColor(theme.isDarkMode ? .14 : .86),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurStyle: BlurStyle.outer,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              CircleAvatar(
                                radius: dimension / 2 - 3,
                                backgroundColor: theme.altBackgroundSecondary.withValues(alpha: 0.4),
                                child: ClipOval(
                                  child: CircleAvatar(
                                    radius: dimension / 2 - 4,
                                    backgroundColor: theme.background.lightenColor(theme.isDarkMode ? .14 : .86),
                                    child: SizedBox.square(
                                      dimension: dimension - 8,
                                      child: BuildImagePathWidget(
                                        fileDetails: course.imageLocationJson.fileDetails,
                                        fallbackWidget: Icon(Iconsax.document_1, size: 16, color: theme.onBackground),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: CircularProgressIndicator(
                                    value: 0.01,
                                    strokeCap: StrokeCap.round,
                                    color: theme.primaryColor,
                                    backgroundColor: theme.altBackgroundSecondary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Flexible(
                                  child: CustomText(
                                    course.courseName,
                                    fontSize: 14,
                                    color: theme.onBackground,
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (course.courseCode.isNotEmpty)
                                  CustomText(course.courseCode, fontSize: 10, color: theme.supportingText),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.background.lightenColor(theme.isDarkMode ? .14 : .86),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomText(
                              course.collections.length.toString(),
                              fontSize: 12,
                              color: theme.supportingText,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scaleXY(
                      alignment: Alignment.topCenter,
                      begin: 0.4,
                      end: 1,
                      curve: CustomCurves.defaultIosSpring,
                      duration: Duration(milliseconds: 550),
                    ),
              ),

              Container(
                width: widgetSize.width,
                padding: EdgeInsets.symmetric(vertical: 8),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.background.lightenColor(theme.isDarkMode ? 0.16 : 0.84).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(blurStyle: BlurStyle.outer, blurRadius: 1, offset: Offset(1, 1), color: Colors.black12),
                    BoxShadow(blurStyle: BlurStyle.outer, blurRadius: 1, offset: Offset(-1, -1), color: Colors.white12),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BuildExpandCardButton(title: "Open", iconData: Iconsax.play, onTap: () {}),
                    divider,
                    // BuildExpandCardButton(title: "Pin", iconData: Icons.pin_rounded, onTap: () {}),
                    // divider,
                    BuildExpandCardButton(
                      title: "Edit course",
                      iconData: Iconsax.grid_edit,
                      onTap: () {
                        UiUtils.hideDialog(context);
                        context.pushNamed(Routes.modifyCourse.name, extra: course.courseId);
                      },
                    ),
                    divider,
                    // BuildExpandCardButton(title: "Share", iconData: Icons.share_outlined, onTap: () {}),
                    // divider,
                    BuildExpandCardButton(
                      title: "Remove",
                      iconData: Iconsax.trash,
                      onTap: () {
                        UiUtils.hideDialog(context);
                        if (rootNavigatorKey.currentContext != null && rootNavigatorKey.currentContext!.mounted) {
                          ModifyCourseActions().showDeleteCourseDialog(course.courseId);
                        }
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn().scaleXY(
                alignment: calculateAnimationAlignment(
                  tapPosition: tapPosition,
                  screenSize: context.screenSize,
                  widgetSize: widgetSize,
                ),
                begin: 0.1,
                end: 1,
                curve: CustomCurves.defaultIosSpring,
                duration: Duration(milliseconds: 550),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BuildExpandCardButton extends ConsumerWidget {
  final String title;
  final IconData iconData;
  final void Function() onTap;
  const BuildExpandCardButton({super.key, required this.title, required this.iconData, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BuildPlainActionButton(
      title: title,
      icon: Icon(iconData, color: ref.supportingText),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      onTap: onTap,
    );
  }
}

Offset repositionOffset({required Size screenSize, required Size widgetSize, required Offset tapPosition}) {
  double dx = tapPosition.dx;
  double dy = tapPosition.dy;

  if (dx + widgetSize.width > screenSize.width) {
    dx = dx - widgetSize.width;
    if (dx < 0) dx = 0;
  }

  if (dy + widgetSize.height > screenSize.height) {
    dy = dy - widgetSize.height;
    if (dy < 0) dy = 0;
  }

  return Offset(dx, dy);
}

Alignment calculateAnimationAlignment({
  required Size screenSize,
  required Size widgetSize,
  required Offset tapPosition,
}) {
  final bool fitsRight = tapPosition.dx + widgetSize.width <= screenSize.width;
  // final bool fitsLeft = tapPosition.dx - widgetSize.width >= 0;
  final bool fitsBelow = tapPosition.dy + widgetSize.height <= screenSize.height;
  // final bool fitsAbove = tapPosition.dy - widgetSize.height >= 0;

  final double horizontalAlignment = fitsRight ? -1.0 : 1.0;

  final double verticalAlignment = fitsBelow ? -1.0 : 1.0;

  return Alignment(horizontalAlignment, verticalAlignment);
}
