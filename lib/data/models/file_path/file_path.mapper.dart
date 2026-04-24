// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'file_path.dart';

class FilePathMapper extends ClassMapperBase<FilePath> {
  FilePathMapper._();

  static FilePathMapper? _instance;
  static FilePathMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FilePathMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FilePath';

  static String? _$url(FilePath v) => v.url;
  static const Field<FilePath, String> _f$url = Field('url', _$url, opt: true);
  static String? _$local(FilePath v) => v.local;
  static const Field<FilePath, String> _f$local = Field(
    'local',
    _$local,
    opt: true,
  );

  @override
  final MappableFields<FilePath> fields = const {
    #url: _f$url,
    #local: _f$local,
  };

  static FilePath _instantiate(DecodingData data) {
    return FilePath(url: data.dec(_f$url), local: data.dec(_f$local));
  }

  @override
  final Function instantiate = _instantiate;

  static FilePath fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FilePath>(map);
  }

  static FilePath fromJson(String json) {
    return ensureInitialized().decodeJson<FilePath>(json);
  }
}

mixin FilePathMappable {
  String toJson() {
    return FilePathMapper.ensureInitialized().encodeJson<FilePath>(
      this as FilePath,
    );
  }

  Map<String, dynamic> toMap() {
    return FilePathMapper.ensureInitialized().encodeMap<FilePath>(
      this as FilePath,
    );
  }

  FilePathCopyWith<FilePath, FilePath, FilePath> get copyWith =>
      _FilePathCopyWithImpl<FilePath, FilePath>(
        this as FilePath,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FilePathMapper.ensureInitialized().stringifyValue(this as FilePath);
  }

  @override
  bool operator ==(Object other) {
    return FilePathMapper.ensureInitialized().equalsValue(
      this as FilePath,
      other,
    );
  }

  @override
  int get hashCode {
    return FilePathMapper.ensureInitialized().hashValue(this as FilePath);
  }
}

extension FilePathValueCopy<$R, $Out> on ObjectCopyWith<$R, FilePath, $Out> {
  FilePathCopyWith<$R, FilePath, $Out> get $asFilePath =>
      $base.as((v, t, t2) => _FilePathCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FilePathCopyWith<$R, $In extends FilePath, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? url, String? local});
  FilePathCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FilePathCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FilePath, $Out>
    implements FilePathCopyWith<$R, FilePath, $Out> {
  _FilePathCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FilePath> $mapper =
      FilePathMapper.ensureInitialized();
  @override
  $R call({Object? url = $none, Object? local = $none}) => $apply(
    FieldCopyWithData({
      if (url != $none) #url: url,
      if (local != $none) #local: local,
    }),
  );
  @override
  FilePath $make(CopyWithData data) => FilePath(
    url: data.get(#url, or: $value.url),
    local: data.get(#local, or: $value.local),
  );

  @override
  FilePathCopyWith<$R2, FilePath, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FilePathCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

