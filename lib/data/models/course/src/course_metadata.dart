import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/painting.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/theme_utils.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/shared/theme/src/app_palette.dart';

part 'course_metadata.mapper.dart';
part 'course_metadata.g.dart';

@MappableClass()
@Embedded(ignore: {'copyWith'})
class CourseMetadata with CourseMetadataMappable {
  String? courseCode;
  String? author;
  FilePath? thumbnail;
  String? rawColor;

  CourseMetadata({this.courseCode, this.author, this.thumbnail, this.rawColor});

  static const fromJson = CourseMetadataMapper.fromJson;
  factory CourseMetadata.empty() => CourseMetadata();

  static CourseMetadata create({String? courseCode, String? author, FilePath? thumbnail, Color? color}) {
    final randColor = color ?? AppPalette.getRandom();
    return CourseMetadata(
      courseCode: courseCode,
      author: author,
      thumbnail: thumbnail,
      rawColor: ThemeUtils.colorToHex(randColor),
    );
  }
}

extension CourseMetadataExtension on CourseMetadata {
  Color? get color => (rawColor != null && rawColor!.isNotEmpty) ? ThemeUtils.hexToColor(rawColor!) : null;
}
