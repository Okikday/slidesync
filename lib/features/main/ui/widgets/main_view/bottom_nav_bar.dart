import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_search_view/library_search_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_text.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

const List<({String label, String tooltip, IconData icon, IconData activeIcon})> _defaultNavBarOptions = [
  (label: "Home", tooltip: "Home", icon: HugeIconsStroke.home01, activeIcon: HugeIconsSolid.home01),
  (
    label: "Library",
    tooltip: "Library holding all your courses",
    icon: HugeIconsStroke.folder01,
    activeIcon: HugeIconsSolid.folder01,
  ),
  (label: "Sync", tooltip: "Sync details", icon: HugeIconsStroke.fileSync, activeIcon: HugeIconsSolid.fileSync),
];

class BottomNavBar extends ConsumerWidget {
  final void Function(int index) onTap;
  const BottomNavBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return BottomPadding(
      withHeight: 4,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AbsorberWatch(
              listenable: MainProvider.state.select((s) => s.tabIndex),
              builder: (context, tabIndex, ref, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: theme.onBackground.withValues(alpha: 0.15),
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),

                  clipBehavior: Clip.antiAlias,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final option in _defaultNavBarOptions)
                          Builder(
                            builder: (context) {
                              final index = _defaultNavBarOptions.indexOf(option);
                              final isActive = tabIndex == index;
                              return _BuildNavItem(
                                label: option.label,
                                tooltip: option.tooltip,
                                isActive: isActive,
                                onTap: () => onTap(index),
                                labelColor: isActive ? theme.onBackground : theme.supportingText,
                                icon: Icon(
                                  isActive ? option.activeIcon : option.icon,
                                  color: isActive ? theme.primaryColor : theme.onBackground,
                                  size: 25,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _SearchNavItem(),
          ],
        ),
      ),
    );
  }
}

class _SearchNavItem extends ConsumerWidget {
  const _SearchNavItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        border: Border.all(
          color: theme.onBackground.withValues(alpha: 0.15),
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        shape: BoxShape.circle,
      ),
      child: CustomElevatedButton(
        fixedSize: Size.square(50),
        shape: CircleBorder(),
        backgroundColor: Colors.transparent,
        onClick: () {
          Navigator.push(
            context,
            PageAnimation.pageRouteBuilder(
              const LibrarySearchView(),
              curve: CustomCurves.defaultIosSpring,
              duration: 700.inMs,
              type: TransitionType.combine(
                transitions: [
                  TransitionType.scale(alignment: Alignment.bottomRight, from: 0.1),
                  TransitionType.fadeIn,
                ],
              ),
            ),
          );
        },
        child: Icon(HugeIconsSolid.search02, color: theme.onBackground, size: 25),
      ),
    );
  }
}

class _BuildNavItem extends StatelessWidget {
  final String label;
  final Widget icon;
  final String tooltip;
  final bool isActive;
  final Color labelColor;
  final void Function() onTap;
  const _BuildNavItem({
    required this.label,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
    required this.icon,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.longPress,
      message: tooltip,
      child: CustomElevatedButton(
        onClick: onTap,
        fixedSize: Size(72, 64),
        // minimumSize: Size(70, 64),
        borderRadius: 40,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            ConstantSizing.columnSpacing(4),
            AppText(label, fontSize: 11, color: labelColor, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
