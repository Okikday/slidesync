// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_track.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContentTrackCollection on Isar {
  IsarCollection<ContentTrack> get contentTracks => this.collection();
}

const ContentTrackSchema = CollectionSchema(
  name: r'ContentTrack',
  id: 6970026462422311558,
  properties: {
    r'courseId': PropertySchema(
      id: 0,
      name: r'courseId',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'extraDetail': PropertySchema(
      id: 2,
      name: r'extraDetail',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(id: 3, name: r'hashCode', type: IsarType.long),
    r'lastRead': PropertySchema(
      id: 4,
      name: r'lastRead',
      type: IsarType.dateTime,
    ),
    r'pages': PropertySchema(id: 5, name: r'pages', type: IsarType.stringList),
    r'progress': PropertySchema(
      id: 6,
      name: r'progress',
      type: IsarType.double,
    ),
    r'thumbnail': PropertySchema(
      id: 7,
      name: r'thumbnail',
      type: IsarType.object,

      target: r'FilePath',
    ),
    r'title': PropertySchema(id: 8, name: r'title', type: IsarType.string),
    r'type': PropertySchema(
      id: 9,
      name: r'type',
      type: IsarType.string,
      enumMap: _ContentTracktypeEnumValueMap,
    ),
    r'uid': PropertySchema(id: 10, name: r'uid', type: IsarType.string),
  },

  estimateSize: _contentTrackEstimateSize,
  serialize: _contentTrackSerialize,
  deserialize: _contentTrackDeserialize,
  deserializeProp: _contentTrackDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'courseId': IndexSchema(
      id: -4937057111615935929,
      name: r'courseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'courseId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'FilePath': FilePathSchema},

  getId: _contentTrackGetId,
  getLinks: _contentTrackGetLinks,
  attach: _contentTrackAttach,
  version: '3.3.2',
);

int _contentTrackEstimateSize(
  ContentTrack object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.courseId.length * 3;
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.extraDetail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.pages.length * 3;
  {
    for (var i = 0; i < object.pages.length; i++) {
      final value = object.pages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount +=
      3 +
      FilePathSchema.estimateSize(
        object.thumbnail,
        allOffsets[FilePath]!,
        allOffsets,
      );
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _contentTrackSerialize(
  ContentTrack object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.courseId);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.extraDetail);
  writer.writeLong(offsets[3], object.hashCode);
  writer.writeDateTime(offsets[4], object.lastRead);
  writer.writeStringList(offsets[5], object.pages);
  writer.writeDouble(offsets[6], object.progress);
  writer.writeObject<FilePath>(
    offsets[7],
    allOffsets,
    FilePathSchema.serialize,
    object.thumbnail,
  );
  writer.writeString(offsets[8], object.title);
  writer.writeString(offsets[9], object.type.name);
  writer.writeString(offsets[10], object.uid);
}

ContentTrack _contentTrackDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContentTrack(
    courseId: reader.readString(offsets[0]),
    description: reader.readString(offsets[1]),
    extraDetail: reader.readStringOrNull(offsets[2]),
    id: id,
    lastRead: reader.readDateTime(offsets[4]),
    pages: reader.readStringList(offsets[5]) ?? [],
    progress: reader.readDouble(offsets[6]),
    thumbnail:
        reader.readObjectOrNull<FilePath>(
          offsets[7],
          FilePathSchema.deserialize,
          allOffsets,
        ) ??
        FilePath(),
    title: reader.readString(offsets[8]),
    type:
        _ContentTracktypeValueEnumMap[reader.readStringOrNull(offsets[9])] ??
        ModuleContentType.unknown,
    uid: reader.readString(offsets[10]),
  );
  return object;
}

P _contentTrackDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readObjectOrNull<FilePath>(
                offset,
                FilePathSchema.deserialize,
                allOffsets,
              ) ??
              FilePath())
          as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_ContentTracktypeValueEnumMap[reader.readStringOrNull(offset)] ??
              ModuleContentType.unknown)
          as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ContentTracktypeEnumValueMap = {
  r'unknown': r'unknown',
  r'document': r'document',
  r'image': r'image',
  r'link': r'link',
  r'note': r'note',
  r'reference': r'reference',
  r'group': r'group',
};
const _ContentTracktypeValueEnumMap = {
  r'unknown': ModuleContentType.unknown,
  r'document': ModuleContentType.document,
  r'image': ModuleContentType.image,
  r'link': ModuleContentType.link,
  r'note': ModuleContentType.note,
  r'reference': ModuleContentType.reference,
  r'group': ModuleContentType.group,
};

Id _contentTrackGetId(ContentTrack object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contentTrackGetLinks(ContentTrack object) {
  return [];
}

void _contentTrackAttach(
  IsarCollection<dynamic> col,
  Id id,
  ContentTrack object,
) {
  object.id = id;
}

extension ContentTrackByIndex on IsarCollection<ContentTrack> {
  Future<ContentTrack?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  ContentTrack? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<ContentTrack?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<ContentTrack?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(ContentTrack object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(ContentTrack object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<ContentTrack> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(
    List<ContentTrack> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension ContentTrackQueryWhereSort
    on QueryBuilder<ContentTrack, ContentTrack, QWhere> {
  QueryBuilder<ContentTrack, ContentTrack, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContentTrackQueryWhere
    on QueryBuilder<ContentTrack, ContentTrack, QWhereClause> {
  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> uidEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause> courseIdEqualTo(
    String courseId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'courseId', value: [courseId]),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterWhereClause>
  courseIdNotEqualTo(String courseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'courseId',
                lower: [],
                upper: [courseId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'courseId',
                lower: [courseId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'courseId',
                lower: [courseId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'courseId',
                lower: [],
                upper: [courseId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ContentTrackQueryFilter
    on QueryBuilder<ContentTrack, ContentTrack, QFilterCondition> {
  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'courseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'courseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'courseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'courseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'courseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'courseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'courseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'courseId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'courseId', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  courseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'courseId', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'extraDetail'),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'extraDetail'),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'extraDetail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'extraDetail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'extraDetail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'extraDetail',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'extraDetail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'extraDetail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'extraDetail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'extraDetail',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'extraDetail', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  extraDetailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'extraDetail', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  hashCodeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hashCode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  hashCodeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hashCode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hashCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  lastReadEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRead', value: value),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  lastReadGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRead',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  lastReadLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRead',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  lastReadBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRead',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pages',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pages', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pages', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pages', length, true, length, true);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pages', 0, true, 0, true);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pages', 0, false, 999999, true);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pages', 0, true, length, include);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pages', length, include, 999999, true);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  pagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  progressEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'progress',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'progress',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'progress',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'progress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> typeEqualTo(
    ModuleContentType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  typeGreaterThan(
    ModuleContentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> typeLessThan(
    ModuleContentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> typeBetween(
    ModuleContentType lower,
    ModuleContentType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> typeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition>
  uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }
}

extension ContentTrackQueryObject
    on QueryBuilder<ContentTrack, ContentTrack, QFilterCondition> {
  QueryBuilder<ContentTrack, ContentTrack, QAfterFilterCondition> thumbnail(
    FilterQuery<FilePath> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'thumbnail');
    });
  }
}

extension ContentTrackQueryLinks
    on QueryBuilder<ContentTrack, ContentTrack, QFilterCondition> {}

extension ContentTrackQuerySortBy
    on QueryBuilder<ContentTrack, ContentTrack, QSortBy> {
  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByCourseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByCourseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByExtraDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDetail', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy>
  sortByExtraDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDetail', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByLastRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByLastReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension ContentTrackQuerySortThenBy
    on QueryBuilder<ContentTrack, ContentTrack, QSortThenBy> {
  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByCourseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByCourseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseId', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByExtraDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDetail', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy>
  thenByExtraDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDetail', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByLastRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByLastReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension ContentTrackQueryWhereDistinct
    on QueryBuilder<ContentTrack, ContentTrack, QDistinct> {
  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByCourseId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByExtraDetail({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extraDetail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByLastRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRead');
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pages');
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentTrack, ContentTrack, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension ContentTrackQueryProperty
    on QueryBuilder<ContentTrack, ContentTrack, QQueryProperty> {
  QueryBuilder<ContentTrack, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContentTrack, String, QQueryOperations> courseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseId');
    });
  }

  QueryBuilder<ContentTrack, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ContentTrack, String?, QQueryOperations> extraDetailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extraDetail');
    });
  }

  QueryBuilder<ContentTrack, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<ContentTrack, DateTime, QQueryOperations> lastReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRead');
    });
  }

  QueryBuilder<ContentTrack, List<String>, QQueryOperations> pagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pages');
    });
  }

  QueryBuilder<ContentTrack, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<ContentTrack, FilePath, QQueryOperations> thumbnailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnail');
    });
  }

  QueryBuilder<ContentTrack, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ContentTrack, ModuleContentType, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<ContentTrack, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
