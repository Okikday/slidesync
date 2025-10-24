// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_map.dart';
import 'package:uuid/uuid.dart';

import 'course_content.dart';

part 'course_collection.g.dart';

@collection
class CourseCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String collectionId;

  @Index()
  late String parentId;
  late String collectionTitle;

  late String description;
  DateTime? createdAt;
  // late String imageLocationJson;
  late String metadataJson;

  final IsarLinks<CourseContent> contents = IsarLinks<CourseContent>();

  CourseCollection();

  factory CourseCollection.create({
    required String parentId,
    String? collectionId,
    required String collectionTitle,
    String description = '',
    DateTime? createdAt,
    // String imageLocationJson = '{}',
    String metadataJson = '{}',
  }) {
    final collection = CourseCollection()
      ..collectionId = collectionId ?? const Uuid().v4()
      ..parentId = parentId
      ..collectionTitle = collectionTitle
      ..description = description
      ..createdAt = createdAt ?? DateTime.now()
      // ..imageLocationJson = imageLocationJson
      ..metadataJson = metadataJson;
    return collection;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collectionId': collectionId,
      'parentId': parentId,
      'collectionTitle': collectionTitle,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      // 'imageLocationJson': imageLocationJson,
      'metadataJson': metadataJson,
      // courseContents is IsarLinks, not serialized here
    };
  }

  factory CourseCollection.fromMap(Map<String, dynamic> map) {
    final collection = CourseCollection();
    collection.id = map['id'] ?? Isar.autoIncrement;
    collection.collectionId = map['collectionId'] ?? '';
    collection.parentId = map['parentId'] ?? '';
    collection.collectionTitle = map['collectionTitle'] ?? '';
    collection.description = map['description'] ?? '';
    collection.createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null;
    // collection.imageLocationJson = map['imageLocationJson'] ?? '{}';
    collection.metadataJson = map['metadataJson'] ?? '{}';

    return collection;
  }

  String toJson() => jsonEncode(toMap());

  factory CourseCollection.fromJson(String source) => CourseCollection.fromMap(jsonDecode(source));

  @override
  bool operator ==(covariant CourseCollection other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.collectionId == collectionId &&
        other.parentId == parentId &&
        other.collectionTitle == collectionTitle &&
        other.description == description &&
        other.createdAt == createdAt &&
        // other.imageLocationJson == imageLocationJson &&
        other.metadataJson == metadataJson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        collectionId.hashCode ^
        parentId.hashCode ^
        collectionTitle.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        // imageLocationJson.hashCode ^
        metadataJson.hashCode;
  }

  @override
  String toString() {
    return 'CourseCollection(id: $id, collectionId: $collectionId, parentId: $parentId, collectionTitle: $collectionTitle, description: $description, createdAt: $createdAt, metadataJson: $metadataJson)';
  }
}

extension CourseCollectionExtension on CourseCollection {
  String get absolutePath => p.join(AppPaths.coursesFolder, parentId, collectionId);
  String get courseId => parentId;

  String joinAbsWithChild(String childId) => p.join(absolutePath, childId);

  CourseCollection copyWith({
    String? collectionId,
    String? parentId,
    String? collectionTitle,
    String? description,
    DateTime? createdAt,
    String? imageLocationJson,
    String? metadataJson,
  }) {
    return this
      ..collectionId = collectionId ?? this.collectionId
      ..parentId = parentId ?? this.parentId
      ..collectionTitle = collectionTitle ?? this.collectionTitle
      ..description = description ?? this.description
      ..createdAt = createdAt ?? this.createdAt
      // ..imageLocationJson = imageLocationJson ?? this.imageLocationJson
      ..metadataJson = metadataJson ?? this.metadataJson;
  }

  Map<String, dynamic> get metadata =>
      Result.tryRun(() => Map<String, dynamic>.from(jsonDecode(metadataJson))).data ?? <String, dynamic>{};
  String get imageLocationJson => metadataJson.decodeJson['imageLocationJson'];
  CourseCollection setImageLocation(FileDetails imageDetails) =>
      copyWith(metadataJson: {...metadataJson.decodeJson, 'imageLocationJson': imageDetails.toJson()}.encodeToJson);
}
