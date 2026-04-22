import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/theme_utils.dart';
import 'package:slidesync/data/models/file_path.dart';

part 'module_metadata.g.dart';

@embedded
class ModuleMetadata {
  String? author;
  FilePath? thumbnail;

  String? rawColor;

  @ignore
  Color? get color => rawColor != null && rawColor!.isNotEmpty ? ThemeUtils.hexToColor(rawColor!) : null;

  ModuleMetadata();

  factory ModuleMetadata.create({String? author, FilePath? thumbnail, Color? color, String? rawColor}) {
    final resolvedColor = rawColor ?? (color != null ? ThemeUtils.colorToHex(color) : null);
    return ModuleMetadata()
      ..author = author
      ..thumbnail = thumbnail
      ..rawColor = resolvedColor;
  }

  // Create empty metadata
  factory ModuleMetadata.empty() => ModuleMetadata();

  // Convert to JSON string (for storing in Isar)
  String toJson() => jsonEncode(toMap());

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      if (author != null) 'author': author,
      if (thumbnail != null) 'thumbnail': thumbnail!.toJson(),
      if (rawColor != null) 'color': rawColor,
    };
  }

  // Create from JSON string
  factory ModuleMetadata.fromJson(String source) {
    if (source.isEmpty) return ModuleMetadata.empty();
    try {
      return ModuleMetadata.fromMap(jsonDecode(source));
    } catch (e) {
      return ModuleMetadata.empty();
    }
  }

  // Create from Map
  factory ModuleMetadata.fromMap(Map<String, dynamic> map) {
    return ModuleMetadata.create(
      author: map['author'] as String?,
      thumbnail: FilePath.fromJson(map['thumbnail'] as String? ?? ''),
      rawColor: map['color'] as String?,
    );
  }

  // Create a copy with updated fields
  ModuleMetadata copyWith({String? author, FilePath? thumbnail, Color? color}) {
    return ModuleMetadata.create(
      author: author ?? this.author,
      thumbnail: thumbnail ?? this.thumbnail,
      rawColor: color != null ? ThemeUtils.colorToHex(color) : rawColor,
    );
  }

  @override
  String toString() => 'ModuleMetadata(author: $author, thumbnail: $thumbnail, color: $rawColor)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModuleMetadata &&
        other.author == author &&
        other.thumbnail == thumbnail &&
        other.rawColor == rawColor;
  }

  @override
  int get hashCode => author.hashCode ^ thumbnail.hashCode ^ rawColor.hashCode;
}
