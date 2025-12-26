import 'dart:convert';
import 'dart:developer';

import 'package:slidesync/data/models/file_details.dart';

class CourseMetadata {
  final String? author;
  final Map<String, dynamic>? thumbnails;
  final Map<String, dynamic>? fields; // For any additional metadata

  FileDetails get thumbnailsDetails => FileDetails.fromMap(thumbnails ?? {});

  CourseMetadata({this.author, this.thumbnails, this.fields});

  // Create empty metadata
  factory CourseMetadata.empty() => CourseMetadata();

  // Convert to JSON string (for storing in Isar)
  String toJson() => jsonEncode(toMap());

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      if (author != null) 'author': author,
      if (thumbnails != null) 'thumbnails': thumbnails,
      if (fields != null) ...fields!,
    };
  }

  // Create from JSON string
  factory CourseMetadata.fromJson(String source) {
    try {
      return CourseMetadata.fromMap(jsonDecode(source));
    } catch (e) {
      return CourseMetadata.empty();
    }
  }

  // Create from Map
  factory CourseMetadata.fromMap(Map<String, dynamic> map) {
    // Extract known fields
    final knownFields = {'author', 'thumbnails'};
    final fields = Map<String, dynamic>.from(map)..removeWhere((key, value) => knownFields.contains(key));

    return CourseMetadata(
      author: map['author'] as String?,
      thumbnails: map['thumbnails'] as Map<String, dynamic>?,
      fields: fields.isNotEmpty ? fields : null,
    );
  }

  // Create a copy with updated fields
  CourseMetadata copyWith({String? author, Map<String, String>? thumbnails, Map<String, dynamic>? fields}) {
    return CourseMetadata(
      author: author ?? this.author,
      thumbnails: thumbnails ?? this.thumbnails,
      fields: fields ?? this.fields,
    );
  }

  @override
  String toString() {
    return 'CourseMetadata(author: $author, thumbnails: $thumbnails, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseMetadata &&
        other.author == author &&
        other.thumbnails == thumbnails &&
        _mapsEqual(other.fields, fields);
  }

  @override
  int get hashCode {
    return author.hashCode ^ thumbnails.hashCode ^ fields.hashCode;
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
