part of 'course.dart';

extension CourseExtension on Course {
  String get courseName => Formatter.separateCodeFromTitle(title).courseName;
  String get courseCode => Formatter.separateCodeFromTitle(title).courseCode;

  String get previewPath => metadata.thumbnail?.local ?? '';
  String get thumbnailPath => previewPath;
}

extension StringExtension on String {
  String get courseName => Formatter.separateCodeFromTitle(this).courseName;
  String get courseCode => Formatter.separateCodeFromTitle(this).courseCode;
}
