import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/src/custom_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/main/pod/main_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _mainNotifier = NotifierProvider(MainPod.new);

class MainPod extends Notifier<MainState> {
  static NotifierProvider<MainPod, MainState> get me => _mainNotifier;

  @override
  MainState build() => const MainState();

  // 1. Focus mode
  AsyncNotifierProvider<KCachedNotifier<bool, bool>, bool> get isFocusMode =>
      _isFocusModeProvider;

  /// ===================================================================================================
  /// METHODS
  /// ===================================================================================================
  void setTabIndex(int index) => state = state.copyWith(tabIndex: index);
}

// For checking if focus mode is enabled or not and persisting the values.
final _isFocusModeProvider = AsyncNotifierProvider(
  () => KCachedNotifier<bool, bool>(HiveDataKey.isFocusMode.name, false),
  dependencies: [MainPod.me],
  isAutoDispose: true,
);
