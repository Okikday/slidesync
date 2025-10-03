import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/courses_view.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

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
