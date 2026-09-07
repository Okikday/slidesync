import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/main/ui/entities/main_view_entity.dart';
import 'package:slidesync/features/main/ui/screens/main_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class MinimalPageSwitcher extends ConsumerStatefulWidget {
  const MinimalPageSwitcher({super.key});

  @override
  ConsumerState<MinimalPageSwitcher> createState() =>
      _MinimalPageSwitcherState();
}

class _MinimalPageSwitcherState extends ConsumerState<MinimalPageSwitcher> {
  double _horizontalDragDistance = 0;

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    // if (DeviceUtils.isDesktopSize()) return;
    _horizontalDragDistance += details.primaryDelta ?? 0;
  }

  void _handleHorizontalDragEnd(WidgetRef ref) {
    // if (DeviceUtils.isDesktop()) return;

    if (_horizontalDragDistance <= -50) {
      final len = mainViewTabOptions.keys.length;
      final nextIndex = (MainPod.me.read(ref).tabIndex + 1).clamp(0, len - 1);
      MainPod.me.act(ref).setTabIndex(nextIndex);
    } else if (_horizontalDragDistance >= 50) {
      final len = mainViewTabOptions.keys.length;
      final previousIndex = (MainPod.me.read(ref).tabIndex - 1).clamp(
        0,
        len - 1,
      );
      MainPod.me.act(ref).setTabIndex(previousIndex);
    }

    _horizontalDragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => _horizontalDragDistance = 0,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: (_) => _handleHorizontalDragEnd(ref),
      child: Consumer(
        builder: (_, ref, child) {
          final tabIndex = MainPod.me.select((s) => s.tabIndex).watch(ref);
          // return IndexedStack(index: tabIndex, children: tabs);
          return AnimatedSwitcher(
            duration: 200.inMs,
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            // swap
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[...previousChildren, ?currentChild],
              );
            },
            child: KeyedSubtree(
              key: ValueKey(tabIndex),
              child: mainViewTabOptions.keys.elementAt(tabIndex),
            ),
          );
        },
      ),
    );
  }
}
