import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';

class ModifyCollectionsState extends LeakPrevention with ValueNotifierFactoryMixin {
  late final ScrollController scrollController;
  late final TextEditingController searchController;
  late final ValueNotifier<String> searchCollectionTextNotifier;
  late final ValueNotifier<double> scrollOffsetNotifier;

  ModifyCollectionsState() {
    scrollController = ScrollController();
    searchController = TextEditingController();
    searchCollectionTextNotifier = useValueNotifier("");
    scrollOffsetNotifier = useValueNotifier(0.0);
    scrollController.addListener(_listenToScrollOffset);
    searchController.addListener(searchCollectionTextListener);
  }

  void _listenToScrollOffset() {
    if (scrollController.positions.isNotEmpty) {
      scrollOffsetNotifier.value = scrollController.offset;
    }
  }

  void searchCollectionTextListener() {
    if (searchCollectionTextNotifier.value == searchController.text) return;
    searchCollectionTextNotifier.value = searchController.text;
  }

  @override
  void onDispose() {
    searchController.removeListener(searchCollectionTextListener);
    searchController.dispose();
    disposeNotifiers();
    scrollController.removeListener(_listenToScrollOffset);
    scrollController.dispose();
    log("Disposed $this");
  }
}
