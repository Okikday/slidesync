import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/browse/ui/actions/module/modify_module_actions.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/edit_collection_title_bottom_sheet.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class CollectionCard extends ConsumerStatefulWidget {
  final Module collection;
  final void Function() onTap;
  final ({bool? selected, void Function() onSelected})? select;
  final bool showSelectOption;
  final String? subtitleText;
  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    this.select,
    this.showSelectOption = false,
    this.subtitleText,
  });

  @override
  ConsumerState<CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends ConsumerState<CollectionCard> {
  // final List<RoundedPolygon> shapes = List.from(materialShapes.map((e) => e.shape));
  // late final RoundedPolygon shape;
  // @override
  // void initState() {
  //   super.initState();
  //   final randomIndex = math.Random().nextInt(shapes.length);
  //   shape = shapes[randomIndex];
  // }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final collection = widget.collection;
    return ScaleClickWrapper(
      borderRadius: 12,
      onTap: widget.select == null ? widget.onTap : widget.select?.onSelected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.supportingText.withAlpha(10),
          border: Border.all(color: theme.supportingText.withAlpha(12)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.hardEdge,
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: collection.metadata.color?.withValues(alpha: 0.1) ?? ref.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: collection.metadata.color?.withAlpha(40) ?? ref.primary.withAlpha(40),
                      width: 1.0,
                    ),
                  ),
                ),
                // child: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: ClipPath(
                //     clipper: MorphClipper(path: shape.toPath(), size: Size(20, 20)),
                //     child: ColoredBox(color: theme.primaryColor),
                //   ),
                // ),
                alignment: Alignment.center,
                child: CustomText(
                  collection.title.substring(0, 1).toUpperCase(),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: collection.metadata.color ?? theme.primaryColor,
                ),
              ),
              ConstantSizing.rowSpacingMedium,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.0,
                  children: [
                    CustomText(
                      collection.title,
                      fontSize: 15,
                      color: theme.onBackground,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                    ),
                    CustomText(
                      widget.subtitleText ??
                          "${collection.contents.isEmpty ? "No" : "${collection.contents.length}"} ${collection.contents.length == 1 ? "item" : "items"}",
                      fontSize: 12,
                      color: theme.supportingText,
                    ),
                  ],
                ),
              ),

              /// Trailing more options
              if (widget.select == null || widget.select?.selected == null)
                AppPopupMenuButton(
                  actions: [
                    if (widget.showSelectOption)
                      PopupMenuAction(
                        title: "Select",
                        iconData: Iconsax.tick_circle,
                        onTap: () {
                          widget.select?.onSelected();
                        },
                      ),

                    PopupMenuAction(
                      title: "Share",
                      iconData: HugeIconsSolid.share01,
                      onTap: () async {
                        await ShareContentActions.shareCollection(context, collection.uid);
                      },
                    ),

                    PopupMenuAction(
                      title: "Rename",
                      iconData: HugeIconsSolid.edit01,
                      onTap: () async {
                        CustomDialog.hide(context);
                        final coll = await ModuleRepo.getByUid(collection.uid);
                        if (coll == null) return;
                        GlobalNav.withContext(
                          (c) => UiUtils.showCustomDialog(
                            context.mounted ? context : c,
                            child: EditCollectionTitleBottomSheet(collection: coll),
                          ),
                        );
                      },
                    ),

                    PopupMenuAction(
                      title: "Remove",
                      iconData: HugeIconsSolid.delete02,
                      onTap: () async {
                        if (context.mounted) {
                          CustomDialog.show(
                            context,
                            canPop: true,
                            barrierColor: Colors.black.withValues(alpha: 0.6),
                            transitionType: TransitionType.cupertinoDialog,
                            transitionDuration: Durations.medium2,
                            child: ConfirmDeletionDialog(
                              content:
                                  "This will delete \"${collection.title}\"."
                                  "\n\nAre you sure you want to delete this collection?",
                              onPop: () {
                                GlobalNav.popGlobal();
                              },
                              onCancel: () {
                                GlobalNav.popGlobal();
                              },
                              onDelete: () async {
                                await ModifyModuleActions().onDeleteCollection(context, collection: collection);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )
              else
                Builder(
                  builder: (context) {
                    final select = widget.select;
                    final isSelected = select?.selected == true;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.transparent : ref.onBackground.withAlpha(10),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.supportingText.withAlpha(12)),
                      ),
                      child: isSelected
                          ? Icon(Iconsax.tick_circle, color: ref.primary)
                          : CircleAvatar(radius: 10, backgroundColor: Colors.transparent, child: const SizedBox()),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
