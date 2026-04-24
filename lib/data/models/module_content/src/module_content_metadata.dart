import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';

part 'module_content_metadata.mapper.dart';
part 'module_content_metadata.g.dart';

@MappableClass()
@Embedded(ignore: {'copyWith'})
class ModuleContentMetadata with ModuleContentMetadataMappable {
  String? originalFileName;
  FilePath? thumbnail;

  @Enumerated(EnumType.name)
  ContentOrigin contentOrigin;
  String? groupId;
  String? author;
  String? rawFieldsJson;

  ModuleContentMetadata({
    this.originalFileName,
    this.thumbnail,
    this.contentOrigin = ContentOrigin.none,
    this.groupId,
    this.author,
    this.rawFieldsJson,
  });

  static const fromJson = ModuleContentMetadataMapper.fromJson;
  static const fromMap = ModuleContentMetadataMapper.fromMap;
  factory ModuleContentMetadata.empty() => ModuleContentMetadata();

  static ModuleContentMetadata create({
    String? originalFileName,
    FilePath? thumbnail,
    ContentOrigin contentOrigin = ContentOrigin.none,
    String? groupId,
    String? author,
    Map<String, dynamic>? fields,
  }) {
    return ModuleContentMetadata(
      originalFileName: originalFileName,
      thumbnail: thumbnail,
      contentOrigin: contentOrigin,
      groupId: groupId,
      author: author,
      rawFieldsJson: fields != null ? jsonEncode(fields) : null,
    );
  }
}

extension ModuleContentMetadataExtension on ModuleContentMetadata {
  Map<String, dynamic>? get fields {
    if (rawFieldsJson == null || rawFieldsJson!.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawFieldsJson!);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  ModuleContentMetadata withFields(Map<String, dynamic>? value) {
    final encoded = (value == null || value.isEmpty) ? null : jsonEncode(value);
    return copyWith(rawFieldsJson: encoded);
  }
}
