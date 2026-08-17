import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_search_view/library_search_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_text.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

part 'src/__bottom_nav_bar.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  final void Function(int index) onTap;
  const BottomNavBar({super.key, required this.onTap});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  bool isUserSignedIn = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(
        () => isUserSignedIn = UserDataFunctions.me.isUserSignedIn(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final tabValues = mainViewTabOptions.values.toList();

    return BottomPadding(
      withHeight: 4,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  builder: (context, tabIndex, ref, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      tabValues.length + (isUserSignedIn ? 0 : -1),
                      (index) {
                        final isActive = tabIndex == index;
                        final option = tabValues[index];
                        return _BuildNavItem(
                          label: option.label,
                          tooltip: option.tooltip,
                          isActive: isActive,
                          onTap: () => widget.onTap(index),
                          labelColor: isActive
                              ? theme.onBackground
                              : theme.supportingText,
                          icon: Icon(
                            isActive ? option.activeIcon : option.icon,
                            color: isActive
                                ? theme.primaryColor
                                : theme.onBackground,
                            size: 25,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            /// Search nav item
            _SearchNavItem(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _navBarDecoration(WidgetRef theme) {
    return BoxDecoration(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(
        color: theme.onBackground.withValues(alpha: 0.15),
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );
  }
}
