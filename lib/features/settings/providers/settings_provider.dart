import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/settings/logic/models/settings_model.dart';
import 'package:slidesync/features/settings/providers/settings_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _settingsProvider = AsyncNotifierProvider.autoDispose(
  () => HiveAsyncImpliedNotifier<Map, SettingsModel>(
    HiveDataPathKey.isBuiltInViewer.name,
    const SettingsModel(),
    isUpdateNotifying: true,
    transformer: (p0) => p0.toMap(),
    builder: (data) => data == null ? const SettingsModel() : SettingsModel.fromMap(Map.castFrom(data)),
  ),
);

class SettingsProvider {
  static final settingsProvider = _settingsProvider;

  static final state = NotifierProvider<SettingsRevealNotifier, SettingsRevealState>(
    SettingsRevealNotifier.new,
    isAutoDispose: true,
  );
}

extension SettingsModelExtension on WidgetRef {
  Future<SettingsModel> get readSettings async => await read(_settingsProvider.future);
}
