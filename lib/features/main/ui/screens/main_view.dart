import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickin_utilities/kickin_utilities.dart' as ku;
import 'package:multi_split_view/multi_split_view.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/main/pod/home/home_pod.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/ui/actions/main_view_actions.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/main_view/content_sidebar/content_sidebar.dart';
import 'package:slidesync/features/main/ui/widgets/main_view/nav_rail/nav_rail.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/library_tab_f_a_b.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/above/home_drawer.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/animations/animated_sizing.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

import '../widgets/main_view/bottom_nav_bar/bottom_nav_bar.dart';

enum MainPanes { navRail, mainContent, contentSidebar }

class MainView extends ConsumerStatefulWidget {
  final int tabIndex;
  const MainView({super.key, required this.tabIndex});

  @override
  ConsumerState createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with MainViewActions {
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    pageController.addListener(_pageListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabIndex = MainPod.me.select((s) => s.tabIndex).read(ref);
      if (pageController.hasClients &&
          pageController.page?.round() != tabIndex) {
        _animateToTab(tabIndex);
      }
    });
  }

  void _pageListener() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final isScrolling = pageController.position.isScrollingNotifier.value;
    final userScrolled = pageController.position.userScrollDirection != .idle;
    if (isScrolling && !userScrolled) return;

    final isHalfway =
        pageController.page != null && pageController.page! % 1 != 0;
    if (isHalfway && isScrolling && !userScrolled) return;

    MainPod.me.not(ref).setTabIndex(pageController.page?.round() ?? 0);
  });

  @override
  void dispose() {
    pageController.removeListener(_pageListener);
    pageController.dispose();
    super.dispose();
  }

  void _animateToTab(int index) => DeviceUtils.isDesktopSize()
      ? pageController.jumpToPage(index)
      : pageController.animateToPage(
          index,
          duration: NumDurationExtension(450).inMs,
          curve: ku.KCurves.defaultIosSpring,
        );

  void _onTapNavItem(int index) {
    if (MainPod.me.read(ref).tabIndex == index) {
      // Tapping the active tab scrolls to top
      PrimaryScrollController.of(context).animateTo(
        0,
        duration: NumDurationExtension(200).inMs,
        curve: Curves.easeInOutCubicEmphasized,
      );
      return;
    }
    _animateToTab(index);
    MainPod.me.not(ref).setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = DeviceUtils.isDesktopSize(context);

    return Consumer(
      builder: (context, ref, body) {
        return AppScaffold(
          title: "",
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            MainPod.me.act(ref).setTabIndex(0);
          },
          extendBody: true,
          drawer: const HomeDrawer(),
          floatingActionButton: const LibraryTabFAB(),
          body: Consumer(
            builder: (context, ref, child) {
              final isScrolled = HomePod.me
                  .select((s) => s.isScrolled)
                  .watch(ref);
              return AnnotatedRegion(
                value: _deriveSystemUiOverlayStyle(context, isScrolled),
                child: child!,
              );
            },
            child: MultiSplitView(
              resizable: true,
              dividerThickness: 4,
              dividerHighlightColor: Colors.blueGrey.withAlpha(50),
              builder: (context, area) => isDesktop
                  ? _buildAreaWidget(area.id, isDesktop)
                  : area.id == MainPanes.mainContent
                  ? _buildAreaWidget(area.id, isDesktop)
                  : null,
              initialAreas: [
                Area(id: MainPanes.navRail, min: 200, max: 240, size: 240),
                Area(id: MainPanes.mainContent),
              ],
            ),
          ),
          footer: isDesktop ? null : BottomNavBar(onTap: _onTapNavItem),
        );
      },
    );
  }

  Widget _buildAreaWidget(MainPanes pane, bool isDesktop) {
    // if (!isDesktop && pane != .mainContent) return const SizedBox.shrink();
    return switch (pane) {
      .mainContent => PageView(
        physics: isDesktop ? const NeverScrollableScrollPhysics() : null,
        controller: pageController,
        onPageChanged: (index) => MainPod.me.act(ref).setTabIndex(index),
        children:
            (UserDataFunctions.me.isUserSignedIn()
                    ? mainViewTabOptions.keys
                    : mainViewTabOptions.keys.take(2))
                .toList(),
      ),
      .navRail => AnimatedSizing.normal(
        child: NavRail(onTabChanged: _onTapNavItem),
      ),
      .contentSidebar => const ContentSidebar(),
    };
  }
}

SystemUiOverlayStyle _deriveSystemUiOverlayStyle(
  BuildContext context,
  bool isScrolled,
) {
  final theme = Theme.of(context).custom;
  final brightness = theme.brightness;
  return SystemUiOverlayStyle(
    statusBarColor: isScrolled
        ? theme.secondaryColor.withAlpha(100)
        : theme.background,
    statusBarBrightness: brightness,
    statusBarIconBrightness: brightness,
    systemNavigationBarIconBrightness: brightness,
    systemNavigationBarColor: theme.cardColor,
  );
}
