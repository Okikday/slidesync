import 'package:slidesync/core/constants/constants.dart';

class Formatter {
  static String formatEnumName(String name) {
    return name.split(RegExp(r'(?=[A-Z])')).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  /// Returns [CourseTitle, CourseCode]
  static CourseTitleRecord separateCodeFromTitle(String joinedStr) {
    final regex = RegExp(r'^\*\[([^\]]+)\]\*(.*)');
    final match = regex.firstMatch(joinedStr);

    if (match != null) {
      final courseCode = match.group(1)?.trim();
      final courseTitle = match.group(2)?.trim();
      if (courseCode == null || courseCode.isEmpty) {
        return (courseName: joinedStr, courseCode: "");
      }

      return (courseName: courseTitle ?? "", courseCode: courseCode);
    } else {
      return (courseName: joinedStr, courseCode: "");
    }
  }

  static String joinCodeToTitle(String courseCode, String courseName) {
    if (courseCode.isEmpty || courseCode.length < 2) return courseName;
    return "*[$courseCode]* $courseName";
  }
}
