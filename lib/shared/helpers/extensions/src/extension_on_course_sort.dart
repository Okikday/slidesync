import 'package:slidesync/core/constants/constants.dart';

extension CourseSortX on CourseSortOption {
  PlainCourseSortOption toPlain() {
    final n = name;
    final core = n.endsWith('Asc')
        ? n.substring(0, n.length - 3)
        : n.endsWith('Desc')
        ? n.substring(0, n.length - 4)
        : n;
    switch (core) {
      case 'name':
        return PlainCourseSortOption.name;
      case 'dateCreated':
        return PlainCourseSortOption.dateCreated;
      case 'dateModified':
        return PlainCourseSortOption.dateModified;
      default:
        return PlainCourseSortOption.dateModified;
    }
  }

  String get label {
    switch (this) {
      case CourseSortOption.nameAsc:
        return 'Name (Ascending)';
      case CourseSortOption.nameDesc:
        return 'Name (Descending)';
      case CourseSortOption.dateCreatedAsc:
        return 'Date Created (Ascending)';
      case CourseSortOption.dateCreatedDesc:
        return 'Date Created (Descending)';
      case CourseSortOption.dateModifiedAsc:
        return 'Date Modified (Ascending)';
      case CourseSortOption.dateModifiedDesc:
        return 'Date Modified (Descending)';
    }
  }
}
