import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/browse/presentation/logic/course_details_provider.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_details_header/progress_shape_animated_widget.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/modify_course/course_description_dialog.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/shared/global/providers/course_track_providers.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CourseDetailsHeader extends ConsumerWidget {
  const CourseDetailsHeader({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarCollapsedHeight = kToolbarHeight;
    final theme = ref;

    // final topGradColor = theme.background.lightenColor(
    //   context.isDarkMode ? .2 : .8,
    // );
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
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.background, theme.adjustBgAndPrimaryWithLerp],
              stops: [.8, 1],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: CourseDetailsHeaderContent(courseId: courseId),
      ),
    );
  }
}

class CourseDetailsHeaderContent extends ConsumerWidget {
  const CourseDetailsHeaderContent({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = context.topPadding;
    final shapeSize = kToolbarHeight * 2;
    final courseDetail = ref.watch(
      CourseProviders.courseProvider(courseId).select(
        (s) => s.whenData(
          (cb) => (title: cb.courseTitle, imageLocationJson: cb.imageLocationJson, description: cb.description),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: courseDetail.when(
        data: (data) {
          final courseTitle = data.title;
          final courseCode = courseTitle.courseCode;
          final courseName = courseTitle.courseName;
          final description = data.description;
          final imageLocationJson = data.imageLocationJson;
          return CourseDetailsHeaderContentChild(
            courseId: courseId,
            courseCode: courseCode,
            shapeSize: shapeSize,
            imageLocationJson: imageLocationJson,
            courseName: courseName,
            description: description,
          );
        },
        error: (e, st) => Icon(Icons.error),
        loading: () => CourseDetailsHeaderContentChild(
          courseId: '',
          courseCode: "",
          shapeSize: shapeSize,
          imageLocationJson: "",
          courseName: "Loading...",
          description: "description",
        ),
      ),
    );
  }
}

class CourseDetailsHeaderContentChild extends ConsumerWidget {
  const CourseDetailsHeaderContentChild({
    super.key,
    required this.courseId,
    required this.courseCode,
    required this.shapeSize,
    required this.imageLocationJson,
    required this.courseName,
    required this.description,
  });
  final String courseId;
  final String courseCode;
  final double shapeSize;
  final String imageLocationJson;
  final String courseName;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: ConstantSizing.spaceSmall, right: ConstantSizing.spaceSmall),
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
                          ).animate().scaleXY(duration: Durations.extralong4, curve: CustomCurves.defaultIosSpring)
                        : const SizedBox(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Consumer(
                  builder: (context, ref, child) {
                    if (courseId.isEmpty) return const SizedBox();
                    final progressN = ref.watch(CourseTrackProviders.courseTrackProgress(courseId));

                    return progressN.when(
                      data: (data) {
                        return ProgressShapeAnimatedWidget(
                              progress: data,
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
                      error: (_, _) => Icon(Icons.error),
                      loading: () => LoadingLogo(size: 10),
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
                    scrollOffsetNotifier: ref.watch(CourseDetailsProvider.state.select((s) => s.scrollOffsetNotifier)),
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
