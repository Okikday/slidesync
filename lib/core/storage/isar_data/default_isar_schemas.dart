import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/models/quiz_question_model/content_questions.dart';

const List<CollectionSchema> defaultIsarSchemas = [
  CourseSchema,
  ModuleSchema,
  ModuleContentSchema,
  CourseTrackSchema,
  ContentTrackSchema,
  ContentQuestionsSchema,
];
