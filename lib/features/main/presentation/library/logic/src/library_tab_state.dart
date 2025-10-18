import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/library_tab_view_app_bar.dart';

class LibraryTabState extends LeakPrevention with ValueNotifierFactoryMixin {
  ///|
  ///|
  /// ===================================================================================================
  /// STATIC VARIABLES
  /// ===================================================================================================

  static bool isCourseCardAnimating = false;
  static Offset? cardTapPositionDetails;

  ///|
  ///|
  /// ===================================================================================================
  /// VARIABLES
  /// ===================================================================================================

  late final Ref ref;
  late final ScrollController scrollController;
  late final ValueNotifier<double> scrollOffsetNotifier;

  ///|
  ///|
  /// ===================================================================================================
  /// INIT
  /// ===================================================================================================
  LibraryTabState._(this.ref) {
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    scrollOffsetNotifier = useValueNotifier(0.0);
  }
  static LibraryTabState of(Ref ref) => LibraryTabState._(ref);

  ///|
  ///|
  /// ===================================================================================================
  /// DISPOSAL
  /// ===================================================================================================
  @override
  void onDispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    disposeNotifiers();
    log("Disposed LibraryTabState!");
  }

  ///|
  ///|
  /// ===================================================================================================
  /// LISTENERS
  /// ===================================================================================================
  void scrollListener() {
    const tol = 20;
    if (scrollController.offset > libraryAppBarMaxHeight + tol) return;
    // if (offset < libraryAppBarMaxHeight - tol) return; // Because of the Library Header Text
    scrollOffsetNotifier.value = scrollController.offset;
  }

  ///|
  ///|
  /// ===================================================================================================
  /// METHODS
  /// ===================================================================================================
}
