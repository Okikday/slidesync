import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/shared/global/notifiers/toggle_notifier.dart';

class PdfDocViewerProviders {
  static final AsyncNotifierProvider<ToggleNotifier, bool> ispdfViewerInDarkModeNotifier =
      AsyncNotifierProvider<ToggleNotifier, bool>(() => ToggleNotifier(HiveDataPathKey.ispdfViewerInDarkMode.name));
}
