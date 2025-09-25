
import 'package:isar/isar.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/progress_track_model.dart';

const List<CollectionSchema> isarSchemas = [
  CourseSchema,
  CourseCollectionSchema,
  CourseContentSchema,
  ProgressTrackModelSchema
];