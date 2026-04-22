// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_content_metadata.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ModuleContentMetadataSchema = Schema(
  name: r'ModuleContentMetadata',
  id: -2603868801880082502,
  properties: {
    r'author': PropertySchema(id: 0, name: r'author', type: IsarType.string),
    r'contentOrigin': PropertySchema(
      id: 1,
      name: r'contentOrigin',
      type: IsarType.byte,
      enumMap: _ModuleContentMetadatacontentOriginEnumValueMap,
    ),
    r'groupId': PropertySchema(id: 2, name: r'groupId', type: IsarType.string),
    r'hashCode': PropertySchema(id: 3, name: r'hashCode', type: IsarType.long),
    r'originalFileName': PropertySchema(
      id: 4,
      name: r'originalFileName',
      type: IsarType.string,
    ),
    r'rawFieldsJson': PropertySchema(
      id: 5,
      name: r'rawFieldsJson',
      type: IsarType.string,
    ),
    r'thumbnails': PropertySchema(
      id: 6,
      name: r'thumbnails',
      type: IsarType.object,

      target: r'FilePath',
    ),
  },

  estimateSize: _moduleContentMetadataEstimateSize,
  serialize: _moduleContentMetadataSerialize,
  deserialize: _moduleContentMetadataDeserialize,
  deserializeProp: _moduleContentMetadataDeserializeProp,
);

int _moduleContentMetadataEstimateSize(
  ModuleContentMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.groupId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originalFileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rawFieldsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnails;
    if (value != null) {
      bytesCount +=
          3 +
          FilePathSchema.estimateSize(value, allOffsets[FilePath]!, allOffsets);
    }
  }
  return bytesCount;
}

void _moduleContentMetadataSerialize(
  ModuleContentMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeByte(offsets[1], object.contentOrigin.index);
  writer.writeString(offsets[2], object.groupId);
  writer.writeLong(offsets[3], object.hashCode);
  writer.writeString(offsets[4], object.originalFileName);
  writer.writeString(offsets[5], object.rawFieldsJson);
  writer.writeObject<FilePath>(
    offsets[6],
    allOffsets,
    FilePathSchema.serialize,
    object.thumbnails,
  );
}

ModuleContentMetadata _moduleContentMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModuleContentMetadata();
  object.author = reader.readStringOrNull(offsets[0]);
  object.contentOrigin =
      _ModuleContentMetadatacontentOriginValueEnumMap[reader.readByteOrNull(
        offsets[1],
      )] ??
      ContentOrigin.none;
  object.groupId = reader.readStringOrNull(offsets[2]);
  object.originalFileName = reader.readStringOrNull(offsets[4]);
  object.rawFieldsJson = reader.readStringOrNull(offsets[5]);
  object.thumbnails = reader.readObjectOrNull<FilePath>(
    offsets[6],
    FilePathSchema.deserialize,
    allOffsets,
  );
  return object;
}

P _moduleContentMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (_ModuleContentMetadatacontentOriginValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              ContentOrigin.none)
          as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readObjectOrNull<FilePath>(
            offset,
            FilePathSchema.deserialize,
            allOffsets,
          ))
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ModuleContentMetadatacontentOriginEnumValueMap = {
  'none': 0,
  'local': 1,
  'server': 2,
};
const _ModuleContentMetadatacontentOriginValueEnumMap = {
  0: ContentOrigin.none,
  1: ContentOrigin.local,
  2: ContentOrigin.server,
};

extension ModuleContentMetadataQueryFilter
    on
        QueryBuilder<
          ModuleContentMetadata,
          ModuleContentMetadata,
          QFilterCondition
        > {
  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'author'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'author'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'author',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'author',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  contentOriginEqualTo(ContentOrigin value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentOrigin', value: value),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  contentOriginGreaterThan(ContentOrigin value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentOrigin',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  contentOriginLessThan(ContentOrigin value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentOrigin',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  contentOriginBetween(
    ContentOrigin lower,
    ContentOrigin upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentOrigin',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'originalFileName'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'originalFileName'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originalFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originalFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originalFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originalFileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'originalFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'originalFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'originalFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'originalFileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originalFileName', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  originalFileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'originalFileName', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rawFieldsJson'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rawFieldsJson'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawFieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawFieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawFieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawFieldsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawFieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawFieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawFieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawFieldsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawFieldsJson', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  rawFieldsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawFieldsJson', value: ''),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  thumbnailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnails'),
      );
    });
  }

  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  thumbnailsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnails'),
      );
    });
  }
}

extension ModuleContentMetadataQueryObject
    on
        QueryBuilder<
          ModuleContentMetadata,
          ModuleContentMetadata,
          QFilterCondition
        > {
  QueryBuilder<
    ModuleContentMetadata,
    ModuleContentMetadata,
    QAfterFilterCondition
  >
  thumbnails(FilterQuery<FilePath> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'thumbnails');
    });
  }
}
