import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:uuid/uuid.dart';

import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/course/src/course_metadata.dart';

export 'src/course_metadata.dart';

part 'course.mapper.dart';
part 'course.g.dart';

@MappableClass()
@Collection(ignore: {'copyWith'})
class Course with CourseMappable {
  Id id;
  @Index(unique: true)
  String uid;
  @Index(caseSensitive: false)
  String title;
  String description;
  DateTime createdAt;
  DateTime lastModified;
  CourseMetadata metadata;

  final IsarLinks<Module> modules = IsarLinks<Module>();

  Course({
    this.id = Isar.autoIncrement,
    required this.uid,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.lastModified,
    required this.metadata,
  });

  static const fromJson = CourseMapper.fromJson;

  static Course create({required String title, String? uid, String? description, CourseMetadata? metadata}) {
    final now = DateTime.now();
    return Course(
      uid: uid ?? const Uuid().v4(),
      title: title,
      description: description ?? '',
      createdAt: now,
      lastModified: now,
      metadata: metadata ?? CourseMetadata.create(),
    );
  }
}

extension CourseExtension on Course {
  // CourseTitleRecord get _sorterCourseTitle => Formatter.separateCodeFromTitle(title);
  // String get courseName => _sorterCourseTitle.courseName;
  // String get courseCode => _sorterCourseTitle.courseCode;

  String get previewPath => metadata.thumbnail?.local ?? '';
  String get localThumbnailPath => previewPath;
}
