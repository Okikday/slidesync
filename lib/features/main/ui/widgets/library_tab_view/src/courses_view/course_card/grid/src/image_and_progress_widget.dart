import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/grid/src/grid_course_card_progress_indicator.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ImageAndProgressWidget extends StatelessWidget {
  const ImageAndProgressWidget({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).custom;
    return Row(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // color: theme.surface.withAlpha(100),
                color: context.isDarkMode
                    ? theme.surface.withAlpha(100)
                    : theme.adjustBgAndPrimaryWithLerpExtra.withValues(
                        alpha: 0.5,
                      ),
                border: Border.all(color: theme.primary.withAlpha(20)),
              ),
              // child: SizedBox(width: 40, height: 40),
              child: SizedBox.square(
                dimension: 40,
                child: BuildImagePathWidget(
                  width: 40,
                  height: 40,
                  fileDetails: course.metadata.thumbnail ?? FilePath.empty(),
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
            child: Column(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (course.metadata.courseCode?.isNotEmpty == true)
                  CustomTextButton(
                    backgroundColor: theme.altBackgroundSecondary,
                    pixelHeight: 16,
                    borderRadius: 8,
                    contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: CustomText(
                      course.metadata.courseCode ?? '',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: theme.secondary,
                    ),
                  ),
                GridCourseCardProgressIndicator(
                  courseId: course.uid,
                  color: course.metadata.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
