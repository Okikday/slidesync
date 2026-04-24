// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'module_content.dart';

class ModuleContentMapper extends ClassMapperBase<ModuleContent> {
  ModuleContentMapper._();

  static ModuleContentMapper? _instance;
  static ModuleContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModuleContentMapper._());
      FilePathMapper.ensureInitialized();
      ModuleContentMetadataMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ModuleContent';

  static int _$id(ModuleContent v) => v.id;
  static const Field<ModuleContent, int> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: Isar.autoIncrement,
  );
  static String _$uid(ModuleContent v) => v.uid;
  static const Field<ModuleContent, String> _f$uid = Field('uid', _$uid);
  static String _$xxh3Hash(ModuleContent v) => v.xxh3Hash;
  static const Field<ModuleContent, String> _f$xxh3Hash = Field(
    'xxh3Hash',
    _$xxh3Hash,
  );
  static String _$parentId(ModuleContent v) => v.parentId;
  static const Field<ModuleContent, String> _f$parentId = Field(
    'parentId',
    _$parentId,
  );
  static String _$title(ModuleContent v) => v.title;
  static const Field<ModuleContent, String> _f$title = Field('title', _$title);
  static String _$description(ModuleContent v) => v.description;
  static const Field<ModuleContent, String> _f$description = Field(
    'description',
    _$description,
  );
  static FilePath _$path(ModuleContent v) => v.path;
  static const Field<ModuleContent, FilePath> _f$path = Field('path', _$path);
  static DateTime _$createdAt(ModuleContent v) => v.createdAt;
  static const Field<ModuleContent, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime _$lastModified(ModuleContent v) => v.lastModified;
  static const Field<ModuleContent, DateTime> _f$lastModified = Field(
    'lastModified',
    _$lastModified,
  );
  static String _$typeRaw(ModuleContent v) => v.typeRaw;
  static const Field<ModuleContent, String> _f$typeRaw = Field(
    'typeRaw',
    _$typeRaw,
    opt: true,
    def: 'unknown',
  );
  static int _$fileSizeInBytes(ModuleContent v) => v.fileSizeInBytes;
  static const Field<ModuleContent, int> _f$fileSizeInBytes = Field(
    'fileSizeInBytes',
    _$fileSizeInBytes,
  );
  static ModuleContentMetadata? _$metadata(ModuleContent v) => v.metadata;
  static const Field<ModuleContent, ModuleContentMetadata> _f$metadata = Field(
    'metadata',
    _$metadata,
    opt: true,
  );

  @override
  final MappableFields<ModuleContent> fields = const {
    #id: _f$id,
    #uid: _f$uid,
    #xxh3Hash: _f$xxh3Hash,
    #parentId: _f$parentId,
    #title: _f$title,
    #description: _f$description,
    #path: _f$path,
    #createdAt: _f$createdAt,
    #lastModified: _f$lastModified,
    #typeRaw: _f$typeRaw,
    #fileSizeInBytes: _f$fileSizeInBytes,
    #metadata: _f$metadata,
  };

  static ModuleContent _instantiate(DecodingData data) {
    return ModuleContent(
      id: data.dec(_f$id),
      uid: data.dec(_f$uid),
      xxh3Hash: data.dec(_f$xxh3Hash),
      parentId: data.dec(_f$parentId),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      path: data.dec(_f$path),
      createdAt: data.dec(_f$createdAt),
      lastModified: data.dec(_f$lastModified),
      typeRaw: data.dec(_f$typeRaw),
      fileSizeInBytes: data.dec(_f$fileSizeInBytes),
      metadata: data.dec(_f$metadata),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ModuleContent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ModuleContent>(map);
  }

  static ModuleContent fromJson(String json) {
    return ensureInitialized().decodeJson<ModuleContent>(json);
  }
}

mixin ModuleContentMappable {
  String toJson() {
    return ModuleContentMapper.ensureInitialized().encodeJson<ModuleContent>(
      this as ModuleContent,
    );
  }

  Map<String, dynamic> toMap() {
    return ModuleContentMapper.ensureInitialized().encodeMap<ModuleContent>(
      this as ModuleContent,
    );
  }

  ModuleContentCopyWith<ModuleContent, ModuleContent, ModuleContent>
  get copyWith => _ModuleContentCopyWithImpl<ModuleContent, ModuleContent>(
    this as ModuleContent,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ModuleContentMapper.ensureInitialized().stringifyValue(
      this as ModuleContent,
    );
  }

  @override
  bool operator ==(Object other) {
    return ModuleContentMapper.ensureInitialized().equalsValue(
      this as ModuleContent,
      other,
    );
  }

  @override
  int get hashCode {
    return ModuleContentMapper.ensureInitialized().hashValue(
      this as ModuleContent,
    );
  }
}

extension ModuleContentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ModuleContent, $Out> {
  ModuleContentCopyWith<$R, ModuleContent, $Out> get $asModuleContent =>
      $base.as((v, t, t2) => _ModuleContentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ModuleContentCopyWith<$R, $In extends ModuleContent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  FilePathCopyWith<$R, FilePath, FilePath> get path;
  ModuleContentMetadataCopyWith<
    $R,
    ModuleContentMetadata,
    ModuleContentMetadata
  >?
  get metadata;
  $R call({
    int? id,
    String? uid,
    String? xxh3Hash,
    String? parentId,
    String? title,
    String? description,
    FilePath? path,
    DateTime? createdAt,
    DateTime? lastModified,
    String? typeRaw,
    int? fileSizeInBytes,
    ModuleContentMetadata? metadata,
  });
  ModuleContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ModuleContentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ModuleContent, $Out>
    implements ModuleContentCopyWith<$R, ModuleContent, $Out> {
  _ModuleContentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ModuleContent> $mapper =
      ModuleContentMapper.ensureInitialized();
  @override
  FilePathCopyWith<$R, FilePath, FilePath> get path =>
      $value.path.copyWith.$chain((v) => call(path: v));
  @override
  ModuleContentMetadataCopyWith<
    $R,
    ModuleContentMetadata,
    ModuleContentMetadata
  >?
  get metadata => $value.metadata?.copyWith.$chain((v) => call(metadata: v));
  @override
  $R call({
    int? id,
    String? uid,
    String? xxh3Hash,
    String? parentId,
    String? title,
    String? description,
    FilePath? path,
    DateTime? createdAt,
    DateTime? lastModified,
    String? typeRaw,
    int? fileSizeInBytes,
    Object? metadata = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (uid != null) #uid: uid,
      if (xxh3Hash != null) #xxh3Hash: xxh3Hash,
      if (parentId != null) #parentId: parentId,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (path != null) #path: path,
      if (createdAt != null) #createdAt: createdAt,
      if (lastModified != null) #lastModified: lastModified,
      if (typeRaw != null) #typeRaw: typeRaw,
      if (fileSizeInBytes != null) #fileSizeInBytes: fileSizeInBytes,
      if (metadata != $none) #metadata: metadata,
    }),
  );
  @override
  ModuleContent $make(CopyWithData data) => ModuleContent(
    id: data.get(#id, or: $value.id),
    uid: data.get(#uid, or: $value.uid),
    xxh3Hash: data.get(#xxh3Hash, or: $value.xxh3Hash),
    parentId: data.get(#parentId, or: $value.parentId),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    path: data.get(#path, or: $value.path),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    lastModified: data.get(#lastModified, or: $value.lastModified),
    typeRaw: data.get(#typeRaw, or: $value.typeRaw),
    fileSizeInBytes: data.get(#fileSizeInBytes, or: $value.fileSizeInBytes),
    metadata: data.get(#metadata, or: $value.metadata),
  );

  @override
  ModuleContentCopyWith<$R2, ModuleContent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ModuleContentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

