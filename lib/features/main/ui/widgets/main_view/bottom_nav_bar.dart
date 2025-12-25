import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/providers/main/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

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
            final currIndex = ref.watch(MainProvider.tabIndexProvider);
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
