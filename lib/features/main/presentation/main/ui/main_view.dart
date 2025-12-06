import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/library/ui/library_floating_action_button.dart';
import 'package:slidesync/features/main/presentation/main/logic/main_provider.dart';
import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_drawer.dart';
import 'package:slidesync/features/main/presentation/library/ui/library_tab_view.dart';

import '../../home/ui/home_tab_view/home_tab_view.dart';
import 'src/bottom_nav_bar.dart';
import 'src/main_view_annotated_region.dart';

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
      (_) => ref.read(MainProvider.tabIndexProvider.notifier).update((cb) => widget.tabIndex),
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
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,

          drawer: const HomeDrawer(),
          floatingActionButton: const LibraryFloatingActionButton(),

          body: Stack(
            children: [
              PageView(
                controller: pageController,
                onPageChanged: (index) {
                  ref.read(MainProvider.tabIndexProvider.notifier).update((cb) => index);
                },
                children: const [
                  HomeTabView(), LibraryTabView(),
                  // ExploreTabView()
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNavBar(
                  onTap: (index) {
                    if (index != ref.read(MainProvider.tabIndexProvider)) {
                      ref.read(MainProvider.tabIndexProvider.notifier).update((cb) => index);
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
