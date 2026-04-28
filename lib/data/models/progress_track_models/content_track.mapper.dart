// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'content_track.dart';

class ContentTrackMapper extends ClassMapperBase<ContentTrack> {
  ContentTrackMapper._();

  static ContentTrackMapper? _instance;
  static ContentTrackMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContentTrackMapper._());
      FilePathMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ContentTrack';

  static int _$id(ContentTrack v) => v.id;
  static const Field<ContentTrack, int> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: Isar.autoIncrement,
  );
  static String _$uid(ContentTrack v) => v.uid;
  static const Field<ContentTrack, String> _f$uid = Field('uid', _$uid);
  static String _$courseId(ContentTrack v) => v.courseId;
  static const Field<ContentTrack, String> _f$courseId = Field(
    'courseId',
    _$courseId,
  );
  static ModuleContentType _$type(ContentTrack v) => v.type;
  static const Field<ContentTrack, ModuleContentType> _f$type = Field(
    'type',
    _$type,
  );
  static String _$title(ContentTrack v) => v.title;
  static const Field<ContentTrack, String> _f$title = Field('title', _$title);
  static String _$description(ContentTrack v) => v.description;
  static const Field<ContentTrack, String> _f$description = Field(
    'description',
    _$description,
  );
  static double _$progress(ContentTrack v) => v.progress;
  static const Field<ContentTrack, double> _f$progress = Field(
    'progress',
    _$progress,
  );
  static String? _$extraDetail(ContentTrack v) => v.extraDetail;
  static const Field<ContentTrack, String> _f$extraDetail = Field(
    'extraDetail',
    _$extraDetail,
  );
  static List<String> _$pages(ContentTrack v) => v.pages;
  static const Field<ContentTrack, List<String>> _f$pages = Field(
    'pages',
    _$pages,
  );
  static DateTime? _$lastRead(ContentTrack v) => v.lastRead;
  static const Field<ContentTrack, DateTime> _f$lastRead = Field(
    'lastRead',
    _$lastRead,
  );
  static FilePath _$thumbnail(ContentTrack v) => v.thumbnail;
  static const Field<ContentTrack, FilePath> _f$thumbnail = Field(
    'thumbnail',
    _$thumbnail,
  );

  @override
  final MappableFields<ContentTrack> fields = const {
    #id: _f$id,
    #uid: _f$uid,
    #courseId: _f$courseId,
    #type: _f$type,
    #title: _f$title,
    #description: _f$description,
    #progress: _f$progress,
    #extraDetail: _f$extraDetail,
    #pages: _f$pages,
    #lastRead: _f$lastRead,
    #thumbnail: _f$thumbnail,
  };

  static ContentTrack _instantiate(DecodingData data) {
    return ContentTrack(
      id: data.dec(_f$id),
      uid: data.dec(_f$uid),
      courseId: data.dec(_f$courseId),
      type: data.dec(_f$type),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      progress: data.dec(_f$progress),
      extraDetail: data.dec(_f$extraDetail),
      pages: data.dec(_f$pages),
      lastRead: data.dec(_f$lastRead),
      thumbnail: data.dec(_f$thumbnail),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ContentTrack fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ContentTrack>(map);
  }

  static ContentTrack fromJson(String json) {
    return ensureInitialized().decodeJson<ContentTrack>(json);
  }
}

mixin ContentTrackMappable {
  String toJson() {
    return ContentTrackMapper.ensureInitialized().encodeJson<ContentTrack>(
      this as ContentTrack,
    );
  }

  Map<String, dynamic> toMap() {
    return ContentTrackMapper.ensureInitialized().encodeMap<ContentTrack>(
      this as ContentTrack,
    );
  }

  ContentTrackCopyWith<ContentTrack, ContentTrack, ContentTrack> get copyWith =>
      _ContentTrackCopyWithImpl<ContentTrack, ContentTrack>(
        this as ContentTrack,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ContentTrackMapper.ensureInitialized().stringifyValue(
      this as ContentTrack,
    );
  }

  @override
  bool operator ==(Object other) {
    return ContentTrackMapper.ensureInitialized().equalsValue(
      this as ContentTrack,
      other,
    );
  }

  @override
  int get hashCode {
    return ContentTrackMapper.ensureInitialized().hashValue(
      this as ContentTrack,
    );
  }
}

extension ContentTrackValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ContentTrack, $Out> {
  ContentTrackCopyWith<$R, ContentTrack, $Out> get $asContentTrack =>
      $base.as((v, t, t2) => _ContentTrackCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ContentTrackCopyWith<$R, $In extends ContentTrack, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get pages;
  FilePathCopyWith<$R, FilePath, FilePath> get thumbnail;
  $R call({
    int? id,
    String? uid,
    String? courseId,
    ModuleContentType? type,
    String? title,
    String? description,
    double? progress,
    String? extraDetail,
    List<String>? pages,
    DateTime? lastRead,
    FilePath? thumbnail,
  });
  ContentTrackCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ContentTrackCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ContentTrack, $Out>
    implements ContentTrackCopyWith<$R, ContentTrack, $Out> {
  _ContentTrackCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ContentTrack> $mapper =
      ContentTrackMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get pages =>
      ListCopyWith(
        $value.pages,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(pages: v),
      );
  @override
  FilePathCopyWith<$R, FilePath, FilePath> get thumbnail =>
      $value.thumbnail.copyWith.$chain((v) => call(thumbnail: v));
  @override
  $R call({
    int? id,
    String? uid,
    String? courseId,
    ModuleContentType? type,
    String? title,
    String? description,
    double? progress,
    Object? extraDetail = $none,
    List<String>? pages,
    Object? lastRead = $none,
    FilePath? thumbnail,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (uid != null) #uid: uid,
      if (courseId != null) #courseId: courseId,
      if (type != null) #type: type,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (progress != null) #progress: progress,
      if (extraDetail != $none) #extraDetail: extraDetail,
      if (pages != null) #pages: pages,
      if (lastRead != $none) #lastRead: lastRead,
      if (thumbnail != null) #thumbnail: thumbnail,
    }),
  );
  @override
  ContentTrack $make(CopyWithData data) => ContentTrack(
    id: data.get(#id, or: $value.id),
    uid: data.get(#uid, or: $value.uid),
    courseId: data.get(#courseId, or: $value.courseId),
    type: data.get(#type, or: $value.type),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    progress: data.get(#progress, or: $value.progress),
    extraDetail: data.get(#extraDetail, or: $value.extraDetail),
    pages: data.get(#pages, or: $value.pages),
    lastRead: data.get(#lastRead, or: $value.lastRead),
    thumbnail: data.get(#thumbnail, or: $value.thumbnail),
  );

  @override
  ContentTrackCopyWith<$R2, ContentTrack, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ContentTrackCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

