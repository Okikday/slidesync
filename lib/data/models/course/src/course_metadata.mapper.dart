// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'course_metadata.dart';

class CourseMetadataMapper extends ClassMapperBase<CourseMetadata> {
  CourseMetadataMapper._();

  static CourseMetadataMapper? _instance;
  static CourseMetadataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CourseMetadataMapper._());
      FilePathMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CourseMetadata';

  static String? _$author(CourseMetadata v) => v.author;
  static const Field<CourseMetadata, String> _f$author = Field(
    'author',
    _$author,
    opt: true,
  );
  static FilePath? _$thumbnail(CourseMetadata v) => v.thumbnail;
  static const Field<CourseMetadata, FilePath> _f$thumbnail = Field(
    'thumbnail',
    _$thumbnail,
    opt: true,
  );
  static String? _$rawColor(CourseMetadata v) => v.rawColor;
  static const Field<CourseMetadata, String> _f$rawColor = Field(
    'rawColor',
    _$rawColor,
    opt: true,
  );

  @override
  final MappableFields<CourseMetadata> fields = const {
    #author: _f$author,
    #thumbnail: _f$thumbnail,
    #rawColor: _f$rawColor,
  };

  static CourseMetadata _instantiate(DecodingData data) {
    return CourseMetadata(
      author: data.dec(_f$author),
      thumbnail: data.dec(_f$thumbnail),
      rawColor: data.dec(_f$rawColor),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CourseMetadata fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CourseMetadata>(map);
  }

  static CourseMetadata fromJson(String json) {
    return ensureInitialized().decodeJson<CourseMetadata>(json);
  }
}

mixin CourseMetadataMappable {
  String toJson() {
    return CourseMetadataMapper.ensureInitialized().encodeJson<CourseMetadata>(
      this as CourseMetadata,
    );
  }

  Map<String, dynamic> toMap() {
    return CourseMetadataMapper.ensureInitialized().encodeMap<CourseMetadata>(
      this as CourseMetadata,
    );
  }

  CourseMetadataCopyWith<CourseMetadata, CourseMetadata, CourseMetadata>
  get copyWith => _CourseMetadataCopyWithImpl<CourseMetadata, CourseMetadata>(
    this as CourseMetadata,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CourseMetadataMapper.ensureInitialized().stringifyValue(
      this as CourseMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return CourseMetadataMapper.ensureInitialized().equalsValue(
      this as CourseMetadata,
      other,
    );
  }

  @override
  int get hashCode {
    return CourseMetadataMapper.ensureInitialized().hashValue(
      this as CourseMetadata,
    );
  }
}

extension CourseMetadataValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CourseMetadata, $Out> {
  CourseMetadataCopyWith<$R, CourseMetadata, $Out> get $asCourseMetadata =>
      $base.as((v, t, t2) => _CourseMetadataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CourseMetadataCopyWith<$R, $In extends CourseMetadata, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  FilePathCopyWith<$R, FilePath, FilePath>? get thumbnail;
  $R call({String? author, FilePath? thumbnail, String? rawColor});
  CourseMetadataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CourseMetadataCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CourseMetadata, $Out>
    implements CourseMetadataCopyWith<$R, CourseMetadata, $Out> {
  _CourseMetadataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CourseMetadata> $mapper =
      CourseMetadataMapper.ensureInitialized();
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
  CourseMetadata $make(CopyWithData data) => CourseMetadata(
    author: data.get(#author, or: $value.author),
    thumbnail: data.get(#thumbnail, or: $value.thumbnail),
    rawColor: data.get(#rawColor, or: $value.rawColor),
  );

  @override
  CourseMetadataCopyWith<$R2, CourseMetadata, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CourseMetadataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

