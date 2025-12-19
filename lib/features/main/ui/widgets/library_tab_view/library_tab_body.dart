import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class LibraryTabBody extends ConsumerWidget {
  const LibraryTabBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmoothCustomScrollView(
      intensity: ScrollIntensity.slow,
      slivers: [
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        const CoursesView(),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacing(kBottomNavigationBarHeight + context.topPadding + 24)),
      ],
    );
  }
}
