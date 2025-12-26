part of 'course.dart';

extension CourseExtension on Course {
  String get courseName => Formatter.separateCodeFromTitle(courseTitle).courseName;
  String get courseCode => Formatter.separateCodeFromTitle(courseTitle).courseCode;

  String get previewPath => FileDetails.fromMap(metadata.thumbnails ?? {}).filePath;
  String get thumbnailPath => previewPath;

  Course copyWith({
    String? courseId,
    String? courseTitle,
    String? description,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? metadataJson,
  }) {
    return this
      ..courseId = courseId ?? this.courseId
      ..courseTitle = courseTitle ?? this.courseTitle
      ..description = description ?? this.description
      // ..imageLocationJson = imageLocationJson ?? this.imageLocationJson
      ..createdAt = createdAt ?? this.createdAt
      ..lastUpdated = lastUpdated ?? DateTime.now()
      ..metadataJson = metadataJson ?? this.metadataJson;
  }
}

extension StringExtension on String {
  String get courseName => Formatter.separateCodeFromTitle(this).courseName;
  String get courseCode => Formatter.separateCodeFromTitle(this).courseCode;
}
