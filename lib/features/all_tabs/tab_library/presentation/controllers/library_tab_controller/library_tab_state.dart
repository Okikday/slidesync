import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/leak_prevention.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/library_tab_controller.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar.dart';

final rawLibraryTabStateProvider = Provider<LibraryTabState>((ref) {
  final lts = LibraryTabState.of(ref);
  ref.onDispose(lts.dispose);
  return lts;
}, isAutoDispose: true);

class LibraryTabState extends LeakPrevention {
  late final Ref ref;
  late final ScrollController scrollController;
  LibraryTabState._(this.ref) {
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  static LibraryTabState of(Ref ref) => LibraryTabState._(ref);

  void scrollListener() {
    const tol = 20;
    if (scrollController.offset > libraryAppBarMaxHeight + tol) return;
    // if (offset < libraryAppBarMaxHeight - tol) return; // Because of the Library Header Text
    ref.read(LibraryTabController.scrollOffsetProvider.notifier).update((cb) => scrollController.offset);
  }

  @override
  void onDispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    log("Disposed LibraryTabState!");
  }
}
