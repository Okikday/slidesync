import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:slidesync/shared/theme/theme.dart';

class ThemeState extends Equatable {
  final bool useSystemBrightness;
  final UnifiedThemeModel theme;

  const ThemeState({required this.useSystemBrightness, required this.theme});

  ThemeData get lightTheme => resolveThemeData(theme.theme);
  ThemeData get darkTheme => resolveThemeData(theme.darkTheme);
  ThemeMode get themeMode => useSystemBrightness
      ? .system
      : (theme.currentBrightness == .light ? .light : .dark);

  ThemeState copyWith({bool? useSystemBrightness, UnifiedThemeModel? theme}) {
    return ThemeState(
      useSystemBrightness: useSystemBrightness ?? this.useSystemBrightness,
      theme: theme ?? this.theme,
    );
  }

  @override
  List<Object> get props => [useSystemBrightness, theme];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'useSystemBrightness': useSystemBrightness,
      'theme': theme.toMap(),
    };
  }

  factory ThemeState.fromMap(Map<String, dynamic> map) {
    return ThemeState(
      useSystemBrightness: map['useSystemBrightness'] as bool,
      theme: UnifiedThemeModel.fromMap(map['theme'] as Map<String, dynamic>),
    );
  }
}
