import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/ui/screens/explore_tab_view.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/library_floating_action_button.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_drawer.dart';
import 'package:slidesync/features/main/ui/screens/library_tab_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

import 'home_tab_view.dart';
import '../widgets/main_view/bottom_nav_bar.dart';
import '../widgets/main_view/main_view_annotated_region.dart';

const _views = [HomeTabView(), LibraryTabView(), ExploreTabView()];

class MainView extends ConsumerStatefulWidget {
  final int tabIndex;
  const MainView({super.key, required this.tabIndex});

  @override
  ConsumerState createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.tabIndex);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => MainProvider.of(ref).state.act(ref).setTabIndex(widget.tabIndex),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    return PopScope(
      canPop: false,
      child: MainViewAnnotatedRegion(
        child: AppScaffold(
          title: "",
          extendBody: true,
          extendBodyBehindAppBar: true,

          drawer: const HomeDrawer(),
          floatingActionButton: const LibraryFloatingActionButton(),

          body: Stack(
            children: [
              PageView(
                controller: pageController,
                // physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  MainProvider.of(ref).state.act(ref).setTabIndex(index);
                },
                children: _views,
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNavBar(
                  onTap: (index) {
                    final tabIndex = MainProvider.from(ref, (r, v) => v.state.read(r).tabIndex);
                    if (index != tabIndex) {
                      MainProvider.from(ref, (r, v) => v.state.act(r)).setTabIndex(index);
                      pageController.animateToPage(
                        index,
                        duration: Durations.extralong1,
                        curve: CustomCurves.defaultIosSpring,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}
