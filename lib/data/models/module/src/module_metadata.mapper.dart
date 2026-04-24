// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'module_metadata.dart';

class ModuleMetadataMapper extends ClassMapperBase<ModuleMetadata> {
  ModuleMetadataMapper._();

  static ModuleMetadataMapper? _instance;
  static ModuleMetadataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModuleMetadataMapper._());
      FilePathMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ModuleMetadata';

  static String? _$author(ModuleMetadata v) => v.author;
  static const Field<ModuleMetadata, String> _f$author = Field(
    'author',
    _$author,
    opt: true,
  );
  static FilePath? _$thumbnail(ModuleMetadata v) => v.thumbnail;
  static const Field<ModuleMetadata, FilePath> _f$thumbnail = Field(
    'thumbnail',
    _$thumbnail,
    opt: true,
  );
  static String? _$rawColor(ModuleMetadata v) => v.rawColor;
  static const Field<ModuleMetadata, String> _f$rawColor = Field(
    'rawColor',
    _$rawColor,
    opt: true,
  );

  @override
  final MappableFields<ModuleMetadata> fields = const {
    #author: _f$author,
    #thumbnail: _f$thumbnail,
    #rawColor: _f$rawColor,
  };

  static ModuleMetadata _instantiate(DecodingData data) {
    return ModuleMetadata(
      author: data.dec(_f$author),
      thumbnail: data.dec(_f$thumbnail),
      rawColor: data.dec(_f$rawColor),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ModuleMetadata fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ModuleMetadata>(map);
  }

  static ModuleMetadata fromJson(String json) {
    return ensureInitialized().decodeJson<ModuleMetadata>(json);
  }
}

mixin ModuleMetadataMappable {
  String toJson() {
    return ModuleMetadataMapper.ensureInitialized().encodeJson<ModuleMetadata>(
      this as ModuleMetadata,
    );
  }

  Map<String, dynamic> toMap() {
    return ModuleMetadataMapper.ensureInitialized().encodeMap<ModuleMetadata>(
      this as ModuleMetadata,
    );
  }

  ModuleMetadataCopyWith<ModuleMetadata, ModuleMetadata, ModuleMetadata>
  get copyWith => _ModuleMetadataCopyWithImpl<ModuleMetadata, ModuleMetadata>(
    this as ModuleMetadata,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ModuleMetadataMapper.ensureInitialized().stringifyValue(
      this as ModuleMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return ModuleMetadataMapper.ensureInitialized().equalsValue(
      this as ModuleMetadata,
      other,
    );
  }

  @override
  int get hashCode {
    return ModuleMetadataMapper.ensureInitialized().hashValue(
      this as ModuleMetadata,
    );
  }
}

extension ModuleMetadataValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ModuleMetadata, $Out> {
  ModuleMetadataCopyWith<$R, ModuleMetadata, $Out> get $asModuleMetadata =>
      $base.as((v, t, t2) => _ModuleMetadataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ModuleMetadataCopyWith<$R, $In extends ModuleMetadata, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  FilePathCopyWith<$R, FilePath, FilePath>? get thumbnail;
  $R call({String? author, FilePath? thumbnail, String? rawColor});
  ModuleMetadataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ModuleMetadataCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ModuleMetadata, $Out>
    implements ModuleMetadataCopyWith<$R, ModuleMetadata, $Out> {
  _ModuleMetadataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ModuleMetadata> $mapper =
      ModuleMetadataMapper.ensureInitialized();
  @override
  FilePathCopyWith<$R, FilePath, FilePath>? get thumbnail =>
      $value.thumbnail?.copyWith.$chain((v) => call(thumbnail: v));
  @override
  $R call({
    Object? author = $none,
    Object? thumbnail = $none,
    Object? rawColor = $none,
  }) => $apply(
    FieldCopyWithData({
      if (author != $none) #author: author,
      if (thumbnail != $none) #thumbnail: thumbnail,
      if (rawColor != $none) #rawColor: rawColor,
    }),
  );
  @override
  ModuleMetadata $make(CopyWithData data) => ModuleMetadata(
    author: data.get(#author, or: $value.author),
    thumbnail: data.get(#thumbnail, or: $value.thumbnail),
    rawColor: data.get(#rawColor, or: $value.rawColor),
  );

  @override
  ModuleMetadataCopyWith<$R2, ModuleMetadata, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ModuleMetadataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

