import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/browse/collection/ui/widgets/materials_search_button.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/progress_indicator/app_circular_loading_indicator.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CollectionMaterialsAppBar extends ConsumerWidget {
  final String collectionId;
  final bool isFullScreen;
  const CollectionMaterialsAppBar({super.key, required this.collectionId, required this.isFullScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (DeviceUtils.isDesktop() && !isFullScreen) ...[
          CustomElevatedButton(
            onClick: () async {
              context.pop();
              final collection = await CourseCollectionRepo.getById(collectionId);
              Result.tryRun(() => context.pushNamed("${Routes.courseMaterials.name}full", extra: collection));
            },
            pixelWidth: 30,
            pixelHeight: 30,
            overlayColor: ref.secondary.withAlpha(40),
            contentPadding: EdgeInsets.zero,
            shape: CircleBorder(side: BorderSide(color: theme.altBackgroundSecondary.withValues(alpha: 0.4))),
            backgroundColor: Colors.transparent,
            child: Icon(HugeIconsSolid.crop, color: theme.supportingText, size: 14),
          ),
          ConstantSizing.rowSpacingSmall,
        ],
        // MaterialsSearchButton(collectionId: collectionId, backgroundColor: theme.secondary.withAlpha(50)),
        AppPopupMenuButton(
          menuPadding: EdgeInsets.only(right: 16),
          buttonStyle: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.all(6)),
            shape: WidgetStateProperty.all(
              CircleBorder(side: BorderSide(color: theme.altBackgroundSecondary.withValues(alpha: 0.4))),
            ),
            overlayColor: WidgetStateProperty.all(theme.secondary.withAlpha(40)),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          icon: HugeIconsSolid.more,
          actions: [
            ref
                .watch(CollectionMaterialsProvider.cardViewType)
                .when(
                  data: (data) {
                    final isGrid = data == 0
                        ? true
                        : data == 1
                        ? false
                        : null;
                    return PopupMenuAction(
                      title: "View",
                      iconData: isGrid != null
                          ? (isGrid ? HugeIconsStroke.grid : HugeIconsStroke.listView)
                          : Icons.list,
                      onTap: () {
                        ref.read(CollectionMaterialsProvider.cardViewType.notifier).toggle();
                      },
                    );
                  },
                  error: (e, st) => PopupMenuAction(title: "View", iconData: Icons.error_rounded, onTap: () {}),
                  loading: () => PopupMenuAction(title: "View", iconData: Icons.circle_outlined, onTap: () {}),
                ),
            PopupMenuAction(
              title: "Sort",
              iconData: HugeIconsStroke.arrange,
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
                                final sortOptionAsync = ref.watch(
                                  CollectionMaterialsProvider.contentSortOptionProvider,
                                );
                                return sortOptionAsync.when(
                                  data: (data) {
                                    return SmoothListView.builder(
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
                                                .read(CollectionMaterialsProvider.contentSortOptionProvider.notifier)
                                                .set(newValue);
                                            (await ref.read(
                                              CollectionMaterialsProvider.contentPaginationProvider(
                                                collectionId,
                                              ).future,
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
                                  loading: () => const AppCircularLoadingIndicator(),
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

            if (!DeviceUtils.isDesktop())
              PopupMenuAction(
                title: "Go back to Course Details",
                iconData: HugeIconsStroke.arrowLeft01,
                onTap: () async {
                  final collection = await CourseCollectionRepo.getById(collectionId);
                  if (collection == null) return;
                  GlobalNav.withContext((c) {
                    (context.mounted ? context : c).pushReplacementNamed(
                      Routes.courseDetails.name,
                      extra: collection.parentId,
                    );
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}
