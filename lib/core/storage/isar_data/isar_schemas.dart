import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
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
