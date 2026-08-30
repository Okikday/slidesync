import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/main/pod/home/home_pod.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/ui/actions/home/home_tab_actions.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/above/home_app_bar.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/body/home_body.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

const double isScrolledLvl = 40.0;

class HomeTabView extends ConsumerStatefulWidget {
  const HomeTabView({super.key});

  @override
  ConsumerState createState() => _HomeTabViewState();
}

class _HomeTabViewState extends ConsumerState<HomeTabView>
    with AutomaticKeepAliveClientMixin, HomeTabActions {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(scrollListener);
  }

  void scrollListener() => HomePod.me.expand(ref, (r, v) {
    final isScrolled = r.read(v.select((s) => s.isScrolled));
    scrollController.offset > isScrolledLvl && !isScrolled
        ? r.read(v.notifier).setIsScrolled(true)
        : isScrolled
        ? r.read(v.notifier).setIsScrolled(true)
        : () {};
  });

  @override
  void dispose() {
    scrollController
      ..removeListener(scrollListener)
      ..dispose();
    super.dispose();
  }

  void focusModeListener(bool? prev, bool next) =>
      SystemChrome.setEnabledSystemUIMode(
        next ? SystemUiMode.immersive : SystemUiMode.edgeToEdge,
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Listen to events on isFocusModeProvider
    ref.listen(
      MainPod.me.link(ref).isFocusMode,
      (a, b) => focusModeListener(a?.value, b.value ?? false),
    );
    // final tabIndex = MainPod.me.select((s) => s.tabIndex).watch(ref);
    return NestedScrollView(
      controller: scrollController,
      physics: DeviceUtils.isDesktop()
          ? const NeverScrollableScrollPhysics()
          : null,
      headerSliverBuilder: (context, isInnerBoxScrolled) {
        return [
          HomeAppBar(
            title: '',
            onClickHamburger: () {
              Scaffold.of(context).openDrawer();
              // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Theme.of(context).scaffoldBackgroundColor));
            },
            onClickFocusButton: () => onClickFocusButton(ref),
          ),
        ];
      },

      body: HomeBody(),
    );
    // .animate(key: ValueKey(tabIndex != 0), target: tabIndex == 0 ? 1 : 0)
    // .blurXY(begin: 0.5, end: 0)
    // .scaleXY(begin: 1.1, end: 1.0, duration: 600.inMs, curve: CustomCurves.defaultIosSpring)
    // .fade(begin: 0.4, end: 1.0);
  }

  @override
  bool get wantKeepAlive => true;
}
