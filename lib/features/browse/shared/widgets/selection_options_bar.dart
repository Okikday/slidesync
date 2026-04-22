import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class SelectionOptionsBar extends ConsumerWidget {
  final List<AppActionDialogModel> actions;
  final List<String> selectedIds;
  final void Function(List<String> selectedIds) onDelete;
  final String deleteTitle;
  final Widget deleteIcon;
  const SelectionOptionsBar({
    super.key,
    this.actions = const [],
    this.selectedIds = const [],
    required this.onDelete,
    this.deleteTitle = 'Delete',
    this.deleteIcon = const Icon(Iconsax.box_remove, color: Colors.redAccent),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = <AppActionDialogModel>[
      ...this.actions,
      AppActionDialogModel(title: deleteTitle, icon: deleteIcon, onTap: () => onDelete(selectedIds)),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 60),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ref.altBackgroundSecondary,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: ref.onBackground.withAlpha(10)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SmoothListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == actions.length - 1 ? 0 : 8),
                  child: ScaleClickWrapper(
                    onTap: action.onTap,
                    child: SizedBox(
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48),
                          color: ref.onSecondary.withAlpha(100),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              action.icon,
                              ConstantSizing.rowSpacingMedium,
                              CustomText(
                                action.title,
                                color: ref.onBackground,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
