import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/repos/course_track_repo/course_track_repo.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/widgets/build_image_path_widget.dart';

class ListCourseCard extends ConsumerWidget {
  const ListCourseCard(
    this.course, {
    super.key,
    this.progress = 0.0,
    // this.dotColor = Colors.transparent,
    this.isStarred = false,
    required this.onTapIcon,
  });
  final Course course;
  final double progress;
  // final Color dotColor;
  final bool isStarred;
  final void Function() onTapIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: ColoredBox(
        color: theme.onSurface.withAlpha(25),
        child: Container(
          margin: EdgeInsets.all(2.0),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          constraints: BoxConstraints(minHeight: 100, maxHeight: 140, maxWidth: 500),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(26),
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
          child: Row(
            children: [
              ListCourseCardIcon(
                onTapIcon: onTapIcon,
                isStarred: isStarred,
                fileDetails: course.imageLocationJson.fileDetails,
                courseCode: course.courseCode,
              ),

              Expanded(
                child: ListCourseCardTitleColumn(
                  courseCode: course.courseCode,
                  courseName: course.courseName,
                  categoriesCount: course.collections.length,
                  hasImage: course.imageLocationJson.fileDetails.containsFilePath,
                ),
              ),

              ListCourseCardProgressIndicator(courseId: course.courseId),
            ],
          ),
        ),
      ),
    );
  }
}

class ListCourseCardIcon extends ConsumerWidget {
  const ListCourseCardIcon({
    super.key,
    required this.fileDetails,
    this.courseCode = '',
    required this.isStarred,
    required this.onTapIcon,
  });

  final FileDetails fileDetails;
  final String courseCode;
  final bool isStarred;
  final void Function() onTapIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTapIcon,
      child: Badge(
        isLabelVisible: isStarred,
        backgroundColor: Colors.transparent,
        label: CircleAvatar(
          radius: 10.5,
          backgroundColor: Color(0xff0e1d27),
          child: Icon(Iconsax.star_1, size: 16, color: theme.primaryColor),
        ),
        offset: Offset(0, -2),
        child: Container(
          height: 64,
          width: 64,
          padding: EdgeInsets.all(2),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.altBackgroundPrimary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BuildImagePathWidget(
              height: 64,
              width: 64,
              fileDetails: fileDetails,
              fallbackWidget: Padding(
                padding: const EdgeInsets.all(8.0),
                child: courseCode.isEmpty
                    ? Icon(Iconsax.document_1, color: theme.primary)
                    : Center(
                        child: CustomText(
                          courseCode.substring(0, courseCode.length.clamp(0, 8)),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                          color: theme.primary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
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
            padding: const EdgeInsets.only(left: 12.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CustomText(courseName, fontSize: 14, fontWeight: FontWeight.bold, color: theme.onBackground),
          ),
        ),

        ConstantSizing.columnSpacing(4.0),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CustomText(
            "${categoriesCount < 1 ? "No" : categoriesCount} ${categoriesCount == 1 ? "category" : "categories"}",
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.supportingText.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class ListCourseCardProgressIndicator extends ConsumerWidget {
  const ListCourseCardProgressIndicator({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return FutureBuilder(
      future: CourseTrackRepo.getByCourseId(courseId),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          log("Where we at");
          final progress = asyncSnapshot.data?.progress ?? 0.0;
          return SizedBox.square(
            dimension: 40,
            child: Stack(
              children: [
                CustomElevatedButton(
                  pixelWidth: 46,
                  pixelHeight: 46,
                  contentPadding: EdgeInsets.zero,
                  shape: CircleBorder(),
                  backgroundColor: theme.background,
                  overlayColor: theme.altBackgroundSecondary,
                  onClick: () {},
                  child: CustomText(
                    "${((progress?.clamp(0, 100) ?? 0.0) * 100.0).toInt()}%",
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.supportingText.withValues(alpha: 0.5),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: CircularProgressIndicator(
                      value: progress?.clamp(0.01, 1.0),
                      strokeCap: StrokeCap.round,
                      color: theme.primaryColor,
                      backgroundColor: theme.altBackgroundPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.square(
          dimension: 40,
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
