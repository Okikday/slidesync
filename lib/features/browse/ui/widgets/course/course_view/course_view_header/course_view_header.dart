import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_header/src/progress_shape_animated_widget.dart';
import 'package:slidesync/features/browse/ui/screens/course_view.dart';
import 'package:slidesync/features/browse/ui/actions/course/modify_course_actions.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/course_description_dialog.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/shared/global/providers/course_track_providers.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

class CourseViewHeader extends ConsumerWidget {
  const CourseViewHeader({super.key, required this.courseId, required this.scrollOffsetNotifier});

  final String courseId;
  final ValueNotifier<double> scrollOffsetNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarCollapsedHeight = kToolbarHeight;
    final theme = ref;
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
              colors: [theme.background, theme.secondary.withAlpha(150)],
              stops: const [.8, 1],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: ColoredBox(
          color: theme.background.withAlpha(200),
          child: _HeaderContent(courseId: courseId, scrollOffsetNotifier: scrollOffsetNotifier),
        ),
      ),
    );
  }
}

const _shapeSize = kToolbarHeight * 2;

typedef _CourseSelectData = ({String courseCode, String courseName, String description, String thumbnailPath});

class _HeaderContent extends ConsumerWidget {
  const _HeaderContent({required this.courseId, required this.scrollOffsetNotifier});

  final String courseId;
  final ValueNotifier<double> scrollOffsetNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _CourseSelectData courseSelectData = ref.watch(
      CourseProviders.watchCourseProvider(courseId).select(
        (s) => (
          courseName: s.value?.title ?? '',
          courseCode: s.value?.metadata.courseCode ?? '',
          thumbnailPath: s.value?.localThumbnailPath ?? '',
          description: s.value?.description ?? '',
        ),
      ),
    );

    return TopPadding(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _AboveHeader(courseSelectData: courseSelectData, courseId: courseId),

          _UnderHeader(courseSelectData: courseSelectData, scrollOffsetNotifier: scrollOffsetNotifier),
        ],
      ),
    );
  }
}

class _UnderHeader extends ConsumerWidget {
  const _UnderHeader({required this.courseSelectData, required this.scrollOffsetNotifier});

  final _CourseSelectData courseSelectData;
  final ValueNotifier<double> scrollOffsetNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final description = courseSelectData.description;
    return AnimatedPositioned(
      left: ConstantSizing.spaceMedium,
      right: _shapeSize + ConstantSizing.spaceMedium + 8,
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
                courseName: courseSelectData.courseName,
                adjustPosition: courseSelectData.courseCode.isEmpty,
                scrollOffsetNotifier: scrollOffsetNotifier,
              ),
            ),

            if (description.isNotEmpty) ConstantSizing.columnSpacingSmall,

            Flexible(
              child: CustomTextButton(
                borderRadius: 4.0,
                contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                onClick: () {
                  if (description.isNotEmpty) {
                    GlobalNav.withContext(
                      (context) => CustomDialog.show(
                        context,
                        canPop: true,
                        transitionType: TransitionType.cupertinoDialog,
                        reverseTransitionDuration: Durations.short4,
                        curve: CustomCurves.defaultIosSpring,
                        barrierColor: Colors.black.withAlpha(100),
                        child: CourseDescriptionDialog(description: description),
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
    );
  }
}

class _AboveHeader extends ConsumerWidget {
  const _AboveHeader({required this.courseSelectData, required this.courseId});
  final _CourseSelectData courseSelectData;
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Padding(
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
                if (!DeviceUtils.isDesktop()) AppBackButton(),

                if (courseSelectData.courseCode.isNotEmpty)
                  CustomTextButton(
                    backgroundColor: theme.altBackgroundPrimary,
                    pixelHeight: 28,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: CustomText(
                      courseSelectData.courseCode,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ).animate().scaleXY(duration: Durations.extralong4, curve: CustomCurves.defaultIosSpring),
              ],
            ),
          ),

          if (courseId.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: AbsorberWatch(
                listenable: CourseTrackProviders.courseTrackProgress(courseId),
                builder: (context, progress, ref, _) {
                  return progress.when(
                    data: (data) {
                      return AnimatedShapeProgressWidget(
                            progress: data,
                            shapeSize: _shapeSize,
                            fileDetails: FilePath(local: courseSelectData.thumbnailPath),
                            onClick: () async => await Future.delayed(
                              Durations.short4,
                            ).then((_) => ModifyCourseActions.onClickCourseImage(ref, courseId: courseId)),
                          )
                          .animate()
                          .fadeIn(duration: Durations.medium4, curve: CustomCurves.bouncySpring)
                          .scaleXY(begin: .4, end: 1, duration: Durations.extralong2, curve: CustomCurves.bouncySpring);
                    },
                    error: (_, _) => Icon(Icons.error),
                    loading: () => LoadingLogo(size: 10),
                  );
                },
              ),
            ),
        ],
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
    final textWidget =
        Tooltip(
              message: widget.courseName,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: 4.inSeconds,
              child: CustomText(
                widget.courseName,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.onBackground,
                overflow: TextOverflow.fade,
              ),
            )
            .animate(controller: moveAnimController)
            .move(
              begin: Offset(48, -44),
              end: Offset.zero,
              duration: Durations.extralong4,
              curve: CustomCurves.defaultIosSpring,
            );

    return widget.adjustPosition ? textWidget : textWidget.fadeIn();
  }
}
