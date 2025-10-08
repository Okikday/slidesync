import 'dart:developer';
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class GridCourseCard extends ConsumerWidget {
  const GridCourseCard(
    this.course, {
    super.key,
    this.dimension,
    this.progress = 0.0,
    this.dotColor = Colors.transparent,
    this.isStarred = false,
    required this.onTapIcon,
  });

  final Course course;
  final double? dimension;
  final double progress;
  final Color dotColor;
  final bool isStarred;
  final void Function() onTapIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final courseCode = course.courseCode;
    final categoriesCount = course.collections.length;
    final shadowSurfaceColor = theme.surface.lightenColor(0.5).withValues(alpha: 0.1);
    log("Rebuild Grid course card");
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(1.5),

      constraints: BoxConstraints(maxWidth: 320, maxHeight: 200),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: shadowSurfaceColor),
      ),
      child: Column(
        // fit: StackFit.expand,
        // clipBehavior: Clip.antiAlias,
        children: [
          Expanded(
            child: GridCourseCardStackedCard(course: course, courseCode: courseCode),
          ),

          GridCourseCardBottomStack(courseName: course.courseName, categoriesCount: categoriesCount),
        ],
      ),
    );
  }
}

class GridCourseCardStackedCard extends ConsumerWidget {
  const GridCourseCardStackedCard({super.key, required this.course, required this.courseCode});

  final Course course;
  final String courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            for (int i = 0; i < 3; i++)
              Transform.translate(
                offset: Offset(0, -(120.0 * i)),
                child: Container(
                  height: 120,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    // color: Colors.yellow,
                    color: theme.surface
                        .withValues(alpha: 0.4 + (i * 0.3))
                        .lightenColor(context.isDarkMode ? 0.3 : 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: i == 2 ? Border.all(color: theme.surface.lightenColor(0.5).withAlpha(40)) : null,
                  ),
                  padding: EdgeInsets.all(12).copyWith(bottom: 40),
                  margin: EdgeInsets.only(top: 4.5 * i, left: 4.0 * (2 - i), right: 4.0 * (2 - i)),

                  child: i == 2
                      ? Row(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    // color: theme.surface.withAlpha(100),
                                    color: context.isDarkMode
                                        ? theme.surface.withAlpha(100)
                                        : theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.5),
                                    border: Border.all(color: theme.primary.withAlpha(20)),
                                  ),
                                  // child: SizedBox(width: 40, height: 40),
                                  child: SizedBox.square(
                                    dimension: 40,
                                    child: BuildImagePathWidget(
                                      width: 40,
                                      height: 40,
                                      fileDetails: course.imageLocationJson.fileDetails,
                                      fallbackWidget: Icon(
                                        Iconsax.star,
                                        size: 16,
                                        color: theme.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child: LinearProgressIndicator(
                                    minHeight: 16,
                                    value: 0.2,
                                    backgroundColor: context.isDarkMode
                                        ? theme.surface.withAlpha(100)
                                        : theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GridCourseCardBottomStack extends ConsumerWidget {
  const GridCourseCardBottomStack({super.key, required this.courseName, required this.categoriesCount});

  final String courseName;
  final int categoriesCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.9),
          // border: Border(top: BorderSide(color: theme.surface.lightenColor(0.5).withAlpha(200))),
        ),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Column(
                children: [
                  Flexible(
                    child: CustomText(
                      courseName,
                      color: theme.onBackground,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      fontSize: 13,
                    ),
                  ),
                  CustomText(
                    "${categoriesCount < 1 ? "No" : categoriesCount} ${categoriesCount == 1 ? "category" : "categories"}",
                    fontSize: 10,
                    color: theme.supportingText.withAlpha(200),
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




    // child: Padding(
      //   padding: const EdgeInsets.only(top: 8, bottom: 0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.fromLTRB(8, 0, 6, 6),
      //         child: Row(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             InkWell(
      //               customBorder: const CircleBorder(),
      //               onTap: onTapIcon,
      //               child: CircleAvatar(
      //                 radius: dimension / 2 - 3,
      //                 backgroundColor: ref.cardColor.withAlpha(80),
      //                 child: ClipOval(
      //                   child: CircleAvatar(
      //                     radius: dimension / 2 - 4,
      //                     // backgroundColor: theme.background.lightenColor(theme.isDarkMode ? .12 : .88),
      //                     backgroundColor: theme.altBackgroundPrimary,
      //                     child: SizedBox.square(
      //                       dimension: dimension - 8,
      //                       child: BuildImagePathWidget(
      //                         fileDetails: course.imageLocationJson.fileDetails,
      //                         fallbackWidget: Icon(
      //                           Iconsax.document_1,
      //                           size: 16,
      //                           color: isDarkMode ? Colors.white : Colors.black,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             if (courseCode.isNotEmpty)
      //               Flexible(
      //                 child: Align(
      //                   alignment: Alignment.topRight,
      //                   child: Padding(
      //                     padding: const EdgeInsets.only(left: 8.0),
      //                     child: CustomTextButton(
      //                       backgroundColor: theme.altBackgroundPrimary,
      //                       pixelHeight: 24,
      //                       borderRadius: 14,
      //                       contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
      //                       child: CustomText(
      //                         courseCode,
      //                         fontSize: 10,
      //                         fontWeight: FontWeight.bold,
      //                         color: theme.primaryColor.withAlpha(200),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //           ],
      //         ),
      //       ),
      //       Expanded(
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //           child: Align(
      //             alignment: Alignment.centerLeft,
      //             child: CustomText(
      //               course.courseName,
      //               overflow: TextOverflow.fade,
      //               fontWeight: FontWeight.bold,
      //               fontSize: 13.5,
      //               color: theme.onBackground,
      //             ),
      //           ),
      //         ),
      //       ),

      //       ConstantSizing.columnSpacing(4.0),

      //       // if (categoriesCount > 0)
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
      //         child: CustomText(
      //           "${categoriesCount < 1 ? "No" : categoriesCount} ${categoriesCount == 1 ? "collection" : "collections"}",
      //           fontSize: 11,
      //           color: theme.supportingText,
      //         ),
      //       ),

      //       ConstantSizing.columnSpacing(8),

      //       LinearProgressIndicator(
      //         minHeight: 4,

      //         value: (progress).clamp(0.1, 1.0),
      //         backgroundColor: theme.altBackgroundPrimary.withValues(alpha: 0.2),
      //         // color: theme.background.lightenColor(theme.isDarkMode ? .12 : .88), //.withAlpha(40)
      //         color: theme.altBackgroundPrimary,
      //       ),
      //     ],
      //   ),
      // ),