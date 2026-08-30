import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// The unified theme that contains both light and dark variants
class UnifiedThemeModel extends Equatable {
  final AppTheme theme; // Light theme
  final AppTheme darkTheme; // Dark theme
  final Brightness currentBrightness;

  const UnifiedThemeModel({
    required this.theme,
    required this.darkTheme,
    required this.currentBrightness,
  });

  /// Returns the appropriate [AppTheme] based on [currentBrightness]
  AppTheme get currentTheme => currentBrightness == .dark ? darkTheme : theme;

  UnifiedThemeModel copyWith({
    AppTheme? theme,
    AppTheme? darkTheme,
    Brightness? currentBrightness,
  }) {
    return UnifiedThemeModel(
      theme: theme ?? this.theme,
      darkTheme: darkTheme ?? this.darkTheme,
      currentBrightness: currentBrightness ?? this.currentBrightness,
    );
  }

  @override
  List<Object> get props => [theme, darkTheme, currentBrightness];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'theme': theme.toMap(),
      'darkTheme': darkTheme.toMap(),
      'currentBrightness': currentBrightness.index,
    };
  }

  factory UnifiedThemeModel.fromMap(Map<String, dynamic> map) {
    return UnifiedThemeModel(
      theme: AppTheme.fromMap(map['theme'] as Map<String, dynamic>),
      darkTheme: AppTheme.fromMap(map['darkTheme'] as Map<String, dynamic>),
      currentBrightness: Brightness.values[map['currentBrightness'] as int],
    );
  }

  @override
  bool get stringify => true;
}

/// APPTHEME
class AppTheme extends Equatable {
  final String title;
  final String fontFamily;
  final Brightness brightness;

  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color altBackgroundPrimary;
  final Color altBackgroundSecondary;
  final Color onPrimary;
  final Color onSecondary;
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color outline;
  final Color shadow;
  final Color inverseSurface;
  final Color onInverseSurface;

  const AppTheme({
    required this.title,
    this.fontFamily = '',
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.altBackgroundPrimary,
    required this.altBackgroundSecondary,
    required this.onPrimary,
    required this.onSecondary,
    required this.error,
    required this.onError,
    required this.success,
    required this.onSuccess,
    required this.outline,
    required this.shadow,
    required this.inverseSurface,
    required this.onInverseSurface,
  });

  AppTheme copyWith({
    String? title,
    String? fontFamily,
    Brightness? brightness,
    Color? primary,
    Color? secondary,
    Color? surface,
    Color? onSurface,
    Color? background,
    Color? onBackground,
    Color? altBackgroundPrimary,
    Color? altBackgroundSecondary,
    Color? onPrimary,
    Color? onSecondary,
    Color? error,
    Color? onError,
    Color? success,
    Color? onSuccess,
    Color? outline,
    Color? shadow,
    Color? inverseSurface,
    Color? onInverseSurface,
  }) {
    return AppTheme(
      title: title ?? this.title,
      fontFamily: fontFamily ?? this.fontFamily,
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      altBackgroundPrimary: altBackgroundPrimary ?? this.altBackgroundPrimary,
      altBackgroundSecondary:
          altBackgroundSecondary ?? this.altBackgroundSecondary,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      outline: outline ?? this.outline,
      shadow: shadow ?? this.shadow,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
    );
  }

  @override
  String toString() {
    return 'AppTheme(title: $title, fontFamily: $fontFamily, brightness: $brightness, '
        'primary: $primary, secondary: $secondary, surface: $surface, '
        'onSurface: $onSurface, background: $background, onBackground: $onBackground, '
        'altBackgroundPrimary: $altBackgroundPrimary, altBackgroundSecondary: $altBackgroundSecondary, '
        'onPrimary: $onPrimary, onSecondary: $onSecondary, '
        'error: $error, onError: $onError, success: $success, onSuccess: $onSuccess, '
        'outline: $outline, shadow: $shadow, '
        'inverseSurface: $inverseSurface, onInverseSurface: $onInverseSurface)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'fontFamily': fontFamily,
      'brightness': brightness.index,
      'primary': primary.toARGB32(),
      'secondary': secondary.toARGB32(),
      'surface': surface.toARGB32(),
      'onSurface': onSurface.toARGB32(),
      'background': background.toARGB32(),
      'onBackground': onBackground.toARGB32(),
      'altBackgroundPrimary': altBackgroundPrimary.toARGB32(),
      'altBackgroundSecondary': altBackgroundSecondary.toARGB32(),
      'onPrimary': onPrimary.toARGB32(),
      'onSecondary': onSecondary.toARGB32(),
      'error': error.toARGB32(),
      'onError': onError.toARGB32(),
      'success': success.toARGB32(),
      'onSuccess': onSuccess.toARGB32(),
      'outline': outline.toARGB32(),
      'shadow': shadow.toARGB32(),
      'inverseSurface': inverseSurface.toARGB32(),
      'onInverseSurface': onInverseSurface.toARGB32(),
    };
  }

  factory AppTheme.fromMap(Map<String, dynamic> map) {
    return AppTheme(
      title: map['title'] as String,
      fontFamily: map['fontFamily'] as String,
      brightness: Brightness.values[map['brightness'] as int],
      primary: Color(map['primary'] as int),
      secondary: Color(map['secondary'] as int),
      surface: Color(map['surface'] as int),
      onSurface: Color(map['onSurface'] as int),
      background: Color(map['background'] as int),
      onBackground: Color(map['onBackground'] as int),
      altBackgroundPrimary: Color(map['altBackgroundPrimary'] as int),
      altBackgroundSecondary: Color(map['altBackgroundSecondary'] as int),
      onPrimary: Color(map['onPrimary'] as int),
      onSecondary: Color(map['onSecondary'] as int),
      error: Color(map['error'] as int),
      onError: Color(map['onError'] as int),
      success: Color(map['success'] as int),
      onSuccess: Color(map['onSuccess'] as int),
      outline: Color(map['outline'] as int),
      shadow: Color(map['shadow'] as int),
      inverseSurface: Color(map['inverseSurface'] as int),
      onInverseSurface: Color(map['onInverseSurface'] as int),
    );
  }

  @override
  List<Object> get props {
    return [
      title,
      fontFamily,
      brightness,
      primary,
      secondary,
      surface,
      onSurface,
      background,
      onBackground,
      altBackgroundPrimary,
      altBackgroundSecondary,
      onPrimary,
      onSecondary,
      error,
      onError,
      success,
      onSuccess,
      outline,
      shadow,
      inverseSurface,
      onInverseSurface,
    ];
  }

  // Supporting text color - lighter version of onSurface for subtitles, captions, etc.
  Color get supportingText => brightness == Brightness.light
      ? onSurface.withValues(alpha: 0.6)
      : onSurface.withValues(alpha: 0.7);

  // // Supporting text that works on altBackground surfaces
  // Color get backgroundSupportingText => brightness == Brightness.light
  //     ? onSurface.withValues(alpha: 0.65)
  //     : onSurface.withValues(alpha: 0.75);

  // // Remapped getters with appropriate names
  // Color get primaryColor => primary;
  // Color get secondaryColor => secondary;
  // Color get cardColor => surface;
  // Color get onCardColor => onSurface;
  // Color get backgroundColor => background;
  // Color get onBackgroundColor => onBackground;
  // Color get scaffoldBackgroundColor => altBackgroundPrimary;
  // Color get onScaffoldBackgroundColor => onSurface;
  // Color get surfaceColor => surface;
  // Color get onSurfaceColor => onSurface;
  // Color get altSurfaceColor => altBackgroundSecondary;
  // Color get onAltSurfaceColor => onSurface;
  // Color get onPrimaryColor => onPrimary;
  // Color get onSecondaryColor => onSecondary;
  // Color get errorColor => error;
  // Color get onErrorColor => onError;
  // Color get successColor => success;
  // Color get onSuccessColor => onSuccess;
  // Color get outlineColor => outline;
  // Color get shadowColor => shadow;
  // Color get inverseSurfaceColor => inverseSurface;
  // Color get onInverseSurfaceColor => onInverseSurface;

  // bool get isDarkTheme => brightness == Brightness.dark;

  // Color get adjustBgAndPrimaryWithLerp => isDarkTheme
  //     ? Color.lerp(
  //         primary.withAlpha(100),
  //         background,
  //         0.85,
  //       )!.withValues(alpha: primary.a)
  //     : background.lightenColor(0.9);
  // Color get adjustBgAndPrimaryWithLerpExtra => isDarkTheme
  //     ? Color.lerp(
  //         primary.withAlpha(100),
  //         background,
  //         0.82,
  //       )!.withValues(alpha: primary.a)
  //     : background.lightenColor(0.85);

  // Color get adjustBgAndSecondaryWithLerp => isDarkTheme
  //     ? Color.lerp(
  //         secondary.withAlpha(100),
  //         background,
  //         0.85,
  //       )!.withValues(alpha: secondary.a)
  //     : background.lightenColor(0.9);
  // Color get adjustBgAndSecondaryWithLerpExtra => isDarkTheme
  //     ? Color.lerp(
  //         secondary.withAlpha(100),
  //         background,
  //         0.82,
  //       )!.withValues(alpha: secondary.a)
  //     : background.lightenColor(0.85);

  // List<Color> get backgroundGradientColors {
  //   if (brightness == Brightness.dark) {
  //     return [
  //       primary.withValues(alpha: 0.15),
  //       secondary.withValues(alpha: 0.08),
  //       background,
  //     ];
  //   } else {
  //     return [
  //       primary.withValues(alpha: 0.12),
  //       secondary.withValues(alpha: 0.06),
  //       background,
  //     ];
  //   }
  // }

  // LinearGradient get accentGradient {
  //   if (brightness == Brightness.dark) {
  //     return LinearGradient(
  //       begin: Alignment.topLeft,
  //       end: Alignment.bottomRight,
  //       colors: [
  //         primary.withValues(alpha: 0.85),
  //         secondary.withValues(alpha: 0.75),
  //         primary.withValues(alpha: 0.65),
  //       ],
  //       stops: const [0.0, 0.5, 1.0],
  //     );
  //   } else {
  //     return LinearGradient(
  //       begin: Alignment.topLeft,
  //       end: Alignment.bottomRight,
  //       colors: [
  //         primary.withValues(alpha: 0.90),
  //         secondary.withValues(alpha: 0.80),
  //         primary.withValues(alpha: 0.70),
  //       ],
  //       stops: const [0.0, 0.5, 1.0],
  //     );
  //   }
  // }
}
