import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/providers/module_contents_provider.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ModuleContentsAppBar extends ConsumerWidget {
  final Module collection;
  final bool isFullScreen;
  const ModuleContentsAppBar({super.key, required this.collection, required this.isFullScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final state = ModuleContentsProvider.state(collection.id);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (DeviceUtils.isDesktop() && !isFullScreen) ...[
          CustomElevatedButton(
            onClick: () async {
              context.pop();
              Result.tryRun(() => context.pushNamed("${Routes.moduleContentsView.name}full", extra: collection));
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
        Consumer(
          builder: (context, value, child) {
            final cardViewType = state.select((s) => s.cardViewType).watch(ref);

            return AppPopupMenuButton(
              menuPadding: EdgeInsets.only(right: 16),
              buttonStyle: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.all(6)),
                shape: WidgetStateProperty.all(
                  CircleBorder(side: BorderSide(color: theme.altBackgroundSecondary.withValues(alpha: 0.4))),
                ),
                overlayColor: WidgetStateProperty.all(theme.secondary.withAlpha(40)),
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
              ),
              icon: HugeIconsSolid.more01,
              actions: [
                PopupMenuAction(
                  title: "View",
                  iconData: IconHelper.getCardViewTypeIconData(cardViewType),
                  onTap: () => state.act(ref).toggleCardViewType(),
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
                                    final contentOrdering = state
                                        .link(ref)
                                        .contentsPagination
                                        .select((s) => s.contentsOrdering)
                                        .watch(ref);
                                    return SmoothListView.builder(
                                      itemCount: EntityOrdering.values.length,
                                      itemBuilder: (context, index) {
                                        return CustomElevatedButton(
                                          pixelHeight: 44,
                                          backgroundColor: Colors.transparent,
                                          borderRadius: 0,
                                          onClick: () async {
                                            final newValue = EntityOrdering.values[index];
                                            state.act(ref).contentsPagination.act(ref).updateContentsOrdering(newValue);
                                            if (context.mounted) UiUtils.hideDialog(context);
                                          },
                                          child: Row(
                                            children: [
                                              RadioGroup<int>(
                                                groupValue: contentOrdering.index,
                                                onChanged: (p) async {},
                                                child: Radio(value: index),
                                              ),
                                              Expanded(child: CustomText(EntityOrdering.values[index].label)),
                                            ],
                                          ),
                                        );
                                      },
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

                if (DeviceUtils.isDesktop())
                  PopupMenuAction(
                    title: "Go back to Course Details",
                    iconData: HugeIconsStroke.arrowLeft01,
                    onTap: () async {
                      // final collection = await ModuleRepo.getByUid(collectionId);
                      // if (collection == null) return;
                      GlobalNav.withContext((c) {
                        (context.mounted ? context : c).pushReplacementNamed(
                          Routes.courseDetails.name,
                          extra: collection.parentId,
                        );
                      });
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
