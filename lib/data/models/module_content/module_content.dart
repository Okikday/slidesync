// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:uuid/uuid.dart';

import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/file_path.dart';
import 'package:slidesync/data/models/module_content/module_content_metadata.dart';

part 'extension_on_course_content.dart';
part 'module_content.g.dart';

@collection
class ModuleContent {
  Id id = Isar.autoIncrement;

  /// Unique identifier for the content
  @Index(unique: true)
  String uid = '';

  /// Holds the hash of the content
  @Index()
  String xxh3Hash = '';

  /// Identifier for the parent collection
  @Index()
  String parentId = '';

  /// Title of the content (e.g., file name or link title)
  @Index(caseSensitive: false)
  String title = '';
  String description = '';

  /// appended with type before path/link e.g. "file:anonymous.jpg" or "link:https://image.jpg"
  FilePath path = FilePath();

  DateTime createdAt = DateTime.now();
  DateTime lastModified = DateTime.now();

  @Enumerated(EnumType.ordinal)
  ModuleContentType type = ModuleContentType.unknown;

  /// File size in bytes for better content matching
  int fileSizeInBytes = 0;

  ModuleContentMetadata metadata = ModuleContentMetadata.empty();

  ModuleContent();

  factory ModuleContent.create({
    String? uid,
    String? contentId,
    String? xxh3Hash,
    String? parentId,
    String? title,
    String? description,
    FilePath? path,
    DateTime? createdAt,
    DateTime? lastModified,
    ModuleContentType? type,
    int? fileSizeInBytes,
    ModuleContentMetadata? metadata,
  }) {
    final now = DateTime.now();
    final resolvedUid = uid ?? contentId;
    return ModuleContent()
      ..uid = (resolvedUid == null || resolvedUid.isEmpty) ? const Uuid().v4() : resolvedUid
      ..xxh3Hash = xxh3Hash ?? ''
      ..parentId = parentId ?? ''
      ..title = title ?? ''
      ..description = description ?? ''
      ..path = path ?? FilePath()
      ..createdAt = createdAt ?? now
      ..lastModified = lastModified ?? now
      ..type = type ?? ModuleContentType.unknown
      ..fileSizeInBytes = fileSizeInBytes ?? 0
      ..metadata = metadata ?? ModuleContentMetadata.empty();
  }

  @override
  String toString() =>
      'ModuleContent(id: $id, uid: $uid, xxh3Hash: $xxh3Hash, parentId: $parentId, title: $title, description: $description, path: $path, createdAt: $createdAt, lastModified: $lastModified, type: $type, fileSizeInBytes: $fileSizeInBytes, metadata: $metadata)';

  @override
  bool operator ==(covariant ModuleContent other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.xxh3Hash == xxh3Hash &&
        other.parentId == parentId &&
        other.title == title &&
        other.description == description &&
        other.path == path &&
        other.createdAt == createdAt &&
        other.lastModified == lastModified &&
        other.type == type &&
        other.fileSizeInBytes == fileSizeInBytes &&
        other.metadata == metadata;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      xxh3Hash.hashCode ^
      parentId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      path.hashCode ^
      createdAt.hashCode ^
      lastModified.hashCode ^
      type.hashCode ^
      fileSizeInBytes.hashCode ^
      metadata.hashCode;

  ModuleContent copyWith({
    String? uid,
    String? contentId,
    String? xxh3Hash,
    String? parentId,
    String? title,
    String? description,
    FilePath? path,
    DateTime? createdAt,
    DateTime? lastModified,
    ModuleContentType? type,
    int? fileSizeInBytes,
    ModuleContentMetadata? metadata,
  }) {
    final resolvedUid = uid ?? contentId;
    return ModuleContent.create(
      uid: resolvedUid ?? this.uid,
      xxh3Hash: xxh3Hash ?? this.xxh3Hash,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      type: type ?? this.type,
      fileSizeInBytes: fileSizeInBytes ?? this.fileSizeInBytes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'xxh3Hash': xxh3Hash,
      'parentId': parentId,
      'title': title,
      'description': description,
      'path': path.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'type': type.index,
      'fileSizeInBytes': fileSizeInBytes,
      'metadata': metadata.toJson(),
    };
  }

  factory ModuleContent.fromMap(Map<String, dynamic> map) {
    return ModuleContent.create(
      uid: map['uid'] as String? ?? const Uuid().v4(),
      xxh3Hash: map['xxh3Hash'] as String? ?? '',
      parentId: map['parentId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      path: Result.from(() => FilePath.fromJson(map['path'] as String? ?? '')),
      createdAt: Result.from(() => DateTime.tryParse(map['createdAt'] as String? ?? '')),
      lastModified: Result.from(() => DateTime.tryParse(map['lastModified'] as String? ?? '')),
      type: ModuleContentType.values[map['type'] as int? ?? 0],
      fileSizeInBytes: map['fileSizeInBytes'] as int? ?? 0,
      metadata: map['metadata'] != null
          ? ModuleContentMetadata.fromJson(Result.from(() => (map['metadata'] as String)))
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ModuleContent.fromJson(String source) => ModuleContent.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

final defaultContent = ModuleContent.create(
  xxh3Hash: '_',
  parentId: '_',
  title: '_',
  fileSizeInBytes: 0,
  path: FilePath(),
  type: ModuleContentType.unknown,
);
