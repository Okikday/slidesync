import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_app_bar.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:window_manager/window_manager.dart';

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
    final homeProvider = MainProvider.of(ref).home;
    final isScrolled = MainProvider.of(ref).home.select((s) => s.isScrolled).read(ref);
    scrollController.offset > isScrolledLvl && !isScrolled
        ? homeProvider.act(ref).setIsScrolled(true)
        : isScrolled
        ? homeProvider.act(ref).setIsScrolled(false)
        : () {};
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
    final isFocusModeProvider = MainProvider.of(ref).state.act(ref).isFocusModeProvider;
    ref.listen<bool>(isFocusModeProvider, focusModeListener);
    return NestedScrollView(
      controller: scrollController,
      physics: DeviceUtils.isDesktop() ? const NeverScrollableScrollPhysics() : null,
      headerSliverBuilder: (context, isInnerBoxScrolled) {
        return [
          HomeAppBar(
            title: '',
            onClickHamburger: () {
              Scaffold.of(context).openDrawer();
              // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Theme.of(context).scaffoldBackgroundColor));
            },
            onClickNotification: () {
              final focusModeProvider = isFocusModeProvider.act(ref);
              late bool prev;
              focusModeProvider.update((cb) {
                prev = cb;
                return !cb;
              });
              if (DeviceUtils.isDesktop()) {
                if (prev) {
                  windowManager.setFullScreen(false).then((_) {
                    windowManager.maximize(vertically: true);
                  });
                } else {
                  windowManager.maximize(vertically: true).then((_) {
                    windowManager.setFullScreen(true);
                  });
                }
              }

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
