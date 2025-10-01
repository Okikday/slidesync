import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_materials_controller.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/materials_search_button.dart';
import 'package:slidesync/shared/common_widgets/app_popup_menu_button.dart';
import 'package:slidesync/shared/components/circular_loading_indicator.dart';
import 'package:slidesync/shared/components/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class CourseMaterialsViewAppBar extends ConsumerWidget {
  final String collectionId;
  const CourseMaterialsViewAppBar({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaterialsSearchButton(),
        AppPopupMenuButton(
          menuPadding: EdgeInsets.only(right: 16),
          actions: [
            ref
                .watch(CourseMaterialsController.cardViewType)
                .when(
                  data: (data) {
                    final isGrid = data == 0;
                    return PopupMenuAction(
                      title: "View",
                      iconData: isGrid ? Iconsax.grid_1 : Iconsax.arrange_square,
                      onTap: () {
                        ref.read(CourseMaterialsController.cardViewType.notifier).toggle();
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
                                final sortOptionAsync = ref.watch(CourseMaterialsController.contentSortOptionProvider);
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
                                                .read(CourseMaterialsController.contentSortOptionProvider.notifier)
                                                .set(newValue);
                                            (await ref.read(
                                              CourseMaterialsController.contentPaginationProvider(collectionId).future,
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
          ],
        ),
      ],
    );
  }
}
