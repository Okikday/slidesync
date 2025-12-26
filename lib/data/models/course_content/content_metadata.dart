import 'dart:convert';

class ContentMetadata {
  final String? originalFileName;
  final Map<String, String>? thumbnails;
  final Map<String, dynamic>? fields; // For any additional metadata

  ContentMetadata({this.originalFileName, this.thumbnails, this.fields});

  // Create empty metadata
  factory ContentMetadata.empty() => ContentMetadata();

  // Convert to JSON string (for storing in Isar)
  String toJson() => jsonEncode(toMap());

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      if (originalFileName != null) 'originalFileName': originalFileName,
      if (thumbnails != null) 'thumbnails': thumbnails,
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
    final knownFields = {'originalFileName', 'thumbnails'};
    final fields = Map<String, dynamic>.from(map)..removeWhere((key, value) => knownFields.contains(key));

    return ContentMetadata(
      originalFileName: map['originalFileName'] as String?,
      thumbnails: map['thumbnails'] != null ? Map<String, String>.from(map['thumbnails'] as Map) : null,
      fields: fields.isNotEmpty ? fields : null,
    );
  }

  // Create a copy with updated fields
  ContentMetadata copyWith({String? originalFileName, Map<String, String>? thumbnails, Map<String, dynamic>? fields}) {
    return ContentMetadata(
      originalFileName: originalFileName ?? this.originalFileName,
      thumbnails: thumbnails ?? this.thumbnails,
      fields: fields ?? this.fields,
    );
  }

  @override
  String toString() {
    return 'ContentMetadata(originalFileName: $originalFileName, thumbnails: $thumbnails, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContentMetadata &&
        other.originalFileName == originalFileName &&
        other.thumbnails == thumbnails &&
        _mapsEqual(other.fields, fields);
  }

  @override
  int get hashCode {
    return originalFileName.hashCode ^ thumbnails.hashCode ^ fields.hashCode;
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
