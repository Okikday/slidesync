import 'package:slidesync/features/main/providers/entities/main_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

final _isFocusModeProvider = NotifierProvider.autoDispose(BoolNotifier.new);

class MainNotifier extends Notifier<MainState> {
  @override
  MainState build() {
    ref.emptyListenMany([isFocusMode]); // As long as MainNotifier is alive, this is also alive
    return const MainState();
  }

  final isFocusMode = _isFocusModeProvider;

  void setTabIndex(int index) => state = state.copyWith(tabIndex: index);
}
