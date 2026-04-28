import 'package:dart_mappable/dart_mappable.dart';

part 'enums.mapper.dart';

enum DeviceType { mobile, tablet, desktop, webMobile, webTablet, webDesktop, unknown }

sealed class Ordering {}

enum EntityOrdering implements Ordering {
  nameAsc,
  nameDesc,
  dateCreatedAsc,
  dateCreatedDesc,
  dateModifiedAsc,
  dateModifiedDesc,
}

enum PlainCourseSortOption { name, dateCreated, dateModified, courseCode }

enum AppDirType { documents, appSupport, temporary, cache }

enum ModuleContentType { unknown, document, image, link, note, reference, group }

enum AppClipboardContentType { empty, text, image, images, file, files, html, unsupported }

enum AppCourseCollections { bookmarks, references }

@MappableEnum()
enum ContentOrigin { none, local, server }

enum CardViewType { grid, list, other }

enum CoursesOrdering implements Ordering {
  nameAsc,
  nameDesc,
  dateCreatedAsc,
  dateCreatedDesc,
  dateModifiedAsc,
  dateModifiedDesc,
  courseCodeAsc,
  courseCodeDesc,
}
