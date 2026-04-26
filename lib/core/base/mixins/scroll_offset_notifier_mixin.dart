import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _scrollThreshold = 100.0;

mixin ScrollOffsetNotifierMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final ScrollController scrollController = ScrollController();
  final scrollOffsetNotifier = ValueNotifier<double>(0.0);

  double get scrollThreshold => _scrollThreshold;

  /// How much difference does the last offset have to be from the current before reflecting change
  double? get diffTolerance => null;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    final currOffset = scrollController.offset;
    if (diffTolerance != null && (currOffset - scrollOffsetNotifier.value).abs() < 0.5) return;
    scrollOffsetNotifier.value = currOffset;
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollOffsetNotifier.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
