import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/browse/ui/actions/course/course_view_actions.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CourseViewFAB extends ConsumerWidget {
  final String courseId;
  const CourseViewFAB({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return FloatingActionButton(
      backgroundColor: theme.primary,
      shape: CircleBorder(),
      tooltip: "Add Collection",
      onPressed: () => CourseViewActions.showNewModuleDialog(context, courseId),
      child: Icon(HugeIconsStroke.add01, color: theme.onPrimary),
    );
  }
}
