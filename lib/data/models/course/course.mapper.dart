// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'course.dart';

class CourseMapper extends ClassMapperBase<Course> {
  CourseMapper._();

  static CourseMapper? _instance;
  static CourseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CourseMapper._());
      CourseMetadataMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Course';

  static int _$id(Course v) => v.id;
  static const Field<Course, int> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: Isar.autoIncrement,
  );
  static String _$uid(Course v) => v.uid;
  static const Field<Course, String> _f$uid = Field('uid', _$uid);
  static String _$title(Course v) => v.title;
  static const Field<Course, String> _f$title = Field('title', _$title);
  static String _$description(Course v) => v.description;
  static const Field<Course, String> _f$description = Field(
    'description',
    _$description,
  );
  static DateTime _$createdAt(Course v) => v.createdAt;
  static const Field<Course, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime _$lastModified(Course v) => v.lastModified;
  static const Field<Course, DateTime> _f$lastModified = Field(
    'lastModified',
    _$lastModified,
  );
  static CourseMetadata _$metadata(Course v) => v.metadata;
  static const Field<Course, CourseMetadata> _f$metadata = Field(
    'metadata',
    _$metadata,
  );
  static IsarLinks<Module> _$modules(Course v) => v.modules;
  static const Field<Course, IsarLinks<Module>> _f$modules = Field(
    'modules',
    _$modules,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Course> fields = const {
    #id: _f$id,
    #uid: _f$uid,
    #title: _f$title,
    #description: _f$description,
    #createdAt: _f$createdAt,
    #lastModified: _f$lastModified,
    #metadata: _f$metadata,
    #modules: _f$modules,
  };

  static Course _instantiate(DecodingData data) {
    return Course(
      id: data.dec(_f$id),
      uid: data.dec(_f$uid),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      createdAt: data.dec(_f$createdAt),
      lastModified: data.dec(_f$lastModified),
      metadata: data.dec(_f$metadata),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Course fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Course>(map);
  }

  static Course fromJson(String json) {
    return ensureInitialized().decodeJson<Course>(json);
  }
}

mixin CourseMappable {
  String toJson() {
    return CourseMapper.ensureInitialized().encodeJson<Course>(this as Course);
  }

  Map<String, dynamic> toMap() {
    return CourseMapper.ensureInitialized().encodeMap<Course>(this as Course);
  }

  CourseCopyWith<Course, Course, Course> get copyWith =>
      _CourseCopyWithImpl<Course, Course>(this as Course, $identity, $identity);
  @override
  String toString() {
    return CourseMapper.ensureInitialized().stringifyValue(this as Course);
  }

  @override
  bool operator ==(Object other) {
    return CourseMapper.ensureInitialized().equalsValue(this as Course, other);
  }

  @override
  int get hashCode {
    return CourseMapper.ensureInitialized().hashValue(this as Course);
  }
}

extension CourseValueCopy<$R, $Out> on ObjectCopyWith<$R, Course, $Out> {
  CourseCopyWith<$R, Course, $Out> get $asCourse =>
      $base.as((v, t, t2) => _CourseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CourseCopyWith<$R, $In extends Course, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  CourseMetadataCopyWith<$R, CourseMetadata, CourseMetadata> get metadata;
  $R call({
    int? id,
    String? uid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    CourseMetadata? metadata,
  });
  CourseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CourseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Course, $Out>
    implements CourseCopyWith<$R, Course, $Out> {
  _CourseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Course> $mapper = CourseMapper.ensureInitialized();
  @override
  CourseMetadataCopyWith<$R, CourseMetadata, CourseMetadata> get metadata =>
      $value.metadata.copyWith.$chain((v) => call(metadata: v));
  @override
  $R call({
    int? id,
    String? uid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    CourseMetadata? metadata,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (uid != null) #uid: uid,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (createdAt != null) #createdAt: createdAt,
      if (lastModified != null) #lastModified: lastModified,
      if (metadata != null) #metadata: metadata,
    }),
  );
  @override
  Course $make(CopyWithData data) => Course(
    id: data.get(#id, or: $value.id),
    uid: data.get(#uid, or: $value.uid),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    lastModified: data.get(#lastModified, or: $value.lastModified),
    metadata: data.get(#metadata, or: $value.metadata),
  );

  @override
  CourseCopyWith<$R2, Course, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CourseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

