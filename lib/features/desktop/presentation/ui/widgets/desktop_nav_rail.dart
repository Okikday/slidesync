import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/presentation/main/logic/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

/// The navigation rail widget for the desktop UI.
/// Replaces the mobile BottomNavBar and incorporates controls from the mobile HomeAppBar.
class DesktopNavRail extends ConsumerWidget {
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;

  const DesktopNavRail({super.key, required this.selectedIndex, required this.onDestinationSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.theme;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.selected,
      backgroundColor: theme.background,
      indicatorColor: theme.primaryColor.withOpacity(0.1),
      selectedIconTheme: IconThemeData(color: theme.primaryColor),
      unselectedIconTheme: IconThemeData(color: theme.onBackground.withOpacity(0.6)),
      selectedLabelTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: theme.onBackground.withOpacity(0.8)),
      minWidth: 80,

      // The app title, similar to the mobile HomeAppBar.
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'SlideSync',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.onBackground),
        ),
      ),

      destinations: const [
        NavigationRailDestination(
          icon: Icon(Iconsax.home_1),
          selectedIcon: Icon(Iconsax.home_1, weight: 900),
          label: Text("Home"),
        ),
        NavigationRailDestination(
          icon: Icon(Iconsax.folder_copy),
          selectedIcon: Icon(Iconsax.folder_copy, weight: 900),
          label: Text("Library"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: Text("Explore"),
        ),
      ],

      // Trailing buttons are moved here from the mobile HomeAppBar.
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notification Button for Focus Mode
                IconButton(
                  icon: Icon(Iconsax.notification, color: theme.onBackground.withOpacity(0.6)),
                  tooltip: "Toggle Focus Mode",
                  onPressed: () {
                    final focusModeNotifier = ref.read(MainProvider.isFocusModeProvider.notifier);
                    final isEnabled = focusModeNotifier.update((state) => !state);
                    // UiUtils.showFlushBar(context, msg: "Focus mode ${isEnabled ? "enabled" : "disabled"}");
                  },
                ),
                const SizedBox(height: 16),

                // User Icon to open the drawer
                IconButton(
                  icon: Icon(Iconsax.user, color: theme.onBackground.withOpacity(0.6)),
                  tooltip: "Profile & Settings",
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
