import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/browse/course/ui/widgets/modify/create_collection_bottom_sheet.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AddCollectionActionButton extends ConsumerWidget {
  final String courseId;
  final void Function() onClickUp;
  final bool isScrolled;
  const AddCollectionActionButton({
    super.key,
    required this.courseId,
    required this.isScrolled,
    required this.onClickUp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return FloatingActionButton.extended(
      shape: isScrolled ? CircleBorder() : null,
      backgroundColor: theme.onPrimary,
      onPressed: () async {
        if (isScrolled) {
          onClickUp();
          return;
        }
        CustomDialog.show(
          context,
          canPop: true,
          barrierColor: Colors.black.withAlpha(150),
          child: CreateCollectionBottomSheet(courseId: courseId),
        );
      },
      extendedIconLabelSpacing: isScrolled ? 0 : null,
      label: isScrolled
          ? const SizedBox()
          : CustomText("Add a collection", fontWeight: FontWeight.bold, color: theme.primaryColor),
      icon: Icon(isScrolled ? Iconsax.arrow_up : Iconsax.add_circle, size: 32, color: theme.primaryColor),
    );
  }
}
