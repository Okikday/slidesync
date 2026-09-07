import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class GridCourseCardBottomStack extends ConsumerWidget {
  const GridCourseCardBottomStack({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).custom;
    final categoriesCount = course.modules.length;
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: .only(
        bottomLeft: .circular(22),
        bottomRight: .circular(22),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.9),
          // border: Border(top: BorderSide(color: theme.surface.lightenColor(0.5).withAlpha(200))),
        ),
        child: SizedBox(
          height: 60,
          width: .infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Flexible(
                  child: CustomText(
                    course.title,
                    color: theme.onBackground,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    fontSize: 13,
                    height: 1.1,
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
    );
  }
}
