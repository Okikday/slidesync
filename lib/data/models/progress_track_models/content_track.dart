// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';

part 'content_track.mapper.dart';
part 'content_track.g.dart';

@MappableClass()
@Collection(ignore: {'copyWith'})
class ContentTrack with ContentTrackMappable {
  Id id;
  @Index(unique: true)
  String uid;
  @Enumerated(EnumType.name)
  ModuleContentType type;
  @Index()
  String courseId;
  String title;
  String description;
  double progress;
  FilePath thumbnail;
  String? extraDetail;
  List<String> pages;
  DateTime lastRead;

  ContentTrack({
    this.id = Isar.autoIncrement,
    required this.uid,
    required this.courseId,
    required this.type,
    required this.title,
    required this.description,
    required this.progress,
    required this.extraDetail,
    required this.pages,
    required this.lastRead,
    required this.thumbnail,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ContentTrack && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  static ContentTrack create({
    required String uid,
    required String courseId,
    required String title,
    required ModuleContentType type,
    String? description,
    required double progress,
    String? extraDetail,
    List<String> pages = const [],
    DateTime? lastRead,
    FilePath? thumbnail,
  }) => ContentTrack(
    uid: uid,
    courseId: courseId,
    title: title,
    type: type,
    description: description ?? "",
    progress: progress,
    extraDetail: extraDetail,
    pages: pages,
    lastRead: lastRead ?? DateTime.now(),
    thumbnail: thumbnail ?? FilePath.empty(),
  );
}
