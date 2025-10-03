import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/app.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';

extension AppProviderTheme on WidgetRef {
  AppTheme get theme => watch(appThemeProvider);
  bool get isDarkMode => watch(appThemeProvider.select((p) => p.isDarkTheme));

  // Core colors
  Color get primary => watch(appThemeProvider.select((p) => p.primary));
  Color get secondary => watch(appThemeProvider.select((p) => p.secondary));
  Color get surface => watch(appThemeProvider.select((p) => p.surface));
  Color get onSurface => watch(appThemeProvider.select((p) => p.onSurface));
  Color get background => watch(appThemeProvider.select((p) => p.background));
  Color get onBackground => watch(appThemeProvider.select((p) => p.onBackground));
  Color get onPrimary => watch(appThemeProvider.select((p) => p.onPrimary));
  Color get onSecondary => watch(appThemeProvider.select((p) => p.onSecondary));

  // Alt background colors
  Color get altBackgroundPrimary => watch(appThemeProvider.select((p) => p.altBackgroundPrimary));
  Color get altBackgroundSecondary => watch(appThemeProvider.select((p) => p.altBackgroundSecondary));

  // Supporting text colors
  Color get supportingText => watch(appThemeProvider.select((p) => p.supportingText));
  Color get backgroundSupportingText => watch(appThemeProvider.select((p) => p.backgroundSupportingText));

  // Remapped getters
  Color get primaryColor => watch(appThemeProvider.select((p) => p.primaryColor));
  Color get secondaryColor => watch(appThemeProvider.select((p) => p.secondaryColor));
  Color get cardColor => watch(appThemeProvider.select((p) => p.cardColor));
  Color get onCardColor => watch(appThemeProvider.select((p) => p.onCardColor));
  Color get backgroundColor => watch(appThemeProvider.select((p) => p.backgroundColor));
  Color get onBackgroundColor => watch(appThemeProvider.select((p) => p.onBackgroundColor));
  Color get scaffoldBackgroundColor => watch(appThemeProvider.select((p) => p.scaffoldBackgroundColor));
  Color get onScaffoldBackgroundColor => watch(appThemeProvider.select((p) => p.onScaffoldBackgroundColor));
  Color get surfaceColor => watch(appThemeProvider.select((p) => p.surfaceColor));
  Color get onSurfaceColor => watch(appThemeProvider.select((p) => p.onSurfaceColor));
  Color get altSurfaceColor => watch(appThemeProvider.select((p) => p.altSurfaceColor));
  Color get onAltSurfaceColor => watch(appThemeProvider.select((p) => p.onAltSurfaceColor));
  Color get onPrimaryColor => watch(appThemeProvider.select((p) => p.onPrimaryColor));
  Color get onSecondaryColor => watch(appThemeProvider.select((p) => p.onSecondaryColor));

  // Computed colors
  Color get adjustBgAndPrimaryWithLerp => watch(appThemeProvider.select((p) => p.adjustBgAndPrimaryWithLerp));
  Color get adjustBgAndPrimaryWithLerpExtra => watch(appThemeProvider.select((p) => p.adjustBgAndPrimaryWithLerpExtra));
  Color get adjustBgAndSecondaryWithLerp => watch(appThemeProvider.select((p) => p.adjustBgAndSecondaryWithLerp));
  Color get adjustBgAndSecondaryWithLerpExtra =>
      watch(appThemeProvider.select((p) => p.adjustBgAndSecondaryWithLerpExtra));

  // Gradient colors
  List<Color> get backgroundGradientColors => watch(appThemeProvider.select((p) => p.backgroundGradientColors));

  // Theme properties
  String get themeTitle => watch(appThemeProvider.select((p) => p.title));
  String? get fontFamily => watch(appThemeProvider.select((p) => p.fontFamily));
  Brightness get brightness => watch(appThemeProvider.select((p) => p.brightness));
}
