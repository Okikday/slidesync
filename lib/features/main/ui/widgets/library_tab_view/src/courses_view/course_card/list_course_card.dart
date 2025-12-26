import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';

import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ListCourseCard extends ConsumerWidget {
  const ListCourseCard(
    this.course, {
    super.key,
    this.progress = 0.0,
    // this.dotColor = Colors.transparent,
    required this.onTapIcon,
  });
  final Course course;
  final double progress;
  // final Color dotColor;
  final void Function() onTapIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Container(
      margin: EdgeInsets.all(2.0),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      height: 100,
      constraints: BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(10))),
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
      child: Badge(
        backgroundColor: Colors.transparent,
        isLabelVisible: (course.createdAt?.difference(DateTime.now()).inMinutes.abs() ?? 10) <= 5,
        alignment: Alignment.topLeft,
        offset: Offset(-20, -16),
        label: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.onBackground.withValues(alpha: 0.4),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              spacing: 1,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.star_1, size: 10, color: theme.adjustBgAndPrimaryWithLerpExtra),
                CustomText("New", fontSize: 8, fontWeight: FontWeight.bold, color: theme.background),
              ],
            ),
          ),
        ),
        child: Row(
          children: [
            ListCourseCardIcon(course: course, onTapIcon: onTapIcon),

            Expanded(
              child: ListCourseCardTitleColumn(
                courseCode: course.courseCode,
                courseName: course.courseName,
                categoriesCount: course.collections.length,
                hasImage: course.metadata.thumbnailsDetails.containsFilePath,
              ),
            ),

            // ListCourseCardProgressIndicator(courseId: course.courseId),
            Icon(Iconsax.arrow_right_1, size: 30, color: theme.supportingText.withAlpha(100)),
          ],
        ),
      ),
    );
  }
}

class ListCourseCardIcon extends ConsumerStatefulWidget {
  const ListCourseCardIcon({super.key, required this.course, required this.onTapIcon});
  final Course course;
  final void Function() onTapIcon;

  @override
  ConsumerState<ListCourseCardIcon> createState() => _ListCourseCardIconState();
}

class _ListCourseCardIconState extends ConsumerState<ListCourseCardIcon> {
  late Stream<CourseTrack?> _courseTrackStream;

  @override
  void initState() {
    super.initState();
    _courseTrackStream = CourseTrackRepo.watchByCourseId(widget.course.courseId);
  }

  @override
  void didUpdateWidget(covariant ListCourseCardIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.courseId != widget.course.courseId) {
      setState(() {
        _courseTrackStream = CourseTrackRepo.watchByCourseId(widget.course.courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return Stack(
      children: [
        InkWell(
          // customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: widget.onTapIcon,
          child: Container(
            // height: 64,
            // width: 64,
            height: 56,
            width: 56,
            padding: EdgeInsets.all(2),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: theme.background.lightenColor(context.isDarkMode ? 0.1 : 0.8).withValues(alpha: 0.8),
              color: theme.altBackgroundPrimary,
              // border: courseCode.isEmpty ? null : Border.all(color: theme.altBackgroundPrimary),
              border: theme.isDarkMode
                  ? Border.fromBorderSide(BorderSide(color: ref.primary.withAlpha(40), width: 1.0))
                  : Border.all(color: theme.altBackgroundPrimary),
              // borderRadius: BorderRadius.circular(12),
            ),
            child: Opacity(
              opacity: 0.8,
              child: ClipOval(
                child: BuildImagePathWidget(
                  height: 64,
                  width: 64,
                  fileDetails: FileDetails(filePath: widget.course.thumbnailPath),
                  fallbackWidget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.course.courseCode.isEmpty
                        ? const SizedBox.shrink()
                        : Center(
                            child: CustomText(
                              widget.course.courseCode.substring(0, widget.course.courseCode.length.clamp(0, 8)),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                              color: theme.onBackground.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: StreamBuilder(
              stream: _courseTrackStream,
              builder: (context, asyncSnapshot) {
                final progress = asyncSnapshot.data?.progress;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: asyncSnapshot.connectionState == ConnectionState.active
                          ? progress?.clamp(0.01, 1.0) ?? 0.01
                          : progress,
                      strokeCap: StrokeCap.round,
                      color: theme.primaryColor,
                      backgroundColor: theme.altBackgroundSecondary.withValues(alpha: 0.4),
                    ),

                    if (progress != null &&
                        widget.course.courseCode.isEmpty &&
                        !widget.course.metadata.thumbnailsDetails.containsFilePath)
                      Positioned.fill(
                        child: Center(
                          child: CustomText(
                            "${((progress.clamp(0, 1.0)) * 100.0).toInt()}%",
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.supportingText.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ListCourseCardTitleColumn extends ConsumerWidget {
  const ListCourseCardTitleColumn({
    super.key,
    required this.courseCode,
    required this.hasImage,
    required this.courseName,
    required this.categoriesCount,
  });

  final String courseCode;
  final bool hasImage;
  final String courseName;
  final int categoriesCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (courseCode.isNotEmpty && hasImage)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CustomTextButton(
              backgroundColor: theme.altBackgroundSecondary,
              pixelHeight: 24,
              borderRadius: 8,
              contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
              child: CustomText(courseCode, fontSize: 12, fontWeight: FontWeight.bold, color: theme.secondary),
            ),
          ),

        if (courseCode.isNotEmpty) ConstantSizing.columnSpacing(6.0),

        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomText(
              courseName,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.onBackground,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        ConstantSizing.columnSpacing(4.0),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomText(
            "${categoriesCount < 1 ? "No" : categoriesCount} ${categoriesCount == 1 ? "category" : "categories"}",
            fontSize: 10,
            // fontWeight: FontWeight.w600,
            color: theme.supportingText.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class ListCourseCardProgressIndicator extends ConsumerStatefulWidget {
  const ListCourseCardProgressIndicator({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<ListCourseCardProgressIndicator> createState() => _ListCourseCardProgressIndicatorState();
}

class _ListCourseCardProgressIndicatorState extends ConsumerState<ListCourseCardProgressIndicator> {
  late Stream<CourseTrack?> _courseTrackStream;

  @override
  void initState() {
    super.initState();
    _courseTrackStream = CourseTrackRepo.watchByCourseId(widget.courseId);
  }

  @override
  void didUpdateWidget(covariant ListCourseCardProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      setState(() {
        _courseTrackStream = CourseTrackRepo.watchByCourseId(widget.courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return StreamBuilder<CourseTrack?>(
      stream: _courseTrackStream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.active) {
          final progress = asyncSnapshot.data?.progress;
          return SizedBox.square(
            dimension: 40,
            child: Stack(
              children: [
                CustomElevatedButton(
                  pixelWidth: 46,
                  pixelHeight: 46,
                  contentPadding: EdgeInsets.zero,
                  shape: CircleBorder(),
                  backgroundColor: theme.altBackgroundPrimary,
                  overlayColor: theme.altBackgroundSecondary,
                  onClick: () {},
                  child: progress == null || (progress <= 0.0)
                      ? Icon(Iconsax.play, color: theme.onBackground)
                      : CustomText(
                          "${((progress.clamp(0, 1.0)) * 100.0).toInt()}%",
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.supportingText.withValues(alpha: 0.5),
                        ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CircularProgressIndicator(
                      value: progress?.clamp(0.01, 1.0) ?? 0.01,
                      strokeCap: StrokeCap.round,
                      color: theme.primaryColor,
                      backgroundColor: theme.altBackgroundSecondary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.square(
          dimension: 30,
          child: CircularProgressIndicator(
            strokeCap: StrokeCap.round,
            color: theme.primaryColor,
            backgroundColor: theme.altBackgroundPrimary.withValues(alpha: 0.4),
          ),
        );
      },
    );
  }
}
