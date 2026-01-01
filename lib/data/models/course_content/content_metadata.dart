import 'dart:convert';

import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/file_details.dart';

class ContentMetadata {
  final String? originalFileName;
  final FileDetails? thumbnails;
  final ContentOrigin contentOrigin;
  final String? groupId;
  final Map<String, dynamic>? fields; // For any additional metadata

  ContentMetadata({
    this.originalFileName,
    this.thumbnails,
    this.contentOrigin = ContentOrigin.none,
    this.groupId,
    this.fields,
  });

  // Create empty metadata
  factory ContentMetadata.empty() => ContentMetadata();

  // Convert to JSON string (for storing in Isar)
  String toJson() => jsonEncode(toMap());

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      if (originalFileName != null) 'originalFileName': originalFileName,
      if (thumbnails != null) 'thumbnails': thumbnails?.toJson(),
      'contentOrigin': contentOrigin.name,
      if (groupId != null) 'groupId': groupId,
      if (fields != null) ...fields!,
    };
  }

  // Create from JSON string
  factory ContentMetadata.fromJson(String source) {
    try {
      return ContentMetadata.fromMap(jsonDecode(source));
    } catch (e) {
      return ContentMetadata.empty();
    }
  }

  // Create from Map
  factory ContentMetadata.fromMap(Map<String, dynamic> map) {
    // Extract known fields
    final knownFields = {'originalFileName', 'thumbnails', 'contentOrigin', 'groupId'};
    final fields = Map<String, dynamic>.from(map)..removeWhere((key, value) => knownFields.contains(key));

    return ContentMetadata(
      originalFileName: map['originalFileName'] as String?,
      thumbnails: map['thumbnails'] != null ? FileDetails.fromJson(map['thumbnails'] as String) : null,
      contentOrigin: ContentOrigin.values.firstWhere(
        (test) => test.name == map['contentOrigin'],
        orElse: () => ContentOrigin.none,
      ),
      groupId: map['groupId'] as String?,
      fields: fields.isNotEmpty ? fields : null,
    );
  }

  // Create a copy with updated fields
  ContentMetadata copyWith({String? originalFileName, FileDetails? thumbnails, Map<String, dynamic>? fields}) {
    return ContentMetadata(
      originalFileName: originalFileName ?? this.originalFileName,
      thumbnails: thumbnails ?? this.thumbnails,
      contentOrigin: contentOrigin,
      groupId: groupId,
      fields: fields ?? this.fields,
    );
  }

  @override
  String toString() {
    return 'ContentMetadata(originalFileName: $originalFileName, thumbnails: $thumbnails, contentOrigin: $contentOrigin, groupId: $groupId, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContentMetadata &&
        other.originalFileName == originalFileName &&
        other.thumbnails == thumbnails &&
        other.contentOrigin == contentOrigin &&
        other.groupId == groupId &&
        _mapsEqual(other.fields, fields);
  }

  @override
  int get hashCode {
    return originalFileName.hashCode ^
        thumbnails.hashCode ^
        contentOrigin.hashCode ^
        groupId.hashCode ^
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
