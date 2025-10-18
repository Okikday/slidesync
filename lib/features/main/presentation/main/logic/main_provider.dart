import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class MainProvider {
  static final tabIndexProvider = NotifierProvider(IntNotifier.new);
  static final isHomeScrolledProvider = NotifierProvider(BoolNotifier.new, isAutoDispose: true);

  static final isFocusModeProvider = NotifierProvider(BoolNotifier.new);
}
