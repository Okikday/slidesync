import 'dart:convert';

extension StringExtension on String {
  Map get decodeJson => jsonDecode(this);
}