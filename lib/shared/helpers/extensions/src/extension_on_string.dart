part of '../extensions.dart';

extension StringExtension on String {
  Map get decodeJson => jsonDecode(this);
}