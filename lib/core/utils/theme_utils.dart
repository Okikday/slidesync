import 'package:flutter/widgets.dart';

class ThemeUtils {
  /// Converts a [Color] to a hexadecimal string, e.g. Color(0xFF123456) -> "#FF123456".
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Converts a hexadecimal string to [Color], supports formats "#RRGGBB" and "#AARRGGBB".
  static Color hexToColor(String hex) {
    try {
      var cleanHex = hex.startsWith('#') ? hex.substring(1) : hex;
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      if (cleanHex.length != 8) return const Color(0x00000000);
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0x00000000);
    }
  }
}

extension ThemeUtilsExtension1 on Color {
  String get toHexColor => ThemeUtils.colorToHex(this);
}

extension ThemeUtilsExtension2 on String {
  Color get toColor => ThemeUtils.hexToColor(this);
}
