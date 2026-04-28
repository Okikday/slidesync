import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:uuid/uuid.dart';

import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/module/src/module_metadata.dart';

export 'src/module_metadata.dart';

part 'module.mapper.dart';
part 'module.g.dart';

@MappableClass()
@Collection(ignore: {'copyWith'})
class Module with ModuleMappable {
  Id id;
  @Index(unique: true)
  String uid;
  @Index()
  String parentId;
  @Index(caseSensitive: false)
  String title;
  String description;
  DateTime createdAt;
  DateTime lastModified;
  ModuleMetadata metadata;

  final IsarLinks<ModuleContent> contents = IsarLinks<ModuleContent>();

  Module({
    this.id = Isar.autoIncrement,
    required this.uid,
    required this.parentId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.lastModified,
    required this.metadata,
  });

  static const fromJson = ModuleMapper.fromJson;

  static Module create({
    String? uid,
    String? parentId,
    String? title,
    String? description,
    DateTime? createdAt,
    ModuleMetadata? metadata,
  }) {
    final now = DateTime.now();
    return Module(
      uid: (uid == null || uid.isEmpty) ? const Uuid().v4() : uid,
      parentId: parentId ?? '',
      title: title ?? '',
      description: description ?? '',
      createdAt: createdAt ?? now,
      lastModified: now,
      metadata: metadata ?? ModuleMetadata.create(),
    );
  }

  static Module empty() => Module.create(uid: '_', title: '_');
}

extension ModuleExtension on Module {
  String get courseId => parentId;
}
