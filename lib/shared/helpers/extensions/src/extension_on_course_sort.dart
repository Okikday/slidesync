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

extension CoursesSortX on CoursesOrdering {
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
      case 'courseCode':
        return PlainCourseSortOption.courseCode;
      default:
        return PlainCourseSortOption.dateModified;
    }
  }

  String get label {
    switch (this) {
      case CoursesOrdering.nameAsc:
        return 'Name (Ascending)';
      case CoursesOrdering.nameDesc:
        return 'Name (Descending)';
      case CoursesOrdering.dateCreatedAsc:
        return 'Date Created (Ascending)';
      case CoursesOrdering.dateCreatedDesc:
        return 'Date Created (Descending)';
      case CoursesOrdering.dateModifiedAsc:
        return 'Date Modified (Ascending)';
      case CoursesOrdering.dateModifiedDesc:
        return 'Date Modified (Descending)';
      case CoursesOrdering.courseCodeAsc:
        return 'Course Code (Ascending)';
      case CoursesOrdering.courseCodeDesc:
        return 'Course Code (Descending)';
    }
  }
}
