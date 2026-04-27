import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/module_contents_search_button.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/add_contents/add_contents_bottom_sheet.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AddContentFAB extends ConsumerWidget {
  final Module collection;
  final bool isScrolled;
  final ScrollController? scrollController;
  const AddContentFAB({super.key, required this.collection, required this.isScrolled, this.scrollController});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    // final isScrolled = scrollOffsetProvider == null ? false : ref.watch(scrollOffsetProvider!) < 100.0;
    if (isScrolled) {
      return BuildButton(
        onTap: () {
          scrollController?.animateTo(0, duration: Durations.short1, curve: Curves.easeInOut);
        },
        shape: const CircleBorder(),
        size: Size.square(32),
        backgroundColor: theme.secondary,
        iconColor: theme.onSecondary,
        iconData: HugeIconsSolid.arrowUp01,
      );
    }
    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ModuleContentsSearchButton(collectionId: collection.uid, backgroundColor: theme.secondary.withAlpha(50)),
        FloatingActionButton(
          backgroundColor: theme.secondary,
          shape: CircleBorder(),
          tooltip: "Add Materials",
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
          child: Icon(Iconsax.add_copy, color: theme.onSecondary),
        ),
      ],
    );
  }
}
