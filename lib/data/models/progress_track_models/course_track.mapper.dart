// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'course_track.dart';

class CourseTrackMapper extends ClassMapperBase<CourseTrack> {
  CourseTrackMapper._();

  static CourseTrackMapper? _instance;
  static CourseTrackMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CourseTrackMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CourseTrack';

  static int _$id(CourseTrack v) => v.id;
  static const Field<CourseTrack, int> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: Isar.autoIncrement,
  );
  static String _$uid(CourseTrack v) => v.uid;
  static const Field<CourseTrack, String> _f$uid = Field('uid', _$uid);
  static String _$title(CourseTrack v) => v.title;
  static const Field<CourseTrack, String> _f$title = Field('title', _$title);
  static String _$description(CourseTrack v) => v.description;
  static const Field<CourseTrack, String> _f$description = Field(
    'description',
    _$description,
  );
  static double _$progress(CourseTrack v) => v.progress;
  static const Field<CourseTrack, double> _f$progress = Field(
    'progress',
    _$progress,
  );
  static String? _$extraDetail(CourseTrack v) => v.extraDetail;
  static const Field<CourseTrack, String> _f$extraDetail = Field(
    'extraDetail',
    _$extraDetail,
  );
  static IsarLinks<ContentTrack> _$contentTracks(CourseTrack v) =>
      v.contentTracks;
  static const Field<CourseTrack, IsarLinks<ContentTrack>> _f$contentTracks =
      Field('contentTracks', _$contentTracks, mode: FieldMode.member);

  @override
  final MappableFields<CourseTrack> fields = const {
    #id: _f$id,
    #uid: _f$uid,
    #title: _f$title,
    #description: _f$description,
    #progress: _f$progress,
    #extraDetail: _f$extraDetail,
    #contentTracks: _f$contentTracks,
  };

  static CourseTrack _instantiate(DecodingData data) {
    return CourseTrack(
      id: data.dec(_f$id),
      uid: data.dec(_f$uid),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      progress: data.dec(_f$progress),
      extraDetail: data.dec(_f$extraDetail),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CourseTrack fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CourseTrack>(map);
  }

  static CourseTrack fromJson(String json) {
    return ensureInitialized().decodeJson<CourseTrack>(json);
  }
}

mixin CourseTrackMappable {
  String toJson() {
    return CourseTrackMapper.ensureInitialized().encodeJson<CourseTrack>(
      this as CourseTrack,
    );
  }

  Map<String, dynamic> toMap() {
    return CourseTrackMapper.ensureInitialized().encodeMap<CourseTrack>(
      this as CourseTrack,
    );
  }

  CourseTrackCopyWith<CourseTrack, CourseTrack, CourseTrack> get copyWith =>
      _CourseTrackCopyWithImpl<CourseTrack, CourseTrack>(
        this as CourseTrack,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CourseTrackMapper.ensureInitialized().stringifyValue(
      this as CourseTrack,
    );
  }

  @override
  bool operator ==(Object other) {
    return CourseTrackMapper.ensureInitialized().equalsValue(
      this as CourseTrack,
      other,
    );
  }

  @override
  int get hashCode {
    return CourseTrackMapper.ensureInitialized().hashValue(this as CourseTrack);
  }
}

extension CourseTrackValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CourseTrack, $Out> {
  CourseTrackCopyWith<$R, CourseTrack, $Out> get $asCourseTrack =>
      $base.as((v, t, t2) => _CourseTrackCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CourseTrackCopyWith<$R, $In extends CourseTrack, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? uid,
    String? title,
    String? description,
    double? progress,
    String? extraDetail,
  });
  CourseTrackCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CourseTrackCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CourseTrack, $Out>
    implements CourseTrackCopyWith<$R, CourseTrack, $Out> {
  _CourseTrackCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CourseTrack> $mapper =
      CourseTrackMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? uid,
    String? title,
    String? description,
    double? progress,
    Object? extraDetail = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (uid != null) #uid: uid,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (progress != null) #progress: progress,
      if (extraDetail != $none) #extraDetail: extraDetail,
    }),
  );
  @override
  CourseTrack $make(CopyWithData data) => CourseTrack(
    id: data.get(#id, or: $value.id),
    uid: data.get(#uid, or: $value.uid),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    progress: data.get(#progress, or: $value.progress),
    extraDetail: data.get(#extraDetail, or: $value.extraDetail),
  );

  @override
  CourseTrackCopyWith<$R2, CourseTrack, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CourseTrackCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

