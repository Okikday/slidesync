import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/settings/logic/models/settings_model.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _settingsProvider =
    AsyncNotifierProvider.autoDispose<AsyncImpliedNotifier<Map<String, dynamic>>, Map<String, dynamic>>(
      () => AsyncImpliedNotifier<Map<String, dynamic>>(
        HiveDataPathKey.isBuiltInViewer.name,
        SettingsModel().toMap(),
        true,
        (data) {
          if (data == null) return SettingsModel().toMap();
          final newData = Map<String, dynamic>.from(data);
          return newData;
        },
      ),
    );

class SettingsController {
  static AsyncNotifierProvider<AsyncImpliedNotifier<Map<String, dynamic>>, Map<String, dynamic>> get settingsProvider =>
      _settingsProvider;
}

extension SettingsModelExtension on WidgetRef {
  Future<SettingsModel> get readSettings async => SettingsModel.fromMap((await read(_settingsProvider.future)));
}
