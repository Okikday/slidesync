import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
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
  (label: "Explore", tooltip: "Explore courses", icon: HugeIconsStroke.compass01, activeIcon: HugeIconsSolid.compass01),
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
        height: 80,
        child: AbsorberWatch(
          listenable: MainProvider.state.select((s) => s.tabIndex),
          builder: (context, tabIndex, ref, _) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: theme.onScaffoldBackgroundColor.withValues(alpha: 0.4)),
              ),
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Row(
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
    return CustomElevatedButton(
      onClick: onTap,
      fixedSize: Size(90, 64),
      borderRadius: 40,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          ConstantSizing.columnSpacing(4),
          AppText(label, fontSize: 10, color: labelColor),
        ],
      ),
    );
  }
}
