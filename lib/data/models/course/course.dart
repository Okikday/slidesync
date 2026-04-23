// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course/course_metadata.dart';
import 'package:slidesync/data/models/file_path.dart';
import 'package:slidesync/shared/helpers/formatter.dart';
import 'package:uuid/uuid.dart';

import '../module/module.dart';

part 'course.g.dart';
part 'extension_on_course.dart';

@collection
class Course {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uid = '';

  @Index(caseSensitive: false)
  String title = '';

  String description = '';

  DateTime createdAt = DateTime.now();
  DateTime lastModified = DateTime.now();

  final IsarLinks<Module> collections = IsarLinks<Module>();

  CourseMetadata metadata = CourseMetadata.empty();

  Course();

  factory Course.create({
    String? uid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    CourseMetadata? metadata,
  }) {
    final now = DateTime.now();
    return Course()
      ..uid = (uid == null || uid.isEmpty) ? const Uuid().v4() : uid
      ..title = title ?? ''
      ..description = description ?? ''
      ..createdAt = createdAt ?? now
      ..lastModified = lastModified ?? now
      ..metadata = metadata ?? CourseMetadata.empty();
  }

  // Json Conversions
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'lastModified': lastModified.toIso8601String(),
    'metadata': metadata.toJson(),
    // Note: subCollections and rootContents are IsarLinks, not serialized here
  };

  factory Course.fromMap(Map<String, dynamic> map) => Course.create(
    uid: map['uid'] ?? const Uuid().v4(),
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? ''),
    lastModified: DateTime.tryParse((map['lastModified'] as String?) ?? ''),
    metadata: map['metadata'] != null ? CourseMetadata.fromJson(Result.from(() => (map['metadata'] as String))) : null,
  );

  String toJson() => jsonEncode(toMap());
  factory Course.fromJson(String source) => Course.fromMap(jsonDecode(source));

  // Copy with
  Course copyWith({
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    CourseMetadata? metadata,
  }) {
    return this
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..createdAt = createdAt ?? this.createdAt
      ..lastModified = lastModified ?? DateTime.now()
      ..metadata = metadata ?? this.metadata;
  }

  @override
  bool operator ==(covariant Course other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
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
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        lastModified.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'Course(id: $id, courseId: $uid, title: $title, description: $description, createdAt: $createdAt, lastModified: $lastModified, metadata: $metadata)';
  }
}
