import 'dart:convert';

extension MapExtension<T> on Map<T, T?> {
  String get encodeToJson => jsonEncode(this);
}
