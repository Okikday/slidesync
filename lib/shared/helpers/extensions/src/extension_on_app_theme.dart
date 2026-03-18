part of '../extensions.dart';

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
  Color get error => watch(appThemeProvider.select((p) => p.error));
  Color get onError => watch(appThemeProvider.select((p) => p.onError));
  Color get success => watch(appThemeProvider.select((p) => p.success));
  Color get onSuccess => watch(appThemeProvider.select((p) => p.onSuccess));
  Color get outline => watch(appThemeProvider.select((p) => p.outline));
  Color get shadow => watch(appThemeProvider.select((p) => p.shadow));
  Color get inverseSurface => watch(appThemeProvider.select((p) => p.inverseSurface));
  Color get onInverseSurface => watch(appThemeProvider.select((p) => p.onInverseSurface));

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
  Color get errorColor => watch(appThemeProvider.select((p) => p.errorColor));
  Color get onErrorColor => watch(appThemeProvider.select((p) => p.onErrorColor));
  Color get successColor => watch(appThemeProvider.select((p) => p.successColor));
  Color get onSuccessColor => watch(appThemeProvider.select((p) => p.onSuccessColor));
  Color get outlineColor => watch(appThemeProvider.select((p) => p.outlineColor));
  Color get shadowColor => watch(appThemeProvider.select((p) => p.shadowColor));
  Color get inverseSurfaceColor => watch(appThemeProvider.select((p) => p.inverseSurfaceColor));
  Color get onInverseSurfaceColor => watch(appThemeProvider.select((p) => p.onInverseSurfaceColor));

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
