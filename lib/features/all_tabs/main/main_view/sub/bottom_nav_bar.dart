import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/all_tabs/main/main_view_controller.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class BottomNavBar extends ConsumerWidget {
  final void Function(int index) onTap;
  const BottomNavBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.antiAlias,

      shape: Border(top: BorderSide(color: theme.onBackground.withAlpha(20))),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Consumer(
          builder: (context, ref, child) {
            final currIndex = ref.watch(MainViewController.mainTabViewIndexProvider);
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currIndex,
              unselectedItemColor: theme.supportingText,
              selectedItemColor: theme.primaryColor,
              onTap: (index) => onTap(index),
              backgroundColor: theme.background.withValues(alpha: 0.8),
              elevation: 0,
              landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
              items: const [
                BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home", tooltip: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.folder),
                  label: "Library",
                  tooltip: "Library holding all your courses",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_rounded),
                  label: "Explore",
                  tooltip: "Explore courses",
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
