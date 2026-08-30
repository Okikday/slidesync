import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_search_view/library_search_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/src/app_theme_extension.dart';
import 'package:slidesync/shared/theme/theme.dart';
import 'package:slidesync/shared/widgets/decorations/backdrop_shadow.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_text.dart';

part 'src/__bottom_nav_bar.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  final void Function(int index) onTap;
  const BottomNavBar({super.key, required this.onTap});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabValues = mainViewTabOptions.values.toList();

    return Stack(
      alignment: .bottomCenter,
      children: [
        _BackdropWidget(),
        SizedBox(
          height: 72,
          child: BottomPadding(
            withHeight: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Main nav bar
                Container(
                  decoration: _navBarDecoration(theme),
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  clipBehavior: .antiAlias,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final tabIndex = MainPod.me
                          .select((s) => s.tabIndex)
                          .watch(ref);

                      return Row(
                        mainAxisSize: .min,
                        mainAxisAlignment: .spaceAround,
                        children: List.generate(
                          tabValues.length +
                              (UserDataFunctions.me.isUserSignedIn() ? 0 : -1),
                          (index) {
                            final isActive = tabIndex == index;
                            final option = tabValues[index];
                            return _BuildNavItem(
                              label: option.label,
                              tooltip: option.tooltip,
                              isActive: isActive,
                              onTap: () => widget.onTap(index),
                              labelColor: isActive
                                  ? theme.custom.onBackground
                                  : theme.custom.supportingText,
                              icon: Icon(
                                isActive ? option.activeIcon : option.icon,
                                color: isActive
                                    ? theme.primaryColor
                                    : theme.custom.onBackground,
                                size: 25,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                /// Search nav item
                _SearchNavItem(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _navBarDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(
        color: theme.custom.onBackground.withValues(alpha: 0.15),
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );
  }
}

class _BackdropWidget extends StatelessWidget {
  const _BackdropWidget();

  @override
  Widget build(BuildContext context) {
    return BackdropShadow(height: context.bottomPadding + 72);
  }
}
