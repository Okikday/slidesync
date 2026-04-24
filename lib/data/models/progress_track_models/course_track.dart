// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';

part 'course_track.mapper.dart';
part 'course_track.g.dart';

@MappableClass()
@collection
class CourseTrack with CourseTrackMappable {
  Id id;
  @Index(unique: true)
  String uid;
  String title;
  String description;
  double progress;
  String? extraDetail;

  final IsarLinks<ContentTrack> contentTracks = IsarLinks<ContentTrack>();
  CourseTrack({
    this.id = Isar.autoIncrement,
    required this.uid,
    required this.title,
    required this.description,
    required this.progress,
    required this.extraDetail,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CourseTrack && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  static CourseTrack create({
    required String courseId,
    required String title,
    required String description,
    double progress = 0.0,
    String? extraDetail,
  }) =>
      CourseTrack(uid: courseId, title: title, description: description, progress: progress, extraDetail: extraDetail);
}
