// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_metadata.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ModuleMetadataSchema = Schema(
  name: r'ModuleMetadata',
  id: 4108555981307664566,
  properties: {
    r'author': PropertySchema(id: 0, name: r'author', type: IsarType.string),
    r'rawColor': PropertySchema(
      id: 1,
      name: r'rawColor',
      type: IsarType.string,
    ),
    r'thumbnail': PropertySchema(
      id: 2,
      name: r'thumbnail',
      type: IsarType.object,

      target: r'FilePath',
    ),
  },

  estimateSize: _moduleMetadataEstimateSize,
  serialize: _moduleMetadataSerialize,
  deserialize: _moduleMetadataDeserialize,
  deserializeProp: _moduleMetadataDeserializeProp,
);

int _moduleMetadataEstimateSize(
  ModuleMetadata object,
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
    final value = object.thumbnail;
    if (value != null) {
      bytesCount +=
          3 +
          FilePathSchema.estimateSize(value, allOffsets[FilePath]!, allOffsets);
    }
  }
  return bytesCount;
}

void _moduleMetadataSerialize(
  ModuleMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeString(offsets[1], object.rawColor);
  writer.writeObject<FilePath>(
    offsets[2],
    allOffsets,
    FilePathSchema.serialize,
    object.thumbnail,
  );
}

ModuleMetadata _moduleMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModuleMetadata(
    author: reader.readStringOrNull(offsets[0]),
    rawColor: reader.readStringOrNull(offsets[1]),
    thumbnail: reader.readObjectOrNull<FilePath>(
      offsets[2],
      FilePathSchema.deserialize,
      allOffsets,
    ),
  );
  return object;
}

P _moduleMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
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

extension ModuleMetadataQueryFilter
    on QueryBuilder<ModuleMetadata, ModuleMetadata, QFilterCondition> {
  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'author'),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'author'),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  rawColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rawColor'),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  rawColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rawColor'),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
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

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  rawColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawColor', value: ''),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  rawColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawColor', value: ''),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  thumbnailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnail'),
      );
    });
  }

  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition>
  thumbnailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnail'),
      );
    });
  }
}

extension ModuleMetadataQueryObject
    on QueryBuilder<ModuleMetadata, ModuleMetadata, QFilterCondition> {
  QueryBuilder<ModuleMetadata, ModuleMetadata, QAfterFilterCondition> thumbnail(
    FilterQuery<FilePath> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'thumbnail');
    });
  }
}
