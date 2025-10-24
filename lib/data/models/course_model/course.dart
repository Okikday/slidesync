// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_map.dart';
import 'package:slidesync/shared/helpers/formatter.dart';
import 'package:uuid/uuid.dart';

import 'course_collection.dart';

part 'course.g.dart';

@collection
class Course {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String courseId;

  @Index(caseSensitive: false)
  late String courseTitle;
  String description = '';
  // String imageLocationJson = '{}';
  DateTime? createdAt;
  DateTime? lastUpdated;

  final IsarLinks<CourseCollection> collections = IsarLinks<CourseCollection>();

  String metadataJson = '{}';

  Course();

  factory Course.create({
    String? courseId,
    required String courseTitle,
    String description = '',
    DateTime? createdAt,
    // FileDetails? imageLocation,
    String metadataJson = '{}',
  }) {
    return Course()
      ..courseId = courseId ?? const Uuid().v4()
      ..courseTitle = courseTitle
      ..description = description
      ..createdAt = createdAt ?? DateTime.now()
      ..lastUpdated = DateTime.now()
      // ..imageLocationJson = imageLocation?.toJson() ?? '{}'
      ..metadataJson = metadataJson;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'description': description,
      // 'imageLocationJson': imageLocationJson,
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'metadataJson': metadataJson,
      // Note: subCollections and rootContents are IsarLinks, not serialized here
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    final course = Course();
    course.id = map['id'] ?? Isar.autoIncrement;
    course.courseId = map['courseId'] ?? '';
    course.courseTitle = map['courseTitle'] ?? '';
    course.description = map['description'] ?? '';
    // course.imageLocationJson = map['imageLocationJson'] ?? '{}';
    course.createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null;
    course.lastUpdated = map['lastUpdated'] != null ? DateTime.tryParse(map['lastUpdated']) : null;
    course.metadataJson = map['metadataJson'] ?? '{}';
    return course;
  }

  String toJson() => jsonEncode(toMap());

  factory Course.fromJson(String source) => Course.fromMap(jsonDecode(source));

  @override
  bool operator ==(covariant Course other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.courseId == courseId &&
        other.courseTitle == courseTitle &&
        other.description == description &&
        // other.imageLocationJson == imageLocationJson &&
        other.createdAt == createdAt &&
        other.lastUpdated == lastUpdated &&
        other.metadataJson == metadataJson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        courseId.hashCode ^
        courseTitle.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        lastUpdated.hashCode ^
        collections.hashCode;
  }

  @override
  String toString() {
    return 'Course(id: $id, courseId: $courseId, courseTitle: $courseTitle, description: $description, createdAt: $createdAt, lastUpdated: $lastUpdated)';
  }
}

extension CourseExtension on Course {
  String get courseName => Formatter.separateCodeFromTitle(courseTitle).courseName;
  String get courseCode => Formatter.separateCodeFromTitle(courseTitle).courseCode;

  Map<String, dynamic> get metadata {
    if (metadataJson.isEmpty || metadataJson.trim().isEmpty) {
      return <String, dynamic>{};
    }
    return Result.tryRun(() => Map<String, dynamic>.from(jsonDecode(metadataJson))).data ?? <String, dynamic>{};
  }

  String get imageLocationJson {
    final json = metadata['imageLocationJson'];
    if (json == null) return '{}';
    if (json is String) return json;
    if (json is Map) return jsonEncode(json);
    return '{}';
  }

  FileDetails get imageLocation {
    final jsonStr = imageLocationJson;
    if (jsonStr.isEmpty || jsonStr == '{}') {
      return FileDetails();
    }
    return FileDetails.fromJson(jsonStr);
  }

  Course setImageLocation(FileDetails imageDetails) =>
      copyWith(metadataJson: {...metadata, 'imageLocationJson': imageDetails.toJson()}.encodeToJson);
  Course copyWith({
    String? courseId,
    String? courseTitle,
    String? description,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? metadataJson,
  }) {
    return this
      ..courseId = courseId ?? this.courseId
      ..courseTitle = courseTitle ?? this.courseTitle
      ..description = description ?? this.description
      // ..imageLocationJson = imageLocationJson ?? this.imageLocationJson
      ..createdAt = createdAt ?? this.createdAt
      ..lastUpdated = lastUpdated ?? DateTime.now()
      ..metadataJson = metadataJson ?? this.metadataJson;
  }
}

extension StringExtension on String {
  String get courseName => Formatter.separateCodeFromTitle(this).courseName;
  String get courseCode => Formatter.separateCodeFromTitle(this).courseCode;
}
