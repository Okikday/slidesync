part of '../extensions.dart';

extension CourseSortX on EntityOrdering {
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
      case EntityOrdering.nameAsc:
        return 'Name (Ascending)';
      case EntityOrdering.nameDesc:
        return 'Name (Descending)';
      case EntityOrdering.dateCreatedAsc:
        return 'Date Created (Ascending)';
      case EntityOrdering.dateCreatedDesc:
        return 'Date Created (Descending)';
      case EntityOrdering.dateModifiedAsc:
        return 'Date Modified (Ascending)';
      case EntityOrdering.dateModifiedDesc:
        return 'Date Modified (Descending)';
    }
  }
}
