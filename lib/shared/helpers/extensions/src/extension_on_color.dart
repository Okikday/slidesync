part of '../extensions.dart';

extension ColorsExtension on Color {
  Color lightenColor([double? value]) => HSLColor.fromColor(this).withLightness((value ?? 0.9)).toColor();
}
