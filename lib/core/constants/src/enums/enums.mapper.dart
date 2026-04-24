// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'enums.dart';

class ContentOriginMapper extends EnumMapper<ContentOrigin> {
  ContentOriginMapper._();

  static ContentOriginMapper? _instance;
  static ContentOriginMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContentOriginMapper._());
    }
    return _instance!;
  }

  static ContentOrigin fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ContentOrigin decode(dynamic value) {
    switch (value) {
      case r'none':
        return ContentOrigin.none;
      case r'local':
        return ContentOrigin.local;
      case r'server':
        return ContentOrigin.server;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ContentOrigin self) {
    switch (self) {
      case ContentOrigin.none:
        return r'none';
      case ContentOrigin.local:
        return r'local';
      case ContentOrigin.server:
        return r'server';
    }
  }
}

extension ContentOriginMapperExtension on ContentOrigin {
  String toValue() {
    ContentOriginMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ContentOrigin>(this) as String;
  }
}

