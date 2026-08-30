import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickin_utilities/kickin_utilities.dart' as ku;
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/main/pod/home/home_pod.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/ui/actions/main_view_actions.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/library_tab_f_a_b.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/above/home_drawer.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/decorations/back_soft_edge_blur.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/main/ui/screens/home_tab_view.dart';
import 'package:slidesync/features/main/ui/screens/library_tab_view.dart';
import 'package:slidesync/features/sync/ui/screens/sync_view.dart';

import '../widgets/main_view/bottom_nav_bar/bottom_nav_bar.dart';

typedef _TabDetails = ({
  String label,
  String tooltip,
  IconData icon,
  IconData activeIcon,
});
final mainViewTabOptions = <Widget, _TabDetails>{
  const HomeTabView(): (
    label: "Home",
    tooltip: "Home",
    icon: HugeIconsStroke.home01,
    activeIcon: HugeIconsSolid.home01,
  ),
  const LibraryTabView(): (
    label: "Library",
    tooltip: "Library holding all your courses",
    icon: HugeIconsStroke.folder01,
    activeIcon: HugeIconsSolid.folder01,
  ),
  const SyncView(): (
    label: "Sync",
    tooltip: "Sync details",
    icon: HugeIconsStroke.fileSync,
    activeIcon: HugeIconsSolid.fileSync,
  ),
};

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

  void _animateToTab(int index) => pageController.animateToPage(
    index,
    duration: NumDurationExtension(450).inMs,
    curve: ku.KCurves.defaultIosSpring,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, body) {
        final isScrolled = HomePod.me.select((s) => s.isScrolled).watch(ref);

        return AppScaffold(
          title: "",
          canPop: false,
          onPopInvokedWithResult: (didPop, result) =>
              MainPod.me.act(ref).setTabIndex(0),
          extendBody: true,
          drawer: const HomeDrawer(),
          floatingActionButton: const LibraryTabFAB(),
          systemUiOverlayStyle: _deriveSystemUiOverlayStyle(
            context,
            isScrolled,
          ),
          body: body!,
          footer: BottomNavBar(
            onTap: (index) {
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
            },
          ),
        );
      },
      child: PageView(
        controller: pageController,
        onPageChanged: (index) => MainPod.me.act(ref).setTabIndex(index),
        children:
            (UserDataFunctions.me.isUserSignedIn()
                    ? mainViewTabOptions.keys
                    : mainViewTabOptions.keys.take(2))
                .toList(),
      ),
      // child: GestureDetector(
      //   onHorizontalDragStart: (_) => _horizontalDragDistance = 0,
      //   onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      //   onHorizontalDragEnd: (_) => _handleHorizontalDragEnd(ref),
      //   child: AbsorberWatch(
      //     listenable: MainPod.me.select((s) => s.tabIndex),
      //     builder: (_, tabIndex, ref, _) {
      //       // return IndexedStack(index: tabIndex, children: tabs);
      //       return AnimatedSwitcher(
      //         duration: 200.inMs,
      //         switchInCurve: Curves.easeInOut,
      //         switchOutCurve: Curves.easeInOut,
      //         // swap
      //         transitionBuilder: (child, animation) {
      //           return FadeTransition(opacity: animation, child: child);
      //         },
      //         layoutBuilder: (currentChild, previousChildren) {
      //           return Stack(
      //             fit: StackFit.expand,
      //             children: <Widget>[...previousChildren, ?currentChild],
      //           );
      //         },
      //         child: KeyedSubtree(
      //           key: ValueKey(tabIndex),
      //           child: tabs[tabIndex],
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
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
