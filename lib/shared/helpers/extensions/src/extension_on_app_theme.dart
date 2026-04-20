part of '../extensions.dart';

extension AppProviderTheme on WidgetRef {
  static final _p = appThemeProvider;
  AppTheme get theme => watch(_p.select((s) => s.currentTheme));
  bool get isDarkMode => watch(_p.select((p) => p.currentBrightness == Brightness.dark));

  // Core colors
  Color get primary => watch(_p.select((p) => p.currentTheme.primary));
  Color get secondary => watch(_p.select((p) => p.currentTheme.secondary));
  Color get surface => watch(_p.select((p) => p.currentTheme.surface));
  Color get onSurface => watch(_p.select((p) => p.currentTheme.onSurface));
  Color get background => watch(_p.select((p) => p.currentTheme.background));
  Color get onBackground => watch(_p.select((p) => p.currentTheme.onBackground));
  Color get onPrimary => watch(_p.select((p) => p.currentTheme.onPrimary));
  Color get onSecondary => watch(_p.select((p) => p.currentTheme.onSecondary));
  Color get error => watch(_p.select((p) => p.currentTheme.error));
  Color get onError => watch(_p.select((p) => p.currentTheme.onError));
  Color get success => watch(_p.select((p) => p.currentTheme.success));
  Color get onSuccess => watch(_p.select((p) => p.currentTheme.onSuccess));
  Color get outline => watch(_p.select((p) => p.currentTheme.outline));
  Color get shadow => watch(_p.select((p) => p.currentTheme.shadow));
  Color get inverseSurface => watch(_p.select((p) => p.currentTheme.inverseSurface));
  Color get onInverseSurface => watch(_p.select((p) => p.currentTheme.onInverseSurface));

  // Alt background colors
  Color get altBackgroundPrimary => watch(_p.select((p) => p.currentTheme.altBackgroundPrimary));
  Color get altBackgroundSecondary => watch(_p.select((p) => p.currentTheme.altBackgroundSecondary));

  // Supporting text colors
  Color get supportingText => watch(_p.select((p) => p.currentTheme.supportingText));
  Color get backgroundSupportingText => watch(_p.select((p) => p.currentTheme.backgroundSupportingText));

  // Remapped getters
  Color get primaryColor => watch(_p.select((p) => p.currentTheme.primaryColor));
  Color get secondaryColor => watch(_p.select((p) => p.currentTheme.secondaryColor));
  Color get cardColor => watch(_p.select((p) => p.currentTheme.cardColor));
  Color get onCardColor => watch(_p.select((p) => p.currentTheme.onCardColor));
  Color get backgroundColor => watch(_p.select((p) => p.currentTheme.backgroundColor));
  Color get onBackgroundColor => watch(_p.select((p) => p.currentTheme.onBackgroundColor));
  Color get scaffoldBackgroundColor => watch(_p.select((p) => p.currentTheme.scaffoldBackgroundColor));
  Color get onScaffoldBackgroundColor => watch(_p.select((p) => p.currentTheme.onScaffoldBackgroundColor));
  Color get surfaceColor => watch(_p.select((p) => p.currentTheme.surfaceColor));
  Color get onSurfaceColor => watch(_p.select((p) => p.currentTheme.onSurfaceColor));
  Color get altSurfaceColor => watch(_p.select((p) => p.currentTheme.altSurfaceColor));
  Color get onAltSurfaceColor => watch(_p.select((p) => p.currentTheme.onAltSurfaceColor));
  Color get onPrimaryColor => watch(_p.select((p) => p.currentTheme.onPrimaryColor));
  Color get onSecondaryColor => watch(_p.select((p) => p.currentTheme.onSecondaryColor));
  Color get errorColor => watch(_p.select((p) => p.currentTheme.errorColor));
  Color get onErrorColor => watch(_p.select((p) => p.currentTheme.onErrorColor));
  Color get successColor => watch(_p.select((p) => p.currentTheme.successColor));
  Color get onSuccessColor => watch(_p.select((p) => p.currentTheme.onSuccessColor));
  Color get outlineColor => watch(_p.select((p) => p.currentTheme.outlineColor));
  Color get shadowColor => watch(_p.select((p) => p.currentTheme.shadowColor));
  Color get inverseSurfaceColor => watch(_p.select((p) => p.currentTheme.inverseSurfaceColor));
  Color get onInverseSurfaceColor => watch(_p.select((p) => p.currentTheme.onInverseSurfaceColor));

  // Computed colors
  Color get adjustBgAndPrimaryWithLerp => watch(_p.select((p) => p.currentTheme.adjustBgAndPrimaryWithLerp));
  Color get adjustBgAndPrimaryWithLerpExtra => watch(_p.select((p) => p.currentTheme.adjustBgAndPrimaryWithLerpExtra));
  Color get adjustBgAndSecondaryWithLerp => watch(_p.select((p) => p.currentTheme.adjustBgAndSecondaryWithLerp));
  Color get adjustBgAndSecondaryWithLerpExtra =>
      watch(_p.select((p) => p.currentTheme.adjustBgAndSecondaryWithLerpExtra));

  // Gradient colors
  List<Color> get backgroundGradientColors => watch(_p.select((p) => p.currentTheme.backgroundGradientColors));

  // Theme properties
  String get themeTitle => watch(_p.select((p) => p.title));
  String? get fontFamily => watch(_p.select((p) => p.fontFamily));
  Brightness get brightness => watch(_p.select((p) => p.currentTheme.brightness));
}
