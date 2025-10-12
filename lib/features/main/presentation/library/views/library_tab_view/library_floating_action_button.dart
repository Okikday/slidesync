import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/main/presentation/library/controllers/library_tab_controller.dart';
import 'package:slidesync/features/main/presentation/main/controllers/main_view_controller.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class LibraryFloatingActionButton extends ConsumerWidget {
  const LibraryFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAtLibrary = ref.watch(MainViewController.mainTabViewIndexProvider.select((p) => p == 1));
    if (!isAtLibrary) return const SizedBox();
    final theme = ref;
    final offset = ref.watch(LibraryTabController.scrollOffsetProvider);
    if (offset > libraryAppBarMaxHeight) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CustomElevatedButton(
          pixelHeight: 32,
          pixelWidth: 32,
          contentPadding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: ref.primary,
          onClick: () {
            ref
                .read(LibraryTabController.libraryTabStateProvider)
                .scrollController
                .animateTo(0, duration: Durations.extralong1, curve: CustomCurves.defaultIosSpring);
          },
          child: Icon(Iconsax.arrow_up, color: theme.onPrimary),
        ).animate().scaleXY(begin: 1.2).fadeIn(),
      );
    }
    // if(value > 240), Show an up arrow
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child:
          FloatingActionButton(
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
          ),
    );
  }
}
