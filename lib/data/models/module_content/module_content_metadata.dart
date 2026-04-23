import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/file_path.dart';

part 'module_content_metadata.g.dart';

@embedded
class ModuleContentMetadata {
  String? originalFileName;
  FilePath? thumbnail;

  @Enumerated(EnumType.ordinal)
  ContentOrigin contentOrigin = ContentOrigin.none;
  String? groupId;
  String? author;
  String? rawFieldsJson;

  @ignore
  Map<String, dynamic>? get fields {
    if (rawFieldsJson == null || rawFieldsJson!.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawFieldsJson!);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  ModuleContentMetadata();

  factory ModuleContentMetadata.create({
    String? originalFileName,
    FilePath? thumbnails,
    ContentOrigin? contentOrigin,
    String? groupId,
    String? author,
    Map<String, dynamic>? fields,
    String? rawFieldsJson,
  }) {
    final computedFieldsJson = rawFieldsJson ?? ((fields == null || fields.isEmpty) ? null : jsonEncode(fields));

    return ModuleContentMetadata()
      ..originalFileName = originalFileName
      ..thumbnail = thumbnails
      ..contentOrigin = contentOrigin ?? ContentOrigin.none
      ..groupId = groupId
      ..author = author
      ..rawFieldsJson = computedFieldsJson;
  }

  // Create empty metadata
  factory ModuleContentMetadata.empty() => ModuleContentMetadata();

  // Convert to JSON string (for storing in Isar)
  String toJson() => jsonEncode(toMap());

  // Convert to Map
  Map<String, dynamic> toMap() {
    final extraFields = fields;
    return {
      if (originalFileName != null) 'originalFileName': originalFileName,
      if (thumbnail != null) 'thumbnails': thumbnail!.toJson(),
      'contentOrigin': contentOrigin.name,
      if (groupId != null) 'groupId': groupId,
      if (author != null) 'author': author,
      if (extraFields != null) ...extraFields,
    };
  }

  // Create from JSON string
  factory ModuleContentMetadata.fromJson(String source) {
    if (source.isEmpty) return ModuleContentMetadata.empty();
    try {
      return ModuleContentMetadata.fromMap(jsonDecode(source));
    } catch (_) {
      return ModuleContentMetadata.empty();
    }
  }

  // Create from Map
  factory ModuleContentMetadata.fromMap(Map<String, dynamic> map) {
    // Extract known fields
    final knownFields = {'originalFileName', 'thumbnails', 'contentOrigin', 'groupId', 'author'};
    final fields = Map<String, dynamic>.from(map)..removeWhere((key, value) => knownFields.contains(key));

    final rawThumbnail = map['thumbnails'];
    final resolvedThumbnail = switch (rawThumbnail) {
      String value => FilePath.fromJson(value),
      Map value => FilePath.fromMap(Map<String, dynamic>.from(value)),
      _ => null,
    };

    return ModuleContentMetadata.create(
      originalFileName: map['originalFileName'] as String?,
      thumbnails: resolvedThumbnail,
      contentOrigin: map['contentOrigin'] != null
          ? ContentOrigin.values.firstWhere(
              (test) => test.name == map['contentOrigin'],
              orElse: () => ContentOrigin.none,
            )
          : null,
      groupId: map['groupId'] as String?,
      author: map['author'] as String?,
      fields: fields.isNotEmpty ? fields : null,
      rawFieldsJson: fields.isNotEmpty ? jsonEncode(fields) : null,
    );
  }

  // Create a copy with updated fields
  ModuleContentMetadata copyWith({
    String? originalFileName,
    FilePath? thumbnails,
    ContentOrigin? contentOrigin,
    String? groupId,
    String? author,
    Map<String, dynamic>? fields,
  }) {
    final nextFields = fields ?? this.fields;
    return ModuleContentMetadata.create(
      originalFileName: originalFileName ?? this.originalFileName,
      thumbnails: thumbnails ?? this.thumbnail,
      contentOrigin: contentOrigin ?? this.contentOrigin,
      groupId: groupId ?? this.groupId,
      author: author ?? this.author,
      fields: nextFields,
      rawFieldsJson: nextFields == null ? null : jsonEncode(nextFields),
    );
  }

  @override
  String toString() {
    return 'ContentMetadata(originalFileName: $originalFileName, thumbnails: $thumbnail, contentOrigin: $contentOrigin, groupId: $groupId, author: $author, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModuleContentMetadata &&
        other.originalFileName == originalFileName &&
        other.thumbnail == thumbnail &&
        other.contentOrigin == contentOrigin &&
        other.groupId == groupId &&
        other.author == author &&
        _mapsEqual(other.fields, fields);
  }

  @override
  int get hashCode {
    return originalFileName.hashCode ^
        thumbnail.hashCode ^
        contentOrigin.hashCode ^
        groupId.hashCode ^
        author.hashCode ^
        fields.hashCode;
  }

  // Helper method to compare maps
  bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
