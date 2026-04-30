import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class LibraryTabBody extends ConsumerWidget {
  const LibraryTabBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(MainProvider.state.select((s) => s.tabIndex));
    return SmoothCustomScrollView(
          intensity: ScrollIntensity.slow,
          // physics: const BouncingScrollPhysics(),
          slivers: const [
            SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

            CoursesView(),

            SliverToBoxAdapter(child: BottomPadding(withHeight: kToolbarHeight * 2)),
          ],
        )
        .animate(target: tabIndex == 1 ? 1 : 0)
        .slideY(begin: 0.05, end: 0, duration: 700.inMs, curve: CustomCurves.defaultIosSpring)
        .fadeIn(duration: 500.inMs, curve: CustomCurves.decelerate);
  }
}
