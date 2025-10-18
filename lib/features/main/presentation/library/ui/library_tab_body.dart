import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/courses_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class LibraryTabBody extends ConsumerWidget {
  const LibraryTabBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        const CoursesView(),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacing(kBottomNavigationBarHeight + context.topPadding + 24)),
      ],
    );
  }
}
