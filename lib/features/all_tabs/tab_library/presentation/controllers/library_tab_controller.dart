import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/global_notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/library_tab_controller/library_tab_state.dart';

final _scrollOffsetProvider = NotifierProvider<DoubleNotifier, double>(DoubleNotifier.new, isAutoDispose: true);

class LibraryTabController {
  static NotifierProvider<DoubleNotifier, double> get scrollOffsetProvider => _scrollOffsetProvider;
  static Provider<LibraryTabState> get libraryTabStateProvider => rawLibraryTabStateProvider;
  
  static bool isCourseCardAnimating = false;

  static Offset? cardTapPositionDetails;
}
