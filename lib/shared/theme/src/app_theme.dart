// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/theme.dart';

// The unified theme that contains both light and dark variants
class UnifiedThemeModel {
  final String title;
  final String? fontFamily;

  // Light theme colors
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

  // Dark theme colors
  final Color primaryDark;
  final Color secondaryDark;
  final Color surfaceDark;
  final Color onSurfaceDark;
  final Color backgroundDark;
  final Color onBackgroundDark;
  final Color altBackgroundPrimaryDark;
  final Color altBackgroundSecondaryDark;
  final Color onPrimaryDark;
  final Color onSecondaryDark;

  const UnifiedThemeModel({
    // Light theme
    // Dark theme
    required this.title,
    this.fontFamily,
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
    required this.primaryDark,
    required this.secondaryDark,
    required this.surfaceDark,
    required this.onSurfaceDark,
    required this.backgroundDark,
    required this.onBackgroundDark,
    required this.altBackgroundPrimaryDark,
    required this.altBackgroundSecondaryDark,
    required this.onPrimaryDark,
    required this.onSecondaryDark,
  });

  UnifiedThemeModel copyWith({
    String? title,
    String? fontFamily,
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
    Color? primaryDark,
    Color? secondaryDark,
    Color? surfaceDark,
    Color? onSurfaceDark,
    Color? backgroundDark,
    Color? onBackgroundDark,
    Color? altBackgroundPrimaryDark,
    Color? altBackgroundSecondaryDark,
    Color? onPrimaryDark,
    Color? onSecondaryDark,
  }) {
    return UnifiedThemeModel(
      title: title ?? this.title,
      fontFamily: fontFamily ?? this.fontFamily,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      altBackgroundPrimary: altBackgroundPrimary ?? this.altBackgroundPrimary,
      altBackgroundSecondary: altBackgroundSecondary ?? this.altBackgroundSecondary,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      onSurfaceDark: onSurfaceDark ?? this.onSurfaceDark,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      onBackgroundDark: onBackgroundDark ?? this.onBackgroundDark,
      altBackgroundPrimaryDark: altBackgroundPrimaryDark ?? this.altBackgroundPrimaryDark,
      altBackgroundSecondaryDark: altBackgroundSecondaryDark ?? this.altBackgroundSecondaryDark,
      onPrimaryDark: onPrimaryDark ?? this.onPrimaryDark,
      onSecondaryDark: onSecondaryDark ?? this.onSecondaryDark,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'fontFamily': fontFamily,
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
      'primaryDark': primaryDark.toARGB32(),
      'secondaryDark': secondaryDark.toARGB32(),
      'surfaceDark': surfaceDark.toARGB32(),
      'onSurfaceDark': onSurfaceDark.toARGB32(),
      'backgroundDark': backgroundDark.toARGB32(),
      'onBackgroundDark': onBackgroundDark.toARGB32(),
      'altBackgroundPrimaryDark': altBackgroundPrimaryDark.toARGB32(),
      'altBackgroundSecondaryDark': altBackgroundSecondaryDark.toARGB32(),
      'onPrimaryDark': onPrimaryDark.toARGB32(),
      'onSecondaryDark': onSecondaryDark.toARGB32(),
    };
  }

  factory UnifiedThemeModel.fromMap(Map<String, dynamic> map) {
    return UnifiedThemeModel(
      title: map['title'] as String,
      fontFamily: map['fontFamily'] != null ? map['fontFamily'] as String : null,
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
      primaryDark: Color(map['primaryDark'] as int),
      secondaryDark: Color(map['secondaryDark'] as int),
      surfaceDark: Color(map['surfaceDark'] as int),
      onSurfaceDark: Color(map['onSurfaceDark'] as int),
      backgroundDark: Color(map['backgroundDark'] as int),
      onBackgroundDark: Color(map['onBackgroundDark'] as int),
      altBackgroundPrimaryDark: Color(map['altBackgroundPrimaryDark'] as int),
      altBackgroundSecondaryDark: Color(map['altBackgroundSecondaryDark'] as int),
      onPrimaryDark: Color(map['onPrimaryDark'] as int),
      onSecondaryDark: Color(map['onSecondaryDark'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UnifiedThemeModel.fromJson(String source) =>
      UnifiedThemeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UnifiedThemeModel(title: $title, fontFamily: $fontFamily, primary: $primary, secondary: $secondary, surface: $surface, onSurface: $onSurface, background: $background, onBackground: $onBackground, altBackgroundPrimary: $altBackgroundPrimary, altBackgroundSecondary: $altBackgroundSecondary, onPrimary: $onPrimary, onSecondary: $onSecondary, primaryDark: $primaryDark, secondaryDark: $secondaryDark, surfaceDark: $surfaceDark, onSurfaceDark: $onSurfaceDark, backgroundDark: $backgroundDark, onBackgroundDark: $onBackgroundDark, altBackgroundPrimaryDark: $altBackgroundPrimaryDark, altBackgroundSecondaryDark: $altBackgroundSecondaryDark, onPrimaryDark: $onPrimaryDark, onSecondaryDark: $onSecondaryDark)';
  }

  @override
  bool operator ==(covariant UnifiedThemeModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.fontFamily == fontFamily &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.surface == surface &&
        other.onSurface == onSurface &&
        other.background == background &&
        other.onBackground == onBackground &&
        other.altBackgroundPrimary == altBackgroundPrimary &&
        other.altBackgroundSecondary == altBackgroundSecondary &&
        other.onPrimary == onPrimary &&
        other.onSecondary == onSecondary &&
        other.primaryDark == primaryDark &&
        other.secondaryDark == secondaryDark &&
        other.surfaceDark == surfaceDark &&
        other.onSurfaceDark == onSurfaceDark &&
        other.backgroundDark == backgroundDark &&
        other.onBackgroundDark == onBackgroundDark &&
        other.altBackgroundPrimaryDark == altBackgroundPrimaryDark &&
        other.altBackgroundSecondaryDark == altBackgroundSecondaryDark &&
        other.onPrimaryDark == onPrimaryDark &&
        other.onSecondaryDark == onSecondaryDark;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        fontFamily.hashCode ^
        primary.hashCode ^
        secondary.hashCode ^
        surface.hashCode ^
        onSurface.hashCode ^
        background.hashCode ^
        onBackground.hashCode ^
        altBackgroundPrimary.hashCode ^
        altBackgroundSecondary.hashCode ^
        onPrimary.hashCode ^
        onSecondary.hashCode ^
        primaryDark.hashCode ^
        secondaryDark.hashCode ^
        surfaceDark.hashCode ^
        onSurfaceDark.hashCode ^
        backgroundDark.hashCode ^
        onBackgroundDark.hashCode ^
        altBackgroundPrimaryDark.hashCode ^
        altBackgroundSecondaryDark.hashCode ^
        onPrimaryDark.hashCode ^
        onSecondaryDark.hashCode;
  }
}

class AppTheme {
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

  const AppTheme({
    required this.title,
    this.fontFamily,
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
  });

  // Factory constructor to resolve from UnifiedThemeModel
  factory AppTheme.of(UnifiedThemeModel unified, Brightness brightness) {
    if (brightness == Brightness.light) {
      return AppTheme(
        title: unified.title,
        fontFamily: unified.fontFamily,
        brightness: brightness,
        primary: unified.primary,
        secondary: unified.secondary,
        surface: unified.surface,
        onSurface: unified.onSurface,
        background: unified.background,
        onBackground: unified.onBackground,
        altBackgroundPrimary: unified.altBackgroundPrimary,
        altBackgroundSecondary: unified.altBackgroundSecondary,
        onPrimary: unified.onPrimary,
        onSecondary: unified.onSecondary,
      );
    } else {
      return AppTheme(
        title: unified.title,
        fontFamily: unified.fontFamily,
        brightness: brightness,
        primary: unified.primaryDark,
        secondary: unified.secondaryDark,
        surface: unified.surfaceDark,
        onSurface: unified.onSurfaceDark,
        background: unified.backgroundDark,
        onBackground: unified.onBackgroundDark,
        altBackgroundPrimary: unified.altBackgroundPrimaryDark,
        altBackgroundSecondary: unified.altBackgroundSecondaryDark,
        onPrimary: unified.onPrimaryDark,
        onSecondary: unified.onSecondaryDark,
      );
    }
  }

  ThemeData get themeData => resolveThemeData(this);
  // Supporting text color - lighter version of onSurface for subtitles, captions, etc.
  Color get supportingText =>
      brightness == Brightness.light ? onSurface.withValues(alpha: 0.6) : onSurface.withValues(alpha: 0.7);

  // Supporting text that works on altBackground surfaces
  Color get backgroundSupportingText =>
      brightness == Brightness.light ? onSurface.withValues(alpha: 0.65) : onSurface.withValues(alpha: 0.75);

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

  bool get isDarkTheme => brightness == Brightness.dark;

  Color get adjustBgAndPrimaryWithLerp => isDarkTheme
      ? Color.lerp(primary.withAlpha(100), background, 0.85)!.withValues(alpha: primary.a)
      : background.lightenColor(0.9);
  Color get adjustBgAndPrimaryWithLerpExtra => isDarkTheme
      ? Color.lerp(primary.withAlpha(100), background, 0.82)!.withValues(alpha: primary.a)
      : background.lightenColor(0.85);

  Color get adjustBgAndSecondaryWithLerp => isDarkTheme
      ? Color.lerp(secondary.withAlpha(100), background, 0.85)!.withValues(alpha: secondary.a)
      : background.lightenColor(0.9);
  Color get adjustBgAndSecondaryWithLerpExtra => isDarkTheme
      ? Color.lerp(secondary.withAlpha(100), background, 0.82)!.withValues(alpha: secondary.a)
      : background.lightenColor(0.85);

  List<Color> get backgroundGradientColors {
    if (brightness == Brightness.dark) {
      return [primary.withValues(alpha: 0.15), secondary.withValues(alpha: 0.08), background];
    } else {
      return [primary.withValues(alpha: 0.12), secondary.withValues(alpha: 0.06), background];
    }
  }

  LinearGradient get accentGradient {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary.withValues(alpha: 0.85), secondary.withValues(alpha: 0.75), primary.withValues(alpha: 0.65)],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary.withValues(alpha: 0.90), secondary.withValues(alpha: 0.80), primary.withValues(alpha: 0.70)],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }

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
      altBackgroundSecondary: altBackgroundSecondary ?? this.altBackgroundSecondary,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
    );
  }

  @override
  bool operator ==(covariant AppTheme other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.fontFamily == fontFamily &&
        other.brightness == brightness &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.surface == surface &&
        other.onSurface == onSurface &&
        other.background == background &&
        other.onBackground == onBackground &&
        other.altBackgroundPrimary == altBackgroundPrimary &&
        other.altBackgroundSecondary == altBackgroundSecondary &&
        other.onPrimary == onPrimary &&
        other.onSecondary == onSecondary;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        fontFamily.hashCode ^
        brightness.hashCode ^
        primary.hashCode ^
        secondary.hashCode ^
        surface.hashCode ^
        onSurface.hashCode ^
        background.hashCode ^
        onBackground.hashCode ^
        altBackgroundPrimary.hashCode ^
        altBackgroundSecondary.hashCode ^
        onPrimary.hashCode ^
        onSecondary.hashCode;
  }

  @override
  String toString() {
    return 'AppTheme(title: $title, fontFamily: $fontFamily, brightness: $brightness, primary: $primary, secondary: $secondary, surface: $surface, onSurface: $onSurface, background: $background, onBackground: $onBackground, altBackgroundPrimary: $altBackgroundPrimary, altBackgroundSecondary: $altBackgroundSecondary, onPrimary: $onPrimary, onSecondary: $onSecondary)';
  }
}
