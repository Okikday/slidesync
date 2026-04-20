import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/ui/actions/main_view_actions.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/library_floating_action_button.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_drawer.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/decorations/back_soft_edge_blur.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import '../widgets/main_view/bottom_nav_bar/bottom_nav_bar.dart';

class MainView extends ConsumerStatefulWidget {
  final int tabIndex;
  const MainView({super.key, required this.tabIndex});

  @override
  ConsumerState createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with MainViewActions {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.tabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => MainProvider.state.act(ref).setTabIndex(widget.tabIndex));
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = mainViewTabOptions.keys.toList();
    return AbsorberWatch(
      listenable: MainProvider.home.select((s) => s.isScrolled),
      builder: (_, isScrolled, ref, body) {
        return AppScaffold(
          title: "",
          canPop: false,
          extendBody: true,
          drawer: const HomeDrawer(),
          floatingActionButton: const LibraryFloatingActionButton(),
          systemUiOverlayStyle: _deriveSystemUiOverlayStyle(ref, isScrolled),
          body: body!,
          footer: BackSoftEdgeBlur(
            edgeType: EdgeType.bottomEdge,
            height: 84 + context.bottomPadding,
            child: BottomNavBar(
              onTap: (index) => onTapBottomNavBarItem(ref, index: index, pageController: pageController),
            ),
          ),
        );
      },
      child: PageView(
        controller: pageController,
        onPageChanged: (index) => MainProvider.state.act(ref).setTabIndex(index),
        children: tabs,
      ),
    );
  }
}

SystemUiOverlayStyle _deriveSystemUiOverlayStyle(WidgetRef ref, bool isScrolled) {
  final theme = ref;
  final brightness = ref.brightness;
  return SystemUiOverlayStyle(
    statusBarColor: isScrolled ? theme.secondaryColor.withAlpha(100) : theme.background,
    statusBarBrightness: brightness,
    statusBarIconBrightness: brightness,
    systemNavigationBarIconBrightness: brightness,
    systemNavigationBarColor: ref.cardColor,
  );
}
