import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';

class MainViewController {
  static final NotifierProvider<IntNotifier, int> mainTabViewIndexProvider = NotifierProvider(IntNotifier.new);
  static final NotifierProvider<BoolNotifier, bool> isMainScrolledProvider = NotifierProvider(
    BoolNotifier.new,
    isAutoDispose: true,
  );

  static final NotifierProvider<BoolNotifier, bool> isFocusModeProvider = NotifierProvider(BoolNotifier.new);
}
