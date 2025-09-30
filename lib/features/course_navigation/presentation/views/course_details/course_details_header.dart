import 'dart:math';
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_details_controller.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_details/course_details_header/progress_shape_animated_widget.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_details_view.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/modify_course/course_description_dialog.dart';
import 'package:slidesync/shared/components/app_bar_container.dart';
import 'package:slidesync/shared/components/loading_logo.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class CourseDetailsHeader extends ConsumerWidget {
  const CourseDetailsHeader({super.key, required this.courseDbId});

  final int courseDbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarCollapsedHeight = kToolbarHeight;
    final theme = ref;

    // final topGradColor = theme.background.lightenColor(
    //   context.isDarkMode ? .2 : .8,
    // );
    final topGradColor = theme.altBackgroundPrimary;
    final firstStop = ((courseDetailsAppBarHeight + context.topPadding) / context.deviceHeight);
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leadingWidth: 0,
      expandedHeight: courseDetailsAppBarHeight,
      collapsedHeight: appBarCollapsedHeight,
      forceMaterialTransparency: true,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        centerTitle: false,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [double.parse(firstStop.toStringAsFixed(2)), 1],
              colors: [theme.background, topGradColor],
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: CourseDetailsHeaderContent(courseDbId: courseDbId),
      ),
    );
  }
}

class CourseDetailsHeaderContent extends ConsumerWidget {
  const CourseDetailsHeaderContent({super.key, required this.courseDbId});

  final int courseDbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = context.topPadding;
    final shapeSize = kToolbarHeight * 2;
    final theme = ref;
    final courseDetail = ref.watch(
      CourseDetailsController.courseWithCollectionProvider(courseDbId).select(
        (s) => s.whenData(
          (cb) => (title: cb.courseTitle, imageLocationJson: cb.imageLocationJson, description: cb.description),
        ),
      ),
    );

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: courseDetail.when(
          data: (data) {
            final courseTitle = data.title;
            final courseCode = courseTitle.courseCode;
            final courseName = courseTitle.courseName;
            final description = data.description;
            final imageLocationJson = data.imageLocationJson;
            return Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: ConstantSizing.spaceSmall, right: ConstantSizing.spaceSmall),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBackButton(),

                            (courseCode.isNotEmpty)
                                ? CustomTextButton(
                                    backgroundColor: theme.altBackgroundPrimary,
                                    pixelHeight: 28,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                    child: CustomText(
                                      courseCode,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ).animate().scaleXY(
                                    duration: Durations.extralong4,
                                    curve: CustomCurves.defaultIosSpring,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Builder(
                          builder: (context) {
                            final rand = Random().nextDouble();
                            return ProgressShapeAnimatedWidget(
                                  progress: rand,
                                  shapeSize: shapeSize,
                                  fileDetails: imageLocationJson.fileDetails,
                                )
                                .animate()
                                .fadeIn(duration: Durations.medium4, curve: CustomCurves.bouncySpring)
                                .scaleXY(
                                  begin: .4,
                                  end: 1,
                                  duration: Durations.extralong2,
                                  curve: CustomCurves.bouncySpring,
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedPositioned(
                  left: ConstantSizing.spaceMedium,
                  right: shapeSize + ConstantSizing.spaceMedium + 8,
                  top: 50 + 8,
                  duration: Durations.short2,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: courseDetailsAppBarHeight - (48 + 8)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: CourseDetailsHeaderTitle(
                            courseName: courseName,
                            adjustPosition: courseCode.isEmpty,
                            scrollOffsetNotifier: ref.watch(
                              CourseDetailsController.courseDetailsStateProvider.select((s) => s.scrollOffsetNotifier),
                            ),
                          ),
                        ),

                        if (description.isNotEmpty) ConstantSizing.columnSpacingSmall,

                        Flexible(
                          child: CustomTextButton(
                            borderRadius: 4.0,
                            contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            onClick: () {
                              if (description.isNotEmpty) {
                                CustomDialog.show(
                                  context,
                                  canPop: true,
                                  transitionType: TransitionType.cupertinoDialog,
                                  reverseTransitionDuration: Durations.short4,
                                  curve: CustomCurves.defaultIosSpring,
                                  barrierColor: Colors.black.withAlpha(100),
                                  child: CourseDescriptionDialog(description: description).animate().scale(
                                    begin: Offset(0.5, 0.5),
                                    duration: Durations.extralong1,
                                    curve: CustomCurves.bouncySpring,
                                  ),
                                );
                              }
                            },
                            child: CustomText(
                              description.isEmpty ? "No description" : description,
                              color: theme.supportingText.withValues(alpha: .9),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          error: (e, st) => Icon(Icons.error),
          loading: () => LoadingLogo(),
        ),
      ),
    );
  }
}

class CourseDetailsHeaderTitle extends ConsumerStatefulWidget {
  const CourseDetailsHeaderTitle({
    super.key,
    required this.courseName,
    required this.adjustPosition,
    required this.scrollOffsetNotifier,
  });

  final String courseName;
  final bool adjustPosition;
  final ValueNotifier<double> scrollOffsetNotifier;

  @override
  ConsumerState<CourseDetailsHeaderTitle> createState() => _CourseDetailsHeaderTitleState();
}

class _CourseDetailsHeaderTitleState extends ConsumerState<CourseDetailsHeaderTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController moveAnimController;
  @override
  void initState() {
    super.initState();
    moveAnimController = AnimationController(
      duration: Durations.medium1,
      reverseDuration: Durations.medium1,
      vsync: this,
    )..forward(from: 0);
    widget.scrollOffsetNotifier.addListener(listener);
  }

  void listener() {
    final offset = widget.scrollOffsetNotifier.value;
    final double percentScroll = (offset / (courseDetailsAppBarHeight + context.topPadding)).clamp(0, 1);
    percentScroll >= 0.5 ? moveAnimController.reverse() : moveAnimController.forward();
  }

  @override
  void dispose() {
    widget.scrollOffsetNotifier.removeListener(listener);
    moveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final textWidget = Tooltip(
      message: widget.courseName,
      triggerMode: TooltipTriggerMode.tap,
      child: CustomText(
        widget.courseName,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: theme.onBackground,
        overflow: TextOverflow.fade,
      ),
    );
    return widget.adjustPosition
        ? textWidget
              .animate(controller: moveAnimController)
              .move(
                begin: Offset(48, -44),
                end: Offset.zero,
                duration: Durations.extralong4,
                curve: CustomCurves.defaultIosSpring,
              )
        : textWidget
              .animate(controller: moveAnimController)
              .fadeIn()
              .move(
                begin: Offset(48, -44),
                end: Offset.zero,
                duration: Durations.extralong4,
                curve: CustomCurves.defaultIosSpring,
              );
  }
}
