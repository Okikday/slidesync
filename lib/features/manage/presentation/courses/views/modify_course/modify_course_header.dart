import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/manage/presentation/courses/actions/modify_course_actions.dart';
import 'package:slidesync/features/manage/presentation/courses/views/modify_course/edit_course_bottom_sheet.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ModifyCourseHeader extends ConsumerWidget {
  final String courseId;

  const ModifyCourseHeader({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final courseAsyncValue = ref.watch(CourseProviders.courseProvider(courseId));
    return SliverToBoxAdapter(
      child: courseAsyncValue.when(
        data: (data) {
          final courseCode = data.courseCode;
          final title = data.courseName;
          final description = data.description;
          final imageDetails = data.imageLocationJson;

          return Column(
            spacing: 24.0,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _ModifyCourseHeaderTitle(
                      courseCode: courseCode,
                      title: title,
                      onClickAddDescription: () {
                        ModifyCourseActions().onClickAddDescription(
                          context,
                          courseId: courseId,
                          currDescription: description,
                        );
                      },
                      description: description,
                    ),
                  ),
                  ConstantSizing.rowSpacingLarge,
                  _PhotoAvatarWidget(
                    theme: theme,
                    onClickImage: () async {
                      final course = (await ref.read(CourseProviders.courseProvider(courseId).future));
                      if (course == defaultCourse) return;
                      if (!course.imageLocationJson.fileDetails.containsFilePath) {
                        // ignore: use_build_context_synchronously
                        ModifyCourseActions().pickImageActionRoute(
                          // ignore: use_build_context_synchronously
                          rootNavigatorKey.currentState!.context,
                          courseDbId: course.id,
                        );
                        return;
                      }

                      ModifyCourseActions().onClickCourseImage(ref, course: course);
                    },
                    onLongPressImage: () async {
                      final course = (await ref.read(CourseProviders.courseProvider(courseId).future));
                      if (course == defaultCourse) return;
                      if (!course.imageLocationJson.fileDetails.containsFilePath) {
                        // ignore: use_build_context_synchronously
                        ModifyCourseActions().pickImageActionRoute(
                          // ignore: use_build_context_synchronously
                          rootNavigatorKey.currentState!.context,
                          courseDbId: course.id,
                        );
                        return;
                      }

                      // ignore: use_build_context_synchronously
                      ModifyCourseActions().previewImageActionRoute(
                        // ignore: use_build_context_synchronously
                        rootNavigatorKey.currentState!.context,
                        courseImagePath: course.imageLocationJson,
                      );
                    },
                    courseFileDetails: imageDetails,
                  ),
                  ConstantSizing.rowSpacingMedium,
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  spacing: 12.0,
                  children: [
                    Expanded(
                      child: _EditCourseButton(
                        onClickEditCourse: () async {
                          await showModalBottomSheet(
                            context: context,
                            enableDrag: false,
                            showDragHandle: false,
                            isScrollControlled: true,
                            builder: (context) => EditCourseBottomSheet(courseId: courseId),
                          );
                        },
                        theme: theme,
                      ),
                    ),
                    CustomElevatedButton(
                      pixelHeight: 48,
                      onClick: () {
                        if (rootNavigatorKey.currentContext != null && rootNavigatorKey.currentContext!.mounted) {
                          ModifyCourseActions().showDeleteCourseDialog(rootNavigatorKey.currentContext!, courseId);
                        }
                      },
                      contentPadding: EdgeInsets.all(16),
                      backgroundColor: Colors.red.withAlpha(50),
                      shape: CircleBorder(),
                      child: Icon(Iconsax.trash_copy, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (e, st) => Icon(Icons.error),
        loading: () => CircularLoadingIndicator(),
      ),
    );
  }
}

class _ModifyCourseHeaderTitle extends ConsumerWidget {
  const _ModifyCourseHeaderTitle({
    required this.courseCode,
    required this.title,
    required this.onClickAddDescription,
    required this.description,
  });

  final String courseCode;
  final String title;
  final void Function() onClickAddDescription;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        ConstantSizing.columnSpacingSmall,
        if (courseCode.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: CustomTextButton(
              backgroundColor: theme.primaryColor.withAlpha(60),
              pixelHeight: 28,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              child: CustomText(courseCode, fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
          ),

        Flexible(
          child: Tooltip(
            message: title,
            triggerMode: TooltipTriggerMode.tap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(title, fontSize: 20, fontWeight: FontWeight.bold, color: theme.onBackground),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 80),
              child: SingleChildScrollView(
                child: CustomTextButton(
                  borderRadius: 4.0,
                  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  onClick: onClickAddDescription,
                  child: CustomText(
                    description.isEmpty ? "Add description" : description,
                    color: theme.supportingText.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoAvatarWidget extends ConsumerWidget {
  const _PhotoAvatarWidget({
    required this.theme,
    required this.onClickImage,
    required this.onLongPressImage,
    required this.courseFileDetails,
  });

  final WidgetRef theme;
  final void Function() onClickImage;
  final void Function() onLongPressImage;
  final String courseFileDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 80,
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: theme.altBackgroundPrimary, spreadRadius: 2, blurRadius: 3)],
      ),
      child: GestureDetector(
        onTap: onClickImage,
        onLongPress: onLongPressImage,
        child: ColoredBox(
          color: theme.altBackgroundPrimary,
          child: SizedBox.square(
            dimension: 80,
            child: BuildImagePathWidget(
              fileDetails: courseFileDetails.fileDetails,
              fallbackWidget: Icon(
                Iconsax.document,
                color: context.isDarkMode ? theme.primaryColor : theme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditCourseButton extends StatelessWidget {
  const _EditCourseButton({required this.onClickEditCourse, required this.theme});

  final void Function() onClickEditCourse;
  final WidgetRef theme;

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onClick: onClickEditCourse,
      buttonStyle: ElevatedButton.styleFrom(
        fixedSize: Size(double.infinity, 48),
        backgroundColor: theme.primaryColor.withAlpha(40),
        elevation: 0,
        shape: RoundedSuperellipseBorder(
          side: BorderSide(color: theme.primaryColor.withAlpha(41), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText("Edit course", color: theme.primaryColor),
          Icon(Iconsax.edit_2, color: theme.supportingText),
        ],
      ),
    );
  }
}
