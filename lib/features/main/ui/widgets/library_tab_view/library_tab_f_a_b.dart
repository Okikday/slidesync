import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/pod/library/library_pod.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/create_course_f_a_b.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class LibraryTabFAB extends ConsumerWidget {
  final bool isDesktop;
  const LibraryTabFAB({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = MainPod.me.select((s) => s.tabIndex).watch(ref);
    // final isAtHome = tabIndex == 0;
    final isAtLibrary = tabIndex == 1;
    // final isAtElsewhere = !isAtHome && !isAtLibrary;
    if (!isAtLibrary && !isDesktop) return const SizedBox();
    final theme = Theme.of(context).custom;
    final tolerance = libraryAppBarMaxHeight + scrollTolerance;

    return Consumer(
      builder: (context, ref, child) {
        final isScrolled = LibraryPod.scrollOffset
            .select((s) => s > tolerance)
            .watch(ref);

        if (isScrolled) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: CustomElevatedButton(
              pixelHeight: 32,
              pixelWidth: 32,
              contentPadding: EdgeInsets.zero,
              shape: const CircleBorder(),
              backgroundColor: theme.primary,
              onClick: () {
                PrimaryScrollController.of(context).animateTo(
                  0,
                  duration: Durations.extralong1,
                  curve: CustomCurves.defaultIosSpring,
                );
              },
              child: Icon(Iconsax.arrow_up, color: theme.onPrimary),
            ).animate().scaleXY(begin: 1.2).fadeIn(),
          );
        }
        return child!;
      },

      child: Padding(
        padding: EdgeInsets.only(bottom: isDesktop ? 24 : 80),
        child: CreateCourseFAB(),
      ),
    );
  }
}
