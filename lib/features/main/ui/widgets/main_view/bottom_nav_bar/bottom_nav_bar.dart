import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:mira_widgets/mira_widgets.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_search_view/library_search_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_text.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

part 'src/__bottom_nav_bar.dart';

class BottomNavBar extends ConsumerWidget {
  final void Function(int index) onTap;
  const BottomNavBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final tabValues = mainViewTabOptions.values.toList();

    return BottomPadding(
      withHeight: 4,
      child:
          [
                /// Main nav bar
                Container(
                  decoration: _navBarDecoration(theme),
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  clipBehavior: Clip.antiAlias,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: AbsorberWatch(
                      listenable: MainProvider.state.select((s) => s.tabIndex),
                      builder: (context, tabIndex, ref, _) =>
                          List.generate(tabValues.length, (index) {
                            final isActive = tabIndex == index;
                            final option = tabValues[index];
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
                          })
                          // in row
                          .row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceAround),
                    ),
                  ),
                ),

                /// Search nav item
                _SearchNavItem(),
              ]
              // in centered row in sized box
              .rowCenter
              .sizedBox(h: 72),
    );
  }

  BoxDecoration _navBarDecoration(WidgetRef theme) {
    return BoxDecoration(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: theme.onBackground.withValues(alpha: 0.15), strokeAlign: BorderSide.strokeAlignOutside),
    );
  }
}
