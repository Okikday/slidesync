// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_track.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCourseTrackCollection on Isar {
  IsarCollection<CourseTrack> get courseTracks => this.collection();
}

const CourseTrackSchema = CollectionSchema(
  name: r'CourseTrack',
  id: -7943013626968881460,
  properties: {
    r'additionalDetail': PropertySchema(
      id: 0,
      name: r'additionalDetail',
      type: IsarType.string,
    ),
    r'courseId': PropertySchema(
      id: 1,
      name: r'courseId',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 3,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'metadataJson': PropertySchema(
      id: 4,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 5,
      name: r'progress',
      type: IsarType.double,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _courseTrackEstimateSize,
  serialize: _courseTrackSerialize,
  deserialize: _courseTrackDeserialize,
  deserializeProp: _courseTrackDeserializeProp,
  idName: r'id',
  indexes: {
    r'courseId': IndexSchema(
      id: -4937057111615935929,
      name: r'courseId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'courseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'contentTracks': LinkSchema(
      id: -2109476058262741982,
      name: r'contentTracks',
      target: r'ContentTrack',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _courseTrackGetId,
  getLinks: _courseTrackGetLinks,
  attach: _courseTrackAttach,
  version: '3.1.0+1',
);

int _courseTrackEstimateSize(
  CourseTrack object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.additionalDetail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.courseId.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metadataJson.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _courseTrackSerialize(
  CourseTrack object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.additionalDetail);
  writer.writeString(offsets[1], object.courseId);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.hashCode);
  writer.writeString(offsets[4], object.metadataJson);
  writer.writeDouble(offsets[5], object.progress);
  writer.writeString(offsets[6], object.title);
}

CourseTrack _courseTrackDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CourseTrack();
  object.additionalDetail = reader.readStringOrNull(offsets[0]);
  object.courseId = reader.readString(offsets[1]);
  object.description = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.metadataJson = reader.readString(offsets[4]);
  object.progress = reader.readDoubleOrNull(offsets[5]);
  object.title = reader.readStringOrNull(offsets[6]);
  return object;
}

P _courseTrackDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _courseTrackGetId(CourseTrack object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _courseTrackGetLinks(CourseTrack object) {
  return [object.contentTracks];
}

void _courseTrackAttach(
    IsarCollection<dynamic> col, Id id, CourseTrack object) {
  object.id = id;
  object.contentTracks
      .attach(col, col.isar.collection<ContentTrack>(), r'contentTracks', id);
}

extension CourseTrackByIndex on IsarCollection<CourseTrack> {
  Future<CourseTrack?> getByCourseId(String courseId) {
    return getByIndex(r'courseId', [courseId]);
  }

  CourseTrack? getByCourseIdSync(String courseId) {
    return getByIndexSync(r'courseId', [courseId]);
  }

  Future<bool> deleteByCourseId(String courseId) {
    return deleteByIndex(r'courseId', [courseId]);
  }

  bool deleteByCourseIdSync(String courseId) {
    return deleteByIndexSync(r'courseId', [courseId]);
  }

  Future<List<CourseTrack?>> getAllByCourseId(List<String> courseIdValues) {
    final values = courseIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'courseId', values);
  }

  List<CourseTrack?> getAllByCourseIdSync(List<String> courseIdValues) {
    final values = courseIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'courseId', values);
  }

  Future<int> deleteAllByCourseId(List<String> courseIdValues) {
    final values = courseIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'courseId', values);
  }

  int deleteAllByCourseIdSync(List<String> courseIdValues) {
    final values = courseIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'courseId', values);
  }

  Future<Id> putByCourseId(CourseTrack object) {
    return putByIndex(r'courseId', object);
  }

  Id putByCourseIdSync(CourseTrack object, {bool saveLinks = true}) {
    return putByIndexSync(r'courseId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCourseId(List<CourseTrack> objects) {
    return putAllByIndex(r'courseId', objects);
  }

  List<Id> putAllByCourseIdSync(List<CourseTrack> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'courseId', objects, saveLinks: saveLinks);
  }
}

extension CourseTrackQueryWhereSort
    on QueryBuilder<CourseTrack, CourseTrack, QWhere> {
  QueryBuilder<CourseTrack, CourseTrack, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CourseTrackQueryWhere
    on QueryBuilder<CourseTrack, CourseTrack, QWhereClause> {
  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> courseIdEqualTo(
      String courseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'courseId',
        value: [courseId],
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterWhereClause> courseIdNotEqualTo(
      String courseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseId',
              lower: [],
              upper: [courseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseId',
              lower: [courseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseId',
              lower: [courseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseId',
              lower: [],
              upper: [courseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CourseTrackQueryFilter
    on QueryBuilder<CourseTrack, CourseTrack, QFilterCondition> {
  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'additionalDetail',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'additionalDetail',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalDetail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'additionalDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'additionalDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'additionalDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'additionalDetail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalDetail',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      additionalDetailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'additionalDetail',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> courseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> courseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> courseIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      courseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      progressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'progress',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      progressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'progress',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> progressEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      progressGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      progressLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> progressBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension CourseTrackQueryObject
    on QueryBuilder<CourseTrack, CourseTrack, QFilterCondition> {}

extension CourseTrackQueryLinks
    on QueryBuilder<CourseTrack, CourseTrack, QFilterCondition> {
  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition> contentTracks(
      FilterQuery<ContentTrack> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'contentTracks');
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      contentTracksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'contentTracks', length, true, length, true);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      contentTracksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'contentTracks', 0, true, 0, true);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      contentTracksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'contentTracks', 0, false, 999999, true);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      contentTracksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'contentTracks', 0, true, length, include);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      contentTracksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'contentTracks', length, include, 999999, true);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterFilterCondition>
      contentTracksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'contentTracks', lower, includeLower, upper, includeUpper);
    });
  }
}

extension CourseTrackQuerySortBy
    on QueryBuilder<CourseTrack, CourseTrack, QSortBy> {
  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy>
      sortByAdditionalDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDetail', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy>
      sortByAdditionalDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDetail', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByCourseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByCourseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy>
      sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CourseTrackQuerySortThenBy
    on QueryBuilder<CourseTrack, CourseTrack, QSortThenBy> {
  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy>
      thenByAdditionalDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDetail', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy>
      thenByAdditionalDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDetail', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByCourseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByCourseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy>
      thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CourseTrackQueryWhereDistinct
    on QueryBuilder<CourseTrack, CourseTrack, QDistinct> {
  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByAdditionalDetail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'additionalDetail',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByCourseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByMetadataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<CourseTrack, CourseTrack, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension CourseTrackQueryProperty
    on QueryBuilder<CourseTrack, CourseTrack, QQueryProperty> {
  QueryBuilder<CourseTrack, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CourseTrack, String?, QQueryOperations>
      additionalDetailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalDetail');
    });
  }

  QueryBuilder<CourseTrack, String, QQueryOperations> courseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseId');
    });
  }

  QueryBuilder<CourseTrack, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CourseTrack, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<CourseTrack, String, QQueryOperations> metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<CourseTrack, double?, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<CourseTrack, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
