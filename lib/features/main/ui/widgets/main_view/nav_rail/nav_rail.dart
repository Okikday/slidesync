import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/features/main/ui/widgets/main_view/nav_rail/src/logo_header.dart';
import 'package:slidesync/app/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/pod/theme_pod.dart';
import 'package:slidesync/shared/widgets/decorations/backdrop_shadow.dart';

class NavRail extends ConsumerWidget {
  final void Function(int index) onTabChanged;
  const NavRail({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!DeviceUtils.isDesktopSize(context)) return const SizedBox.shrink();
    final tabValues = mainViewTabOptions.values.toList();
    final customTheme = Theme.of(context).custom;
    return Stack(
      alignment: .centerLeft,
      children: [
        Container(
          height: double.infinity,
          clipBehavior: .antiAlias,
          // margin: .only(left: 8),
          decoration: _navBarDecoration(customTheme),
          child: Material(
            type: .transparency,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 20),
                LogoHeader(),
                const SizedBox(height: 20),
                Consumer(
                  builder: (context, ref, _) {
                    final tabIndex = MainPod.me
                        .select((s) => s.tabIndex)
                        .watch(ref);
                    return Padding(
                      padding: const .symmetric(horizontal: 8),
                      child: Column(
                        children: List.generate(
                          tabValues.length +
                              (UserDataFunctions.me.isUserSignedIn() ? 0 : -1),
                          (index) {
                            final tab = tabValues[index];
                            return NavRailDestination(
                              icon: (tab.activeIcon, tab.icon),
                              label: tab.label,
                              isSelected: tabIndex == index,
                              onTap: () => onTabChanged(index),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                Spacer(),
                Padding(
                  padding: const .only(left: 8),
                  child: Column(
                    spacing: 12,
                    children: [
                      BuildButton(
                        iconData: Iconsax.setting,
                        onTap: () => context.pushNamed(Routes.settings.name),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: customTheme.surface.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: customTheme.onBackground.withAlpha(10),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            BuildButton(
                              shape: customTheme.isDarkMode
                                  ? const CircleBorder()
                                  : null,
                              backgroundColor: Colors.transparent,
                              iconData: Iconsax.sun_copy,
                              onTap: () {
                                ThemePod.me.act(ref).toggleThemeMode();
                              },
                            ),
                            BuildButton(
                              shape: customTheme.isDarkMode
                                  ? null
                                  : const CircleBorder(),
                              backgroundColor: Colors.transparent,
                              iconData: Iconsax.moon,
                              onTap: () {
                                ThemePod.me.act(ref).toggleThemeMode();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _BackdropWidget(),
      ],
    );
  }

  BoxDecoration _navBarDecoration(AppThemeExtension theme) {
    return BoxDecoration(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      // borderRadius: .only(topRight: .circular(40), bottomRight: .circular(40)),
      border: Border.all(
        color: theme.onBackground.withValues(alpha: 0.15),
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );
  }
}

class NavRailDestination extends StatelessWidget {
  final VoidCallback? onTap;
  final (IconData active, IconData inactive) icon;
  final String label;
  final bool isSelected;
  const NavRailDestination({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).custom;
    return ListTile(
      selected: isSelected,
      tileColor: Colors.transparent,
      selectedTileColor: customTheme.primary.withAlpha(30),
      leading: Icon(
        isSelected ? icon.$1 : icon.$2,
        color: isSelected
            ? customTheme.primary
            : customTheme.supportingText.withAlpha(150),
      ),

      title: CustomText(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).custom.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _BackdropWidget extends StatelessWidget {
  const _BackdropWidget();

  @override
  Widget build(BuildContext context) => BackdropShadow(
    height: .infinity,
    width: 24,
    shadowDirection: (.centerLeft, .centerRight),
  );
}
