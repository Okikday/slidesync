import 'package:dart_mappable/dart_mappable.dart';

part 'enums.mapper.dart';

enum DeviceType { mobile, tablet, desktop, webMobile, webTablet, webDesktop, unknown }

enum CourseSortOption { nameAsc, nameDesc, dateCreatedAsc, dateCreatedDesc, dateModifiedAsc, dateModifiedDesc }

enum PlainCourseSortOption { name, dateCreated, dateModified }

enum AppDirType { documents, appSupport, temporary, cache }

enum ModuleContentType { unknown, document, image, link, note, reference, group }

enum AppClipboardContentType { empty, text, image, images, file, files, html, unsupported }

enum AppCourseCollections { bookmarks, references }

@MappableEnum()
enum ContentOrigin { none, local, server }
