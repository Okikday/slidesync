import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/models/module_content/src/module_content_metadata.dart';

export 'src/module_content_metadata.dart';

part 'module_content.mapper.dart';
part 'module_content.g.dart';

@MappableClass()
@Collection(ignore: {'copyWith'})
class ModuleContent with ModuleContentMappable {
  Id id;
  @Index(unique: true)
  String uid;
  String xxh3Hash;
  @Index()
  String parentId;
  String title;
  String description;
  FilePath path;
  DateTime createdAt;
  DateTime lastModified;
  String typeRaw;
  int fileSizeInBytes;
  ModuleContentMetadata? metadata;

  ModuleContent({
    this.id = Isar.autoIncrement,
    required this.uid,
    required this.xxh3Hash,
    required this.parentId,
    required this.title,
    required this.description,
    required this.path,
    required this.createdAt,
    required this.lastModified,
    this.typeRaw = 'unknown',
    required this.fileSizeInBytes,
    this.metadata,
  });

  static const fromJson = ModuleContentMapper.fromJson;
  static const fromMap = ModuleContentMapper.fromMap;

  static ModuleContent create({
    String? uid,
    String? contentId,
    String? title,
    String? description,
    FilePath? path,
    ModuleContentType? type,
    String? parentId,
    int? fileSizeInBytes,
    ModuleContentMetadata? metadata,
    String? xxh3Hash,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    final now = DateTime.now();
    return ModuleContent(
      uid: uid ?? contentId ?? const Uuid().v4(),
      title: title ?? '',
      description: description ?? '',
      path: path ?? FilePath.empty(),
      typeRaw: (type ?? ModuleContentType.unknown).name,
      parentId: parentId ?? '',
      fileSizeInBytes: fileSizeInBytes ?? 0,
      xxh3Hash: xxh3Hash ?? '',
      metadata: metadata,
      createdAt: createdAt ?? now,
      lastModified: lastModified ?? now,
    );
  }
}

extension CourseContentExtension on ModuleContent {
  ModuleContentType get type =>
      ModuleContentType.values.firstWhere((e) => e.name == typeRaw, orElse: () => ModuleContentType.unknown);

  set type(ModuleContentType value) => typeRaw = value.name;

  String get collectionId => parentId;

  String get contentId => uid;
  set contentId(String value) => uid = value;

  String get metadataJson => jsonEncode(metadata?.toJson() ?? <String, dynamic>{});
  set metadataJson(String value) => metadata = ModuleContentMetadata.fromJson(jsonDecode(value));

  String get previewPath => metadata?.thumbnail?.local ?? '';
  String get thumbnailPath => previewPath;
  FilePath get thumbnailDetails => metadata?.thumbnail ?? FilePath();
}

final defaultContent = ModuleContent.create(
  xxh3Hash: '_',
  parentId: '_',
  title: '_',
  fileSizeInBytes: 0,
  path: FilePath(),
  type: ModuleContentType.unknown,
);
