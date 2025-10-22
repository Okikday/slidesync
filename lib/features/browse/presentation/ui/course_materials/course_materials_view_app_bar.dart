import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/presentation/logic/course_materials_provider.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials/materials_search_button.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CourseMaterialsViewAppBar extends ConsumerWidget {
  final String collectionId;
  const CourseMaterialsViewAppBar({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaterialsSearchButton(collectionId: collectionId),
        AppPopupMenuButton(
          menuPadding: EdgeInsets.only(right: 16),
          actions: [
            ref
                .watch(CourseMaterialsProvider.cardViewType)
                .when(
                  data: (data) {
                    final isGrid = data == 0
                        ? true
                        : data == 1
                        ? false
                        : null;
                    return PopupMenuAction(
                      title: "View",
                      iconData: isGrid != null ? (isGrid ? Iconsax.grid_1 : Iconsax.arrange_square) : Icons.list,
                      onTap: () {
                        ref.read(CourseMaterialsProvider.cardViewType.notifier).toggle();
                      },
                    );
                  },
                  error: (e, st) => PopupMenuAction(title: "View", iconData: Icons.error_rounded, onTap: () {}),
                  loading: () => PopupMenuAction(title: "View", iconData: Icons.circle_outlined, onTap: () {}),
                ),
            PopupMenuAction(
              title: "Sort",
              iconData: Iconsax.arrange_circle,
              onTap: () {
                UiUtils.showCustomDialog(
                  context,
                  child: AppCustomizableDialog(
                    backgroundColor: theme.background.withValues(alpha: 0.9),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 250),
                      child: Column(
                        children: [
                          CustomText("Sort by", color: theme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                          ConstantSizing.columnSpacingSmall,
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final sortOptionAsync = ref.watch(CourseMaterialsProvider.contentSortOptionProvider);
                                return sortOptionAsync.when(
                                  data: (data) {
                                    return ListView.builder(
                                      itemCount: CourseSortOption.values.length,
                                      itemBuilder: (context, index) {
                                        return CustomElevatedButton(
                                          pixelHeight: 44,
                                          backgroundColor: Colors.transparent,
                                          borderRadius: 0,
                                          onClick: () async {
                                            final newValue =
                                                CourseSortOption.values[index.clamp(0, CourseSortOption.values.length)];
                                            ref
                                                .read(CourseMaterialsProvider.contentSortOptionProvider.notifier)
                                                .set(newValue);
                                            (await ref.read(
                                              CourseMaterialsProvider.contentPaginationProvider(collectionId).future,
                                            )).updateSortOption(newValue, true);
                                            if (context.mounted) UiUtils.hideDialog(context);
                                          },
                                          child: Row(
                                            children: [
                                              RadioGroup<int>(
                                                groupValue: data.index,
                                                onChanged: (p) async {},
                                                child: Radio(value: index),
                                              ),
                                              Expanded(child: CustomText(CourseSortOption.values[index].label)),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  error: (e, st) => Icon(Icons.error_rounded),
                                  loading: () => const CircularLoadingIndicator(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            PopupMenuAction(title: "Group", iconData: Iconsax.arrange_circle, onTap: () {}),
          ],
        ),
      ],
    );
  }
}
