part of 'module_content.dart';

extension CourseContentExtension on ModuleContent {
  String get collectionId => parentId;

  String get contentId => uid;
  set contentId(String value) => uid = value;

  String get metadataJson => metadata.toJson();
  set metadataJson(String value) => metadata = ModuleContentMetadata.fromJson(value);

  String get previewPath => metadata.thumbnail?.local ?? '';
  String get thumbnailPath => previewPath;
  FilePath get thumbnailDetails => metadata.thumbnail ?? FilePath();
}

// extension CourseContentMapX on Map<String, dynamic> {
//   int get id => this['id'] as int? ?? -1;
//   String get xxh3Hash => this['xxh3Hash'] as String? ?? '';
//   String get contentId => this['contentId'] as String? ?? '';
//   String get parentId => this['parentId'] as String? ?? '';
//   String get title => this['title'] as String? ?? '';
//   String get path => this['path'] as String? ?? '{}';
//   DateTime? get createdAt => this['createdAt'] != null ? DateTime.tryParse(this['createdAt'] as String) : null;
//   DateTime? get lastModified => this['lastModified'] != null ? DateTime.tryParse(this['lastModified'] as String) : null;
//   String get description => this['description'] as String? ?? '';
//   int get courseContentTypeIndex => this['type'] as int? ?? 0;
//   int get fileSize => this['fileSize'] as int? ?? 0; // NEW: Add fileSize getter
//   String get metadataJson => this['metadataJson'] as String? ?? '{}';
// }
