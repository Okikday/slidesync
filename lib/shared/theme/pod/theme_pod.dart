import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/src/custom_notifiers.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/shared/theme/src/built_in_themes.dart';
import 'package:slidesync/shared/theme/theme.dart';

import 'theme_state.dart';

final _themePod = NotifierProvider(
  ThemePod.new,
  dependencies: [_themeNotifier],
);

class ThemePod extends Notifier<ThemeState> {
  static NotifierProvider<ThemePod, ThemeState> get me => _themePod;
  @override
  ThemeState build() {
    final theme = ref.watch(_themeNotifier);
    return theme.value ??
        ThemeState(
          theme: defaultUnifiedThemeModels.first,
          useSystemBrightness: true,
        );
  }

  void setTheme(UnifiedThemeModel newTheme) {
    state = state.copyWith(theme: newTheme);
    ref.read(_themeNotifier.notifier).set(state);
  }

  void setUseSystemBrightness(bool useSystemBrightness) {
    state = state.copyWith(useSystemBrightness: useSystemBrightness);
    ref.read(_themeNotifier.notifier).set(state);
  }
}

final _themeNotifier = AsyncNotifierProvider(
  () => KCachedNotifier<Map, ThemeState>(
    HiveDataKey.appTheme.name,
    ThemeState(
      useSystemBrightness: false,
      theme: defaultUnifiedThemeModels.first,
    ),
    encode: (raw) => raw.toMap(),
    decode: (data) => data == null
        ? ThemeState(
            useSystemBrightness: false,
            theme: defaultUnifiedThemeModels.first,
          )
        : ThemeState.fromMap(Map.castFrom(data)),
  ),
);
