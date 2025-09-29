import 'package:isar/isar.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/progress_track_models/content_track.dart';
import 'package:slidesync/domain/models/progress_track_models/course_track.dart';

const List<CollectionSchema> isarSchemas = [
  CourseSchema,
  CourseCollectionSchema,
  CourseContentSchema,
  CourseTrackSchema,
  ContentTrackSchema,
];
