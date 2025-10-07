import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/base/leak_prevention.dart';

class ModifyCollectionsState extends LeakPrevention {
  late final ScrollController scrollController;
  late final TextEditingController searchCollectionController;
  late final ValueNotifier<String> searchCollectionTextNotifier;
  late final ValueNotifier<double> scrollOffsetNotifier;

  ModifyCollectionsState() {
    scrollController = ScrollController();
    searchCollectionController = TextEditingController();
    searchCollectionTextNotifier = ValueNotifier("");
    scrollOffsetNotifier = ValueNotifier(0.0);
    scrollController.addListener(listenToscrollOffsetProvider);
    searchCollectionController.addListener(searchCollectionTextListener);
  }

  void listenToscrollOffsetProvider() {
    if (scrollController.positions.isNotEmpty) {
      scrollOffsetNotifier.value = scrollController.offset;
    }
  }

  void searchCollectionTextListener() {
    if (searchCollectionTextNotifier.value == searchCollectionController.text) return;
    searchCollectionTextNotifier.value = searchCollectionController.text;
  }

  @override
  void onDispose() {
    searchCollectionController.removeListener(searchCollectionTextListener);
    searchCollectionController.dispose();
    searchCollectionTextNotifier.dispose();
    scrollOffsetNotifier.dispose();
    scrollController.removeListener(listenToscrollOffsetProvider);
    scrollController.dispose();
    log("Disposed $this");
  }
}
