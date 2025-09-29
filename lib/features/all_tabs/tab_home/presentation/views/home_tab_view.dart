import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_app_bar.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_body.dart';
import 'package:slidesync/features/all_tabs/main/main_view_controller.dart';

const double isScrolledLvl = 40.0;

class HomeTabView extends ConsumerStatefulWidget {
  const HomeTabView({super.key});

  @override
  ConsumerState createState() => _HomeTabViewState();
}

class _HomeTabViewState extends ConsumerState<HomeTabView> with AutomaticKeepAliveClientMixin {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(scrollListener);
  }

  void scrollListener() {
    final isScrolledProvider = MainViewController.isMainScrolledProvider;
    final isScrolled = ref.read(isScrolledProvider);
    if (scrollController.offset > isScrolledLvl) {
      if (!isScrolled) {
        ref.read(isScrolledProvider.notifier).update((cb) => true);
      }
    } else {
      if (isScrolled) {
        ref.read(isScrolledProvider.notifier).update((cb) => false);
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void focusModeListener(bool? prev, bool next) {
    if (next) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen<bool>(MainViewController.isFocusModeProvider, focusModeListener);
    return NestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (context, isInnerBoxScrolled) {
        return [
          HomeAppBar(
            title: 'SlideSync',
            onClickUserIcon: () {
              Scaffold.of(context).openDrawer();
              // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Theme.of(context).scaffoldBackgroundColor));
            },
            onClickNotification: () {
              final focusModeProvider = ref.read(MainViewController.isFocusModeProvider.notifier);
              late bool prev;
              focusModeProvider.update((cb) {
                prev = cb;
                return !cb;
              });

              UiUtils.showFlushBar(context, msg: "Focus mode ${prev ? "disabled" : "enabled"}");
            },
          ),
        ];
      },

      body: HomeBody(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
