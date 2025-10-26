import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class EditCourseTile extends ConsumerWidget {
  const EditCourseTile({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.categoriesCount,
    required this.syncImagePath,
    required this.selectionState,
    required this.onTap,
    required this.onSelected,
  });
  final String courseName;
  final String courseCode;
  final int categoriesCount;
  final String syncImagePath;

  final ({bool selected, bool isSelecting}) selectionState;

  final void Function() onTap;
  final void Function() onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final side = BorderSide(color: theme.background.lightenColor(theme.isDarkMode ? 0.2 : 0.7).withAlpha(20));
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      onLongPress: onSelected,
      
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        constraints: BoxConstraints(minHeight: 90, maxHeight: 140),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(right: side, bottom: side),
        ),
        child: Row(
          children: [
            ClipOval(
              // borderRadius: BorderRadius.circular(13),
              child: ColoredBox(
                color: theme.background.lightenColor(theme.isDarkMode ? 0.2 : 0.7).withAlpha(80),
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: ClipOval(
                    child: SizedBox.square(
                      dimension: 44,
                      child: BuildImagePathWidget(fileDetails: syncImagePath.fileDetails),
                    ),
                  ),
                ),
              ),
            ).animate().fade(begin: selectionState.selected ? 1.0 : 0.5, end: selectionState.selected ? 0.5 : 1.0),
            ConstantSizing.rowSpacingMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (courseCode.isNotEmpty)
                    CustomTextButton(
                      backgroundColor: theme.secondary.withValues(alpha: 0.2),
                      pixelHeight: 24,
                      borderRadius: 12,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomText(courseCode, fontSize: 12, fontWeight: FontWeight.bold, color: ref.secondary),
                    ),

                  if (courseCode.isNotEmpty) ConstantSizing.columnSpacing(2),

                  Flexible(
                    child: CustomText(courseName, fontSize: 14, fontWeight: FontWeight.bold, color: theme.onBackground),
                  ),

                  ConstantSizing.columnSpacing(2.0),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CustomText("This is a Content."),
                      CustomText("$categoriesCount items", fontSize: 12, color: theme.supportingText),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
