import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/theme_utils.dart';
import 'package:slidesync/data/models/file_path.dart';

part 'course_metadata.g.dart';

@embedded
class CourseMetadata {
  String? author;
  FilePath? thumbnails;
  String? rawColor;

  @ignore
  Color? get color => rawColor != null && rawColor!.isNotEmpty ? ThemeUtils.hexToColor(rawColor!) : null;

  FilePath get thumbnailsDetails => thumbnails ?? FilePath();

  CourseMetadata();

  factory CourseMetadata.create({String? author, FilePath? thumbnails, Color? color, String? rawColor}) {
    final resolvedColor = rawColor ?? (color != null ? ThemeUtils.colorToHex(color) : null);
    return CourseMetadata()
      ..author = author
      ..thumbnails = thumbnails
      ..rawColor = resolvedColor;
  }

  // Create empty metadata
  factory CourseMetadata.empty() => CourseMetadata();

  // Convert to JSON string (for storing in Isar)
  String toJson() => jsonEncode(toMap());

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      if (author != null) 'author': author,
      if (thumbnails != null) 'thumbnails': thumbnails!.toJson(),
      if (rawColor != null) 'color': rawColor,
    };
  }

  // Create from JSON string
  factory CourseMetadata.fromJson(String source) {
    if (source.isEmpty) return CourseMetadata.empty();
    try {
      return CourseMetadata.fromMap(jsonDecode(source));
    } catch (_) {
      return CourseMetadata.empty();
    }
  }

  // Create from Map
  factory CourseMetadata.fromMap(Map<String, dynamic> map) {
    final rawThumbnail = map['thumbnails'];
    final resolvedThumbnail = switch (rawThumbnail) {
      String value => FilePath.fromJson(value),
      Map value => FilePath.fromMap(Map<String, dynamic>.from(value)),
      _ => null,
    };

    return CourseMetadata.create(
      author: map['author'] as String?,
      thumbnails: resolvedThumbnail,
      rawColor: map['color'] as String?,
    );
  }

  // Create a copy with updated fields
  CourseMetadata copyWith({String? author, FilePath? thumbnails, Color? color}) {
    return CourseMetadata.create(
      author: author ?? this.author,
      thumbnails: thumbnails ?? this.thumbnails,
      rawColor: color != null ? ThemeUtils.colorToHex(color) : rawColor,
    );
  }

  @override
  String toString() {
    return 'CourseMetadata(author: $author, thumbnails: $thumbnails, color: $rawColor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseMetadata &&
        other.author == author &&
        other.thumbnails == thumbnails &&
        other.rawColor == rawColor;
  }

  @override
  int get hashCode {
    return author.hashCode ^ thumbnails.hashCode ^ rawColor.hashCode;
  }
}
