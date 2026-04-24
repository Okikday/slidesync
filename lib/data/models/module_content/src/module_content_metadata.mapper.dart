// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'module_content_metadata.dart';

class ModuleContentMetadataMapper
    extends ClassMapperBase<ModuleContentMetadata> {
  ModuleContentMetadataMapper._();

  static ModuleContentMetadataMapper? _instance;
  static ModuleContentMetadataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModuleContentMetadataMapper._());
      FilePathMapper.ensureInitialized();
      ContentOriginMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ModuleContentMetadata';

  static String? _$originalFileName(ModuleContentMetadata v) =>
      v.originalFileName;
  static const Field<ModuleContentMetadata, String> _f$originalFileName = Field(
    'originalFileName',
    _$originalFileName,
    opt: true,
  );
  static FilePath? _$thumbnail(ModuleContentMetadata v) => v.thumbnail;
  static const Field<ModuleContentMetadata, FilePath> _f$thumbnail = Field(
    'thumbnail',
    _$thumbnail,
    opt: true,
  );
  static ContentOrigin _$contentOrigin(ModuleContentMetadata v) =>
      v.contentOrigin;
  static const Field<ModuleContentMetadata, ContentOrigin> _f$contentOrigin =
      Field(
        'contentOrigin',
        _$contentOrigin,
        opt: true,
        def: ContentOrigin.none,
      );
  static String? _$groupId(ModuleContentMetadata v) => v.groupId;
  static const Field<ModuleContentMetadata, String> _f$groupId = Field(
    'groupId',
    _$groupId,
    opt: true,
  );
  static String? _$author(ModuleContentMetadata v) => v.author;
  static const Field<ModuleContentMetadata, String> _f$author = Field(
    'author',
    _$author,
    opt: true,
  );
  static String? _$rawFieldsJson(ModuleContentMetadata v) => v.rawFieldsJson;
  static const Field<ModuleContentMetadata, String> _f$rawFieldsJson = Field(
    'rawFieldsJson',
    _$rawFieldsJson,
    opt: true,
  );

  @override
  final MappableFields<ModuleContentMetadata> fields = const {
    #originalFileName: _f$originalFileName,
    #thumbnail: _f$thumbnail,
    #contentOrigin: _f$contentOrigin,
    #groupId: _f$groupId,
    #author: _f$author,
    #rawFieldsJson: _f$rawFieldsJson,
  };

  static ModuleContentMetadata _instantiate(DecodingData data) {
    return ModuleContentMetadata(
      originalFileName: data.dec(_f$originalFileName),
      thumbnail: data.dec(_f$thumbnail),
      contentOrigin: data.dec(_f$contentOrigin),
      groupId: data.dec(_f$groupId),
      author: data.dec(_f$author),
      rawFieldsJson: data.dec(_f$rawFieldsJson),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ModuleContentMetadata fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ModuleContentMetadata>(map);
  }

  static ModuleContentMetadata fromJson(String json) {
    return ensureInitialized().decodeJson<ModuleContentMetadata>(json);
  }
}

mixin ModuleContentMetadataMappable {
  String toJson() {
    return ModuleContentMetadataMapper.ensureInitialized()
        .encodeJson<ModuleContentMetadata>(this as ModuleContentMetadata);
  }

  Map<String, dynamic> toMap() {
    return ModuleContentMetadataMapper.ensureInitialized()
        .encodeMap<ModuleContentMetadata>(this as ModuleContentMetadata);
  }

  ModuleContentMetadataCopyWith<
    ModuleContentMetadata,
    ModuleContentMetadata,
    ModuleContentMetadata
  >
  get copyWith =>
      _ModuleContentMetadataCopyWithImpl<
        ModuleContentMetadata,
        ModuleContentMetadata
      >(this as ModuleContentMetadata, $identity, $identity);
  @override
  String toString() {
    return ModuleContentMetadataMapper.ensureInitialized().stringifyValue(
      this as ModuleContentMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return ModuleContentMetadataMapper.ensureInitialized().equalsValue(
      this as ModuleContentMetadata,
      other,
    );
  }

  @override
  int get hashCode {
    return ModuleContentMetadataMapper.ensureInitialized().hashValue(
      this as ModuleContentMetadata,
    );
  }
}

extension ModuleContentMetadataValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ModuleContentMetadata, $Out> {
  ModuleContentMetadataCopyWith<$R, ModuleContentMetadata, $Out>
  get $asModuleContentMetadata => $base.as(
    (v, t, t2) => _ModuleContentMetadataCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ModuleContentMetadataCopyWith<
  $R,
  $In extends ModuleContentMetadata,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  FilePathCopyWith<$R, FilePath, FilePath>? get thumbnail;
  $R call({
    String? originalFileName,
    FilePath? thumbnail,
    ContentOrigin? contentOrigin,
    String? groupId,
    String? author,
    String? rawFieldsJson,
  });
  ModuleContentMetadataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ModuleContentMetadataCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ModuleContentMetadata, $Out>
    implements ModuleContentMetadataCopyWith<$R, ModuleContentMetadata, $Out> {
  _ModuleContentMetadataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ModuleContentMetadata> $mapper =
      ModuleContentMetadataMapper.ensureInitialized();
  @override
  FilePathCopyWith<$R, FilePath, FilePath>? get thumbnail =>
      $value.thumbnail?.copyWith.$chain((v) => call(thumbnail: v));
  @override
  $R call({
    Object? originalFileName = $none,
    Object? thumbnail = $none,
    ContentOrigin? contentOrigin,
    Object? groupId = $none,
    Object? author = $none,
    Object? rawFieldsJson = $none,
  }) => $apply(
    FieldCopyWithData({
      if (originalFileName != $none) #originalFileName: originalFileName,
      if (thumbnail != $none) #thumbnail: thumbnail,
      if (contentOrigin != null) #contentOrigin: contentOrigin,
      if (groupId != $none) #groupId: groupId,
      if (author != $none) #author: author,
      if (rawFieldsJson != $none) #rawFieldsJson: rawFieldsJson,
    }),
  );
  @override
  ModuleContentMetadata $make(CopyWithData data) => ModuleContentMetadata(
    originalFileName: data.get(#originalFileName, or: $value.originalFileName),
    thumbnail: data.get(#thumbnail, or: $value.thumbnail),
    contentOrigin: data.get(#contentOrigin, or: $value.contentOrigin),
    groupId: data.get(#groupId, or: $value.groupId),
    author: data.get(#author, or: $value.author),
    rawFieldsJson: data.get(#rawFieldsJson, or: $value.rawFieldsJson),
  );

  @override
  ModuleContentMetadataCopyWith<$R2, ModuleContentMetadata, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ModuleContentMetadataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

