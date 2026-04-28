import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/painting.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/theme_utils.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/shared/theme/src/app_palette.dart';

part 'module_metadata.mapper.dart';
part 'module_metadata.g.dart';

@MappableClass()
@Embedded(ignore: {'copyWith'})
class ModuleMetadata with ModuleMetadataMappable {
  String? author;
  FilePath? thumbnail;
  String? rawColor;

  ModuleMetadata({this.author, this.thumbnail, this.rawColor});

  static const fromJson = ModuleMetadataMapper.fromJson;
  factory ModuleMetadata.empty() => ModuleMetadata();

  static ModuleMetadata create({String? author, FilePath? thumbnail, Color? color}) {
    final randColor = color ?? AppPalette.getRandom();
    return ModuleMetadata(author: author, thumbnail: thumbnail, rawColor: ThemeUtils.colorToHex(randColor));
  }
}

extension ModuleMetadataExtension on ModuleMetadata {
  Color? get color => (rawColor != null && rawColor!.isNotEmpty) ? ThemeUtils.hexToColor(rawColor!) : null;
}
