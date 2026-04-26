import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/providers/module_contents_provider.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_notifier/module_contents_notifier.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/mod_contents_options_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/animations/animated_sizing.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

typedef _OptionStruct = ({
  String title,
  IconData iconData,
  void Function(BuildContext c, ModuleContentsNotifier n) onClick,
});
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

class ModContentsOptions extends ConsumerWidget {
  final Module collection;
  const ModContentsOptions({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleContentsPro = ModuleContentsProvider.state(collection);
    ref.listen(moduleContentsPro, (p, n) => n);

    final theme = ref;
    final plainBtnBgColor = theme.supportingText.withAlpha(20);
    final plainBtnTextColor = theme.onSurface;
    return PinnedHeaderSliver(
      child: AbsorberWatch(
        listenable: moduleContentsPro,
        builder: (context, proState, _, _) {
          return AnimatedSizing.fast(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                proState.hasSelectedContents
                    ? SizedBox.shrink()
                    : Container(
                        height: 50,

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
                                onClick: () => moduleContentsPro.act(ref).unselectAllContents(),
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
                                  onClick: () => e.onClick(context, moduleContentsPro.link(ref)),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
              ],
            ),
          );
        },
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
