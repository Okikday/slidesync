import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/browse/collection/providers/src/mod_contents_state.dart';
import 'package:slidesync/features/browse/collection/ui/actions/mod_contents_options_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

typedef _OptionStruct = ({
  String title,
  IconData iconData,
  void Function(BuildContext c, ModContentsNotifier n) onClick,
});

class ModContentsOptions extends ConsumerWidget {
  final String collectionTitle;
  final int? collectionLength;
  ModContentsOptions({super.key, required this.collectionTitle, this.collectionLength});
  final _options = <_OptionStruct>[
    (title: "Move", iconData: HugeIconsSolid.move, onClick: (c, n) => ModContentsOptionsActions.onMove(c, n)),
    (title: "Share", iconData: HugeIconsSolid.share01, onClick: (c, n) => ModContentsOptionsActions.onShare(c, n)),
    (
      title: "Select All",
      iconData: HugeIconsSolid.select01,
      onClick: (c, n) => ModContentsOptionsActions.onSelectAll(c, n),
    ),
    (title: "Delete", iconData: HugeIconsSolid.delete01, onClick: (c, n) => ModContentsOptionsActions.delete(c, n)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CollectionMaterialsProvider.modState.watch(ref);
    final mcvp = CollectionMaterialsProvider.modState.link(ref);
    final theme = ref;
    final plainBtnBgColor = theme.supportingText.withAlpha(20);
    final plainBtnTextColor = theme.onSurface;
    return PinnedHeaderSliver(
      child: AnimatedContainer(
        duration: Durations.extralong1,
        curve: CustomCurves.defaultIosSpring,
        height: mcvp.selectedContents.isNotEmpty ? 50 : 0,

        margin: EdgeInsets.symmetric(horizontal: 20),
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: theme.background.lightenColor(context.isDarkMode ? 0.2 : 0.9),
          border: Border.all(color: theme.supportingText.withAlpha(20)),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: CustomElevatedButton(
                backgroundColor: theme.onPrimary.withAlpha(200),
                onClick: () => CollectionMaterialsProvider.modState.act(ref).clearContents(),
                shape: CircleBorder(),
                child: Icon(HugeIconsStroke.cancelCircle, color: theme.primary),
              ),
            ),

            ...(_options.map(
              (e) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: _PlainOptionButton(
                  color: (bgColor: plainBtnBgColor, onBgColor: plainBtnTextColor),
                  title: e.title,
                  iconData: e.iconData,
                  onClick: () => e.onClick(context, mcvp),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _PlainOptionButton extends StatelessWidget {
  const _PlainOptionButton({required this.color, required this.title, required this.iconData, this.onClick});
  final String title;
  final IconData iconData;
  final void Function()? onClick;
  final ({Color bgColor, Color onBgColor}) color;

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      backgroundColor: color.bgColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
      borderRadius: ConstantSizing.borderRadiusCircle,
      onClick: onClick,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(iconData, color: color.onBgColor.withValues(alpha: 200)),
          CustomText(title, color: color.onBgColor),
        ],
      ),
    );
  }
}
