// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

part 'content_track.g.dart';

@collection
class ContentTrack {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String contentId;

  @Index()
  late String parentId;

  String? title;
  String? description;

  @Index()
  late String contentHash;
  double? progress;
  String? additionalDetail;
  List<String> pages = <String>[];

  DateTime? lastRead;

  String metadataJson = '{}';

  ContentTrack();

  factory ContentTrack.create({
    required String contentId,
    required String parentId,
    String? title,
    String? description,
    required String contentHash,
    double? progress,
    String? additionalDetail,
    List<String>? pages,
    String? metadataJson,
    DateTime? lastRead,
  }) {
    return ContentTrack()
      ..contentId = contentId
      ..parentId = parentId
      ..title = title
      ..description = description
      ..contentHash = contentHash
      ..progress = progress
      ..additionalDetail = additionalDetail
      ..pages = pages ?? <String>[]
      ..lastRead = lastRead
      ..metadataJson = metadataJson ?? '{}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'contentId': contentId,
      'parentId': parentId,
      'title': title,
      'description': description,
      'contentHash': contentHash,
      'progress': progress,
      'additionalDetail': additionalDetail,
      'pages': pages,
      'lastRead': lastRead?.toIso8601String(),
      'metadataJson': metadataJson,
    };
  }

  factory ContentTrack.fromMap(Map<String, dynamic> map) {
    return ContentTrack()
      ..id = map['id'] as int
      ..contentId = map['contentId'] as String
      ..parentId = map['parentId'] as String
      ..title = map['title'] as String?
      ..description = map['description'] as String?
      ..contentHash = map['contentHash'] as String? ?? ''
      ..progress = map['progress'] as double? ?? 0.0
      ..additionalDetail = map['additionalDetail'] as String? ?? ''
      ..pages = map['pages'] as List<String>? ?? <String>[]
      ..lastRead = DateTime.tryParse(map['lastRead'] as String? ?? '') ?? DateTime.now()
      ..metadataJson = map['metadataJson'] ?? '{}';
  }

  String toJson() => json.encode(toMap());

  factory ContentTrack.fromJson(String source) => ContentTrack.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProgressTrackModel(id: $id, contentId: $contentId, parentId: $parentId, title: $title, description: $description, contentHash: $contentHash, progress: $progress, additionalDetail: $additionalDetail, pages: $pages, lastRead: $lastRead, metadataJson: $metadataJson)';
  }

  @override
  bool operator ==(covariant ContentTrack other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.contentId == contentId &&
        other.parentId == parentId &&
        other.title == title &&
        other.description == description &&
        other.contentHash == contentHash &&
        other.progress == progress &&
        other.additionalDetail == additionalDetail &&
        const ListEquality().equals(other.pages, pages) &&
        other.lastRead == lastRead &&
        other.metadataJson == metadataJson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        contentId.hashCode ^
        parentId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        contentHash.hashCode ^
        progress.hashCode ^
        additionalDetail.hashCode ^
        pages.hashCode ^
        lastRead.hashCode ^
        metadataJson.hashCode;
  }
}

extension ProgressTrackModelExtension on ContentTrack {
  ContentTrack copyWith({
    Id? id,
    String? contentId,
    String? parentId,
    String? title,
    String? description,
    String? contentHash,
    double? progress,
    String? additionalDetail,
    List<String>? pages,
    DateTime? lastRead,
    String? metadataJson,
  }) {
    return this
      ..contentId = contentId ?? this.contentId
      ..parentId = parentId ?? this.parentId
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..contentHash = contentHash ?? this.contentHash
      ..progress = progress ?? this.progress
      ..additionalDetail = additionalDetail ?? this.additionalDetail
      ..pages = pages ?? this.pages
      ..lastRead = lastRead
      ..metadataJson = metadataJson ?? this.metadataJson;
  }
}
