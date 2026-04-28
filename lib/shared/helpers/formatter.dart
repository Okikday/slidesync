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

  // static String joinCodeToTitle(String courseCode, String courseName) {
  //   if (courseCode.isEmpty || courseCode.length < 2) return courseName;
  //   return "*[$courseCode]* $courseName";
  // }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    final kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(2)} KB";
    final mb = kb / 1024;
    if (mb < 1024) return "${mb.toStringAsFixed(2)} MB";
    final gb = mb / 1024;
    return "${gb.toStringAsFixed(2)} GB";
  }

  static const List<String> _monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  static const List<String> _weekDayNames = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  static String formatDateToDayDateMonth(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return _weekDayNames[date.weekday - 1];
    } else {
      final day = date.day;
      final month = _monthNames[date.month - 1];
      final year = date.year;
      return "$day $month $year";
    }
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
    } else {
      return formatDateToDayDateMonth(date);
    }
  }
}
