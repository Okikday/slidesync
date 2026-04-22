// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_metadata.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CourseMetadataSchema = Schema(
  name: r'CourseMetadata',
  id: -4465050667655202996,
  properties: {
    r'author': PropertySchema(id: 0, name: r'author', type: IsarType.string),
    r'hashCode': PropertySchema(id: 1, name: r'hashCode', type: IsarType.long),
    r'rawColor': PropertySchema(
      id: 2,
      name: r'rawColor',
      type: IsarType.string,
    ),
    r'thumbnails': PropertySchema(
      id: 3,
      name: r'thumbnails',
      type: IsarType.object,

      target: r'FilePath',
    ),
    r'thumbnailsDetails': PropertySchema(
      id: 4,
      name: r'thumbnailsDetails',
      type: IsarType.object,

      target: r'FilePath',
    ),
  },

  estimateSize: _courseMetadataEstimateSize,
  serialize: _courseMetadataSerialize,
  deserialize: _courseMetadataDeserialize,
  deserializeProp: _courseMetadataDeserializeProp,
);

int _courseMetadataEstimateSize(
  CourseMetadata object,
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
    final value = object.rawColor;
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
  bytesCount +=
      3 +
      FilePathSchema.estimateSize(
        object.thumbnailsDetails,
        allOffsets[FilePath]!,
        allOffsets,
      );
  return bytesCount;
}

void _courseMetadataSerialize(
  CourseMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeString(offsets[2], object.rawColor);
  writer.writeObject<FilePath>(
    offsets[3],
    allOffsets,
    FilePathSchema.serialize,
    object.thumbnails,
  );
  writer.writeObject<FilePath>(
    offsets[4],
    allOffsets,
    FilePathSchema.serialize,
    object.thumbnailsDetails,
  );
}

CourseMetadata _courseMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CourseMetadata();
  object.author = reader.readStringOrNull(offsets[0]);
  object.rawColor = reader.readStringOrNull(offsets[2]);
  object.thumbnails = reader.readObjectOrNull<FilePath>(
    offsets[3],
    FilePathSchema.deserialize,
    allOffsets,
  );
  return object;
}

P _courseMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readObjectOrNull<FilePath>(
            offset,
            FilePathSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 4:
      return (reader.readObjectOrNull<FilePath>(
                offset,
                FilePathSchema.deserialize,
                allOffsets,
              ) ??
              FilePath())
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CourseMetadataQueryFilter
    on QueryBuilder<CourseMetadata, CourseMetadata, QFilterCondition> {
  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'author'),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'author'),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hashCode', value: value),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
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

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rawColor'),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rawColor'),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawColor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawColor',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawColor', value: ''),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  rawColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawColor', value: ''),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  thumbnailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnails'),
      );
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  thumbnailsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnails'),
      );
    });
  }
}

extension CourseMetadataQueryObject
    on QueryBuilder<CourseMetadata, CourseMetadata, QFilterCondition> {
  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  thumbnails(FilterQuery<FilePath> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'thumbnails');
    });
  }

  QueryBuilder<CourseMetadata, CourseMetadata, QAfterFilterCondition>
  thumbnailsDetails(FilterQuery<FilePath> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'thumbnailsDetails');
    });
  }
}
