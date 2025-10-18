import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/manage/presentation/contents/ui/add_contents/add_contents_bottom_sheet.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AddContentFAB extends ConsumerWidget {
  final CourseCollection collection;
  final NotifierProvider<DoubleNotifier, double>? scrollOffsetProvider;
  const AddContentFAB({super.key, required this.collection, this.scrollOffsetProvider});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    // final isScrolled = scrollOffsetProvider == null ? false : ref.watch(scrollOffsetProvider!) < 100.0;

    return FloatingActionButton(
      backgroundColor: theme.primaryColor,
      shape: CircleBorder(),
      onPressed: () {
        CustomDialog.show(
          context,
          transitionType: TransitionType.cupertinoDialog,
          transitionDuration: Durations.medium1,
          reverseTransitionDuration: Durations.short1,
          barrierColor: Colors.black45,
          blurSigma: Offset(2, 2),
          child: AddContentsBottomSheet(collection: collection),
        );
      },
      child: Icon(Iconsax.add_copy, color: theme.onPrimary),
    );
  }
}
