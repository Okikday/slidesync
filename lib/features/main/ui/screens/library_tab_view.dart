import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/library_tab_body.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class LibraryTabView extends ConsumerStatefulWidget {
  const LibraryTabView({super.key});

  @override
  ConsumerState createState() => _LibraryTabViewState();
}

class _LibraryTabViewState extends ConsumerState<LibraryTabView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final tabIndex = MainProvider.state.select((s) => s.tabIndex).watch(ref);
    return NestedScrollView(
      controller: MainProvider.library.link(ref).scrollController,
      // physics: const NeverScrollableScrollPhysics(),
      headerSliverBuilder: (context, isInnerBoxScrolled) => const [LibraryTabViewAppBar()],
      body: const LibraryTabBody(),
    );
    // .animate(key: ValueKey(tabIndex != 1), target: tabIndex == 1 ? 1 : 0) // gotta handle target too for smoother
    // .blurXY(begin: 0.5, end: 0)
    // .scaleXY(begin: 1.1, end: 1.0, duration: 600.inMs, curve: CustomCurves.defaultIosSpring)
    // .fade(begin: 0.4, end: 1.0);
  }

  @override
  bool get wantKeepAlive => true;
}
