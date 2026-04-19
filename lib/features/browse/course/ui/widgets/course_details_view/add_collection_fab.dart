import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/browse/course/ui/actions/course_details_actions.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AddCollectionFab extends ConsumerWidget {
  final String courseId;
  const AddCollectionFab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return FloatingActionButton(
      backgroundColor: theme.primary,
      shape: CircleBorder(),
      tooltip: "Add Materials",
      onPressed: () {
        CourseDetailsActions.showNewCollectionDialog(context, courseId);
      },
      child: Icon(HugeIconsStroke.add01, color: theme.onPrimary),
    );
  }
}
