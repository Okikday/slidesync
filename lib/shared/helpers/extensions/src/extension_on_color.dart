part of '../extensions.dart';

extension ColorsExtension on Color {
  Color lightenColor([double? value]) =>
      HSLColor.fromColor(this).withLightness((value ?? 0.9)).toColor();
  Color blendColor(Color other, [double? value]) =>
      Color.lerp(this, other, value ?? 0.5) ?? this;
}
