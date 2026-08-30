// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final String title;
  final String? fontFamily;
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

  AppThemeExtension({
    required this.title,
    required this.fontFamily,
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

  @override
  AppThemeExtension lerp(covariant AppThemeExtension? other, double t) {
    return AppThemeExtension(
      title: title,
      fontFamily: fontFamily,
      brightness: brightness,
      primary: Color.lerp(primary, other?.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other?.secondary, t) ?? secondary,
      surface: Color.lerp(surface, other?.surface, t) ?? surface,
      onSurface: Color.lerp(onSurface, other?.onSurface, t) ?? onSurface,
      background: Color.lerp(background, other?.background, t) ?? background,
      onBackground:
          Color.lerp(onBackground, other?.onBackground, t) ?? onBackground,
      altBackgroundPrimary:
          Color.lerp(altBackgroundPrimary, other?.altBackgroundPrimary, t) ??
          altBackgroundPrimary,
      altBackgroundSecondary:
          Color.lerp(
            altBackgroundSecondary,
            other?.altBackgroundSecondary,
            t,
          ) ??
          altBackgroundSecondary,
      onPrimary: Color.lerp(onPrimary, other?.onPrimary, t) ?? onPrimary,
      onSecondary:
          Color.lerp(onSecondary, other?.onSecondary, t) ?? onSecondary,
      error: Color.lerp(error, other?.error, t) ?? error,
      onError: Color.lerp(onError, other?.onError, t) ?? onError,
      success: Color.lerp(success, other?.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other?.onSuccess, t) ?? onSuccess,
      outline: Color.lerp(outline, other?.outline, t) ?? outline,
      shadow: Color.lerp(shadow, other?.shadow, t) ?? shadow,
      inverseSurface:
          Color.lerp(inverseSurface, other?.inverseSurface, t) ??
          inverseSurface,
      onInverseSurface:
          Color.lerp(onInverseSurface, other?.onInverseSurface, t) ??
          onInverseSurface,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> copyWith({
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
    return AppThemeExtension(
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

  factory AppThemeExtension.fromAppTheme(AppTheme theme) {
    return AppThemeExtension(
      title: theme.title,
      fontFamily: theme.fontFamily,
      brightness: theme.brightness,
      primary: theme.primary,
      secondary: theme.secondary,
      surface: theme.surface,
      onSurface: theme.onSurface,
      background: theme.background,
      onBackground: theme.onBackground,
      altBackgroundPrimary: theme.altBackgroundPrimary,
      altBackgroundSecondary: theme.altBackgroundSecondary,
      onPrimary: theme.onPrimary,
      onSecondary: theme.onSecondary,
      error: theme.error,
      onError: theme.onError,
      success: theme.success,
      onSuccess: theme.onSuccess,
      outline: theme.outline,
      shadow: theme.shadow,
      inverseSurface: theme.inverseSurface,
      onInverseSurface: theme.onInverseSurface,
    );
  }
}

extension ExtAppThemeExtension on AppThemeExtension {
  // Supporting text color - lighter version of onSurface for subtitles, captions, etc.
  Color get supportingText => brightness == Brightness.light
      ? onSurface.withValues(alpha: 0.6)
      : onSurface.withValues(alpha: 0.7);

  // Supporting text that works on altBackground surfaces
  Color get backgroundSupportingText => brightness == Brightness.light
      ? onSurface.withValues(alpha: 0.65)
      : onSurface.withValues(alpha: 0.75);

  // Remapped getters with appropriate names
  Color get primaryColor => primary;
  Color get secondaryColor => secondary;
  Color get cardColor => surface;
  Color get onCardColor => onSurface;
  Color get backgroundColor => background;
  Color get onBackgroundColor => onBackground;
  Color get scaffoldBackgroundColor => altBackgroundPrimary;
  Color get onScaffoldBackgroundColor => onSurface;
  Color get surfaceColor => surface;
  Color get onSurfaceColor => onSurface;
  Color get altSurfaceColor => altBackgroundSecondary;
  Color get onAltSurfaceColor => onSurface;
  Color get onPrimaryColor => onPrimary;
  Color get onSecondaryColor => onSecondary;
  Color get errorColor => error;
  Color get onErrorColor => onError;
  Color get successColor => success;
  Color get onSuccessColor => onSuccess;
  Color get outlineColor => outline;
  Color get shadowColor => shadow;
  Color get inverseSurfaceColor => inverseSurface;
  Color get onInverseSurfaceColor => onInverseSurface;

  bool get isDarkTheme => brightness == Brightness.dark;
  bool get isDarkMode => brightness == Brightness.dark;

  Color get adjustBgAndPrimaryWithLerp => isDarkTheme
      ? Color.lerp(
          primary.withAlpha(100),
          background,
          0.85,
        )!.withValues(alpha: primary.a)
      : background.lightenColor(0.9);
  Color get adjustBgAndPrimaryWithLerpExtra => isDarkTheme
      ? Color.lerp(
          primary.withAlpha(100),
          background,
          0.82,
        )!.withValues(alpha: primary.a)
      : background.lightenColor(0.85);

  Color get adjustBgAndSecondaryWithLerp => isDarkTheme
      ? Color.lerp(
          secondary.withAlpha(100),
          background,
          0.85,
        )!.withValues(alpha: secondary.a)
      : background.lightenColor(0.9);
  Color get adjustBgAndSecondaryWithLerpExtra => isDarkTheme
      ? Color.lerp(
          secondary.withAlpha(100),
          background,
          0.82,
        )!.withValues(alpha: secondary.a)
      : background.lightenColor(0.85);

  List<Color> get backgroundGradientColors {
    if (brightness == Brightness.dark) {
      return [
        primary.withValues(alpha: 0.15),
        secondary.withValues(alpha: 0.08),
        background,
      ];
    } else {
      return [
        primary.withValues(alpha: 0.12),
        secondary.withValues(alpha: 0.06),
        background,
      ];
    }
  }

  LinearGradient get accentGradient {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withValues(alpha: 0.85),
          secondary.withValues(alpha: 0.75),
          primary.withValues(alpha: 0.65),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withValues(alpha: 0.90),
          secondary.withValues(alpha: 0.80),
          primary.withValues(alpha: 0.70),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }
}
