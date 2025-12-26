import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/models/quiz_question_model/content_questions.dart';

const List<CollectionSchema> isarSchemas = [
  CourseSchema,
  CourseCollectionSchema,
  CourseContentSchema,
  CourseTrackSchema,
  ContentTrackSchema,
  ContentQuestionsSchema,
];
