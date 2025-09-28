import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/providers/library_tab_view_providers.dart';
import 'package:slidesync/features/all_tabs/main/main_view_controller.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class LibraryFloatingActionButton extends ConsumerWidget {
  const LibraryFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainTabIndex = ref.watch(MainViewController.mainTabViewIndexProvider);
    if (mainTabIndex != 1) return const SizedBox();
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: LibraryTabViewProviders.scrollPositionNotifier,
      builder: (context, value, child) {
        // if(value > 240), Show an up arrow
        return FloatingActionButton(
          onPressed: () {
            context.pushNamed(Routes.createCourse.name);
          },
          tooltip: "Create course",
          shape: const CircleBorder(),
          backgroundColor: theme.primaryColor,
          child: ClipOval(
            child: ColoredBox(
              color: ref.primary,
              child: SizedBox.square(dimension: 51, child: Icon(Iconsax.add_copy, color: theme.onPrimary)),
            ),
          ),
        ).animate().scale(
          alignment: Alignment.bottomRight,
          curve: CustomCurves.bouncySpring,
          duration: Durations.extralong3,
        );
      },
    );
  }
}
