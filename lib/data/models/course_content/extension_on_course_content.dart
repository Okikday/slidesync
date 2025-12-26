part of 'course_content.dart';

extension CourseContentExtension on CourseContent {
  String get collectionId => parentId;

  CourseContent copyWith({
    required String contentHash,
    String? parentId,
    String? title,
    FileDetails? path,
    DateTime? createdAt,
    DateTime? lastModified,
    String? description,
    CourseContentType? courseContentType,
    int? fileSize, // NEW: Add to copyWith
    String? metadataJson,
  }) {
    return this
      ..contentHash = contentHash
      ..parentId = parentId ?? this.parentId
      ..title = title ?? this.title
      ..path = path?.toJson() ?? this.path
      ..createdAt = createdAt ?? this.createdAt
      ..lastModified = lastModified ?? this.lastModified
      ..description = description ?? this.description
      ..courseContentType = courseContentType ?? this.courseContentType
      ..fileSize = fileSize ?? this.fileSize
      ..metadataJson = metadataJson ?? this.metadataJson;
  }

  String get previewPath => FileDetails.fromMap(metadata.thumbnails ?? {}).filePath;
  String get thumbnailPath => previewPath;
  FileDetails get thumbnailDetails => FileDetails(filePath: thumbnailPath);
}

// extension CourseContentMapX on Map<String, dynamic> {
//   int get id => this['id'] as int? ?? -1;
//   String get contentHash => this['contentHash'] as String? ?? '';
//   String get contentId => this['contentId'] as String? ?? '';
//   String get parentId => this['parentId'] as String? ?? '';
//   String get title => this['title'] as String? ?? '';
//   String get path => this['path'] as String? ?? '{}';
//   DateTime? get createdAt => this['createdAt'] != null ? DateTime.tryParse(this['createdAt'] as String) : null;
//   DateTime? get lastModified => this['lastModified'] != null ? DateTime.tryParse(this['lastModified'] as String) : null;
//   String get description => this['description'] as String? ?? '';
//   int get courseContentTypeIndex => this['courseContentType'] as int? ?? 0;
//   int get fileSize => this['fileSize'] as int? ?? 0; // NEW: Add fileSize getter
//   String get metadataJson => this['metadataJson'] as String? ?? '{}';
// }
