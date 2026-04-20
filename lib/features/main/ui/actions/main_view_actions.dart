import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

mixin MainViewActions {
  /// 1. Handles taps on the bottom navigation bar items. Under [MainView()]
  void onTapBottomNavBarItem(WidgetRef ref, {required int index, required PageController pageController}) =>
      MainProvider.state.expand(ref, (r, v) {
        if (v.read(r).tabIndex != index) {
          v.act(r).setTabIndex(index);
          // pageController.animateToPage(index, duration: 700.inMs, curve: CustomCurves.defaultIosSpring);
          pageController.jumpToPage(index);
        }
      });
}
