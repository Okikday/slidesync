import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_state.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_notifier/module_contents_notifier.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _moduleContentsNotifier = NotifierProvider.family.autoDispose((Module arg) => ModuleContentsNotifier(arg));

class ModuleContentsProvider {
  static NotifierProvider<ModuleContentsNotifier, ModuleContentsState> state(Module collection) =>
      _moduleContentsNotifier(collection);
}
