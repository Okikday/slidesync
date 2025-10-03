// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';

part 'course_track.g.dart';

@collection
class CourseTrack {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String courseId;
  String? title;
  String? description;

  double? progress;
  String? additionalDetail;
  IsarLinks<ContentTrack> contentTracks = IsarLinks<ContentTrack>();
  String metadataJson = '{}';

  CourseTrack();

  factory CourseTrack.create({
    required String courseId,
    String? title,
    String? description,
    double? progress,
    String? additionalDetail,
    String? metadataJson,
  }) {
    return CourseTrack()
      ..courseId = courseId
      ..title = title
      ..description = description
      ..progress = progress
      ..additionalDetail = additionalDetail
      ..metadataJson = metadataJson ?? '{}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'progress': progress,
      'additionalDetail': additionalDetail,
      'metadataJson': metadataJson,
      // Note: contentTracks is not included in map for serialization
    };
  }

  factory CourseTrack.fromMap(Map<String, dynamic> map) {
    return CourseTrack()
      ..id = map['id'] as int
      ..courseId = map['courseId'] as String
      ..title = map['title'] as String?
      ..description = map['description'] as String?
      ..progress = map['progress'] as double? ?? 0.0
      ..additionalDetail = map['additionalDetail'] as String? ?? ''
      ..metadataJson = map['metadataJson'] ?? '{}';
  }

  String toJson() => json.encode(toMap());

  factory CourseTrack.fromJson(String source) => CourseTrack.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CourseTrack(id: $id, courseId: $courseId, title: $title, description: $description, progress: $progress, additionalDetail: $additionalDetail, metadataJson: $metadataJson)';
  }

  @override
  bool operator ==(covariant CourseTrack other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.courseId == courseId &&
        other.title == title &&
        other.description == description &&
        other.progress == progress &&
        other.additionalDetail == additionalDetail &&
        other.metadataJson == metadataJson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        courseId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        progress.hashCode ^
        additionalDetail.hashCode ^
        metadataJson.hashCode;
  }
}

extension CourseTrackExtension on CourseTrack {
  CourseTrack copyWith({
    Id? id,
    String? courseId,
    String? title,
    String? description,
    double? progress,
    String? additionalDetail,
    String? metadataJson,
  }) {
    return this
      ..id = id ?? this.id
      ..courseId = courseId ?? this.courseId
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..progress = progress ?? this.progress
      ..additionalDetail = additionalDetail ?? this.additionalDetail
      ..metadataJson = metadataJson ?? this.metadataJson;
  }
}
