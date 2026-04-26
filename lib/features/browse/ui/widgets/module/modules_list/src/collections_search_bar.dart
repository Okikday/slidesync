import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/browse/ui/actions/course/course_view_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/decorations/back_soft_edge_blur.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class CollectionsViewSearchBar extends ConsumerStatefulWidget {
  final String courseId;
  final void Function() onTap;
  final void Function(String text) onChanged;
  // final void Function(FocusNode focusNode)? onTapOutside;
  final bool showTrailing;
  const CollectionsViewSearchBar({
    super.key,
    required this.courseId,
    required this.onTap,
    required this.onChanged,
    // this.onTapOutside,
    required this.showTrailing,
  });

  @override
  ConsumerState<CollectionsViewSearchBar> createState() => _CollectionsViewSearchBarState();
}

class _CollectionsViewSearchBarState extends ConsumerState<CollectionsViewSearchBar> {
  // final FocusNode focusNode = FocusNode();

  // @override
  // void dispose() {
  //   focusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final isDesktop = DeviceUtils.isDesktop();
    // final searchNotifier = ref.read(CourseDetailsProvider.state.select((s) => s.searchCollectionTextNotifier));
    return BackSoftEdgeBlur(
      color: isDesktop ? ref.background : ref.background.withAlpha(200),
      applyHeightToSize: true,
      height: 80,
      edgeType: EdgeType.topEdge,
      child: Padding(
        padding: isDesktop
            ? const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 4.0)
            : const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 12.0),
        child: Row(
          spacing: 12.0,
          children: [
            Expanded(
              child: ClipRSuperellipse(
                borderRadius: BorderRadius.circular(10.0),
                child: CustomTextfield(
                  hint: "Search collections",
                  // focusNode: focusNode,
                  autoDispose: false,
                  hintStyle: TextStyle(color: theme.supportingText),
                  selectionHandleColor: theme.primaryColor,
                  inputTextStyle: TextStyle(fontSize: 15, color: theme.onBackground),
                  backgroundColor: theme.surface,
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.zero),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 10.0, top: 12.0, bottom: 12.0),
                    child: Icon(Iconsax.search_normal_copy, size: 20, color: theme.supportingText),
                  ),
                  onchanged: widget.onChanged,
                  // onTapOutside: widget.onTapOutside == null
                  //     ? null
                  //     : () {
                  //         if (widget.onTapOutside != null) widget.onTapOutside!(focusNode);
                  //       },
                  ontap: widget.onTap,
                ),
              ),
            ),

            if (widget.showTrailing)
              CustomElevatedButton(
                pixelHeight: 48,
                pixelWidth: 48,
                backgroundColor: ref.secondary.withAlpha(50),
                shape: CircleBorder(side: BorderSide(color: ref.onBackground.withAlpha(10))),
                onClick: () => CourseViewActions.showMoreOptionsDialog(context, courseId: widget.courseId),
                child: Icon(Iconsax.more_copy, size: 24, color: ref.secondary),
              ),
          ],
        ),
      ),
    );
  }
}
