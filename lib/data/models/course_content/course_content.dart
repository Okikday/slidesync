import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/app_constants.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/data/models/course_content/content_metadata.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:uuid/uuid.dart';

part 'course_content.g.dart';
part 'extension_on_course_content.dart';

@collection
class CourseContent {
  Id id = Isar.autoIncrement;

  /// Holds the hash of the content
  @Index()
  late String contentHash;

  /// Unique identifier for the content
  @Index(unique: true)
  late String contentId;

  /// Identifier for the parent collection
  @Index()
  late String parentId;

  /// Title of the content (e.g., file name or link title)
  @Index(caseSensitive: false)
  late String title;

  /// appended with type before path/link e.g. "file:anonymous.jpg" or "link:https://image.jpg"
  late String path;

  DateTime? createdAt;
  DateTime? lastModified;
  late String description;

  @Enumerated(EnumType.ordinal)
  late CourseContentType courseContentType;

  /// File size in bytes for better content matching
  late int fileSize;

  late String metadataJson;

  @ignore
  ContentMetadata get metadata => ContentMetadata.fromJson(metadataJson);

  CourseContent();

  factory CourseContent.create({
    required String contentHash, // file hash or link hash
    String? contentId, // unique id
    required String parentId, // collection id
    required String title, // file name or link title
    required FileDetails path,
    DateTime? createdAt,
    DateTime? lastModified,
    required CourseContentType courseContentType,
    required int fileSize,
    String description = '',
    String metadataJson = '{}',
  }) {
    final content = CourseContent()
      ..contentHash = contentHash
      ..contentId = contentId ?? const Uuid().v4()
      ..parentId = parentId
      ..title = title
      ..path = path.toJson()
      ..createdAt = createdAt ?? DateTime.now()
      ..lastModified = lastModified ?? DateTime.now()
      ..courseContentType = courseContentType
      ..fileSize = fileSize
      ..description = description
      ..metadataJson = metadataJson;
    return content;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contentHash': contentHash,
      'contentId': contentId,
      'parentId': parentId,
      'title': title,
      'path': path,
      'createdAt': createdAt?.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'description': description,
      'courseContentType': courseContentType.index,
      'fileSize': fileSize,
      'metadataJson': metadataJson,
    };
  }

  factory CourseContent.fromMap(Map<String, dynamic> map) {
    return CourseContent()
      ..id = map['id'] ?? Isar.autoIncrement
      ..contentHash = map['contentHash'] ?? ''
      ..contentId = map['contentId'] ?? ''
      ..parentId = map['parentId'] ?? ''
      ..title = map['title'] ?? ''
      ..path = map['path'] ?? ''
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null
      ..lastModified = map['lastModified'] != null ? DateTime.tryParse(map['lastModified']) : null
      ..description = map['description'] ?? ''
      ..courseContentType = CourseContentType.values[map['courseContentType'] ?? 0]
      ..fileSize = map['fileSize'] ?? 0
      ..metadataJson = map['metadataJson'] ?? '{}';
  }

  String toJson() => jsonEncode(toMap());

  factory CourseContent.fromJson(String source) => CourseContent.fromMap(jsonDecode(source));

  @override
  bool operator ==(covariant CourseContent other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.contentHash == contentHash &&
        other.contentId == contentId &&
        other.parentId == parentId &&
        other.title == title &&
        other.path == path &&
        other.createdAt == createdAt &&
        other.lastModified == lastModified &&
        other.description == description &&
        other.courseContentType == courseContentType &&
        other.fileSize == fileSize && // NEW: Include in equality
        other.metadataJson == metadataJson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        contentHash.hashCode ^
        contentId.hashCode ^
        parentId.hashCode ^
        title.hashCode ^
        path.hashCode ^
        createdAt.hashCode ^
        lastModified.hashCode ^
        description.hashCode ^
        courseContentType.hashCode ^
        fileSize.hashCode ^ // NEW: Include in hashCode
        metadataJson.hashCode;
  }

  @override
  String toString() {
    return 'CourseContent(id: $id, contentHash: $contentHash, contentId: $contentId, parentId: $parentId, title: $title, path: $path, createdAt: $createdAt, lastModified: $lastModified, description: $description, courseContentType: $courseContentType, fileSize: $fileSize, metadataJson: $metadataJson)';
  }
}
