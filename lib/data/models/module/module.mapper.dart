// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'module.dart';

class ModuleMapper extends ClassMapperBase<Module> {
  ModuleMapper._();

  static ModuleMapper? _instance;
  static ModuleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModuleMapper._());
      ModuleMetadataMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Module';

  static int _$id(Module v) => v.id;
  static const Field<Module, int> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: Isar.autoIncrement,
  );
  static String _$uid(Module v) => v.uid;
  static const Field<Module, String> _f$uid = Field('uid', _$uid);
  static String _$parentId(Module v) => v.parentId;
  static const Field<Module, String> _f$parentId = Field(
    'parentId',
    _$parentId,
  );
  static String _$title(Module v) => v.title;
  static const Field<Module, String> _f$title = Field('title', _$title);
  static String _$description(Module v) => v.description;
  static const Field<Module, String> _f$description = Field(
    'description',
    _$description,
  );
  static DateTime _$createdAt(Module v) => v.createdAt;
  static const Field<Module, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime _$lastModified(Module v) => v.lastModified;
  static const Field<Module, DateTime> _f$lastModified = Field(
    'lastModified',
    _$lastModified,
  );
  static ModuleMetadata _$metadata(Module v) => v.metadata;
  static const Field<Module, ModuleMetadata> _f$metadata = Field(
    'metadata',
    _$metadata,
  );
  static IsarLinks<ModuleContent> _$contents(Module v) => v.contents;
  static const Field<Module, IsarLinks<ModuleContent>> _f$contents = Field(
    'contents',
    _$contents,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Module> fields = const {
    #id: _f$id,
    #uid: _f$uid,
    #parentId: _f$parentId,
    #title: _f$title,
    #description: _f$description,
    #createdAt: _f$createdAt,
    #lastModified: _f$lastModified,
    #metadata: _f$metadata,
    #contents: _f$contents,
  };

  static Module _instantiate(DecodingData data) {
    return Module(
      id: data.dec(_f$id),
      uid: data.dec(_f$uid),
      parentId: data.dec(_f$parentId),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      createdAt: data.dec(_f$createdAt),
      lastModified: data.dec(_f$lastModified),
      metadata: data.dec(_f$metadata),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Module fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Module>(map);
  }

  static Module fromJson(String json) {
    return ensureInitialized().decodeJson<Module>(json);
  }
}

mixin ModuleMappable {
  String toJson() {
    return ModuleMapper.ensureInitialized().encodeJson<Module>(this as Module);
  }

  Map<String, dynamic> toMap() {
    return ModuleMapper.ensureInitialized().encodeMap<Module>(this as Module);
  }

  ModuleCopyWith<Module, Module, Module> get copyWith =>
      _ModuleCopyWithImpl<Module, Module>(this as Module, $identity, $identity);
  @override
  String toString() {
    return ModuleMapper.ensureInitialized().stringifyValue(this as Module);
  }

  @override
  bool operator ==(Object other) {
    return ModuleMapper.ensureInitialized().equalsValue(this as Module, other);
  }

  @override
  int get hashCode {
    return ModuleMapper.ensureInitialized().hashValue(this as Module);
  }
}

extension ModuleValueCopy<$R, $Out> on ObjectCopyWith<$R, Module, $Out> {
  ModuleCopyWith<$R, Module, $Out> get $asModule =>
      $base.as((v, t, t2) => _ModuleCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ModuleCopyWith<$R, $In extends Module, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ModuleMetadataCopyWith<$R, ModuleMetadata, ModuleMetadata> get metadata;
  $R call({
    int? id,
    String? uid,
    String? parentId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    ModuleMetadata? metadata,
  });
  ModuleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ModuleCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Module, $Out>
    implements ModuleCopyWith<$R, Module, $Out> {
  _ModuleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Module> $mapper = ModuleMapper.ensureInitialized();
  @override
  ModuleMetadataCopyWith<$R, ModuleMetadata, ModuleMetadata> get metadata =>
      $value.metadata.copyWith.$chain((v) => call(metadata: v));
  @override
  $R call({
    int? id,
    String? uid,
    String? parentId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    ModuleMetadata? metadata,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (uid != null) #uid: uid,
      if (parentId != null) #parentId: parentId,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (createdAt != null) #createdAt: createdAt,
      if (lastModified != null) #lastModified: lastModified,
      if (metadata != null) #metadata: metadata,
    }),
  );
  @override
  Module $make(CopyWithData data) => Module(
    id: data.get(#id, or: $value.id),
    uid: data.get(#uid, or: $value.uid),
    parentId: data.get(#parentId, or: $value.parentId),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    lastModified: data.get(#lastModified, or: $value.lastModified),
    metadata: data.get(#metadata, or: $value.metadata),
  );

  @override
  ModuleCopyWith<$R2, Module, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ModuleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

