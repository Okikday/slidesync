// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/file_path.dart';
import 'package:slidesync/data/models/module/module_metadata.dart';
// import 'package:path/path.dart' as p;
// import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:uuid/uuid.dart';

import '../module_content/module_content.dart';

part 'module.g.dart';

@collection
class Module {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uid = '';

  @Index()
  String parentId = '';

  @Index(caseSensitive: false)
  String title = '';

  String description = '';
  DateTime createdAt = DateTime.now();
  DateTime lastModified = DateTime.now();
  ModuleMetadata metadata = ModuleMetadata.empty();

  final IsarLinks<ModuleContent> contents = IsarLinks<ModuleContent>();

  Module();

  factory Module.create({
    String? uid,
    String? parentId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    ModuleMetadata? metadata,
  }) {
    final now = DateTime.now();
    return Module()
      ..uid = (uid == null || uid.isEmpty) ? const Uuid().v4() : uid
      ..parentId = parentId ?? ''
      ..title = title ?? ''
      ..description = description ?? ''
      ..createdAt = createdAt ?? now
      ..lastModified = lastModified ?? now
      ..metadata = metadata ?? ModuleMetadata.empty();
  }

  factory Module.empty() => Module.create(uid: "_", title: "_");

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'parentId': parentId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'metadata': metadata.toJson(),
      // contents is IsarLinks, not serialized here
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module.create(
      uid: map['uid'] ?? '',
      parentId: map['parentId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.tryParse(Result.from(() => map['createdAt'] as String? ?? '')),
      lastModified: DateTime.tryParse(Result.from(() => map['lastModified'] as String? ?? '')),
      metadata: map['metadata'] != null
          ? ModuleMetadata.fromJson(Result.from(() => (map['metadata'] as String)))
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Module.fromJson(String source) => Module.fromMap(jsonDecode(source));

  Module copyWith({
    String? uid,
    String? parentId,
    String? collectionTitle,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    ModuleMetadata? metadata,
  }) {
    final resolvedTitle = title ?? collectionTitle;
    return Module.create(
      uid: uid ?? this.uid,
      parentId: parentId ?? this.parentId,
      title: resolvedTitle ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(covariant Module other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.parentId == parentId &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.lastModified == lastModified &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        parentId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        lastModified.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'CourseCollection(id: $id, uid: $uid, parentId: $parentId, title: $title, description: $description, createdAt: $createdAt, lastModified: $lastModified, metadata: $metadata)';
  }
}

extension CourseCollectionExtension on Module {
  // String get absolutePath => p.join(AppPaths.materialsFolder, parentId, uid);
  String get courseId => parentId;

  // String joinAbsWithChild(String childId) => p.join(absolutePath, childId);
}
