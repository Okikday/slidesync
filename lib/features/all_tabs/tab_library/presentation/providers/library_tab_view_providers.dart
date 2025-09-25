import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/global_notifiers/card_view_type_notifier.dart';

class LibraryTabViewProviders {
  /// All To be used in just the LibraryTabView since it's a main view
  static final ValueNotifier<double> scrollPositionNotifier = ValueNotifier(0.0);

  static final AutoDisposeAsyncNotifierProvider<CardViewTypeNotifier, int> cardViewType =
      AutoDisposeAsyncNotifierProvider<CardViewTypeNotifier, int>(
        () => CardViewTypeNotifier(HiveDataPaths.libraryTabCardViewType, 2),
      );
  static bool isCourseCardAnimating = false;

  static Offset? cardTapPositionDetails;

  static void dispose() {
    scrollPositionNotifier.dispose();
    log("Disposed Library Tab View Providers");
  }
}
