import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';

/// Defines the allowed file extensions for various content types.
class AllowedFileExtensions {
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'svg'];

  static const List<String> allowedVideoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'mpeg', 'mpg'];

  static const List<String> allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'csv',
    'rtf',
  ];

  static const List<String> allowedAudioExtensions = ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'];

  /// Combined list plus additional useful extensions
  static const List<String> allowedExtensions = [
    ...allowedImageExtensions,
    ...allowedVideoExtensions,
    ...allowedDocumentExtensions,
    ...allowedAudioExtensions,
    'txt',
    'md',
    'html',
    'css',
    'js',
    'json',
    'xml',
    'yaml',
    'zip',
    'rar',
    '7z',
  ];

  /// Returns the CourseContentType for a file extension or path.
  /// E.g. `.md`, `file.txt`, `/path/to/image.jpg`
  static CourseContentType checkContentType(String pathOrExt) {
    // Remove any leading dots and path parts
    String ext = pathOrExt.trim().toLowerCase();

    if (ext.contains(Platform.pathSeparator)) {
      ext = ext.split(Platform.pathSeparator).last;
    }
    if (ext.contains('.')) {
      ext = ext.split('.').last;
    }

    if (AllowedFileExtensions.allowedImageExtensions.contains(ext)) {
      return CourseContentType.image;
    }
    // else if (AllowedFileExtensions.allowedVideoExtensions.contains(ext)) {
    //   return CourseContentType.video;
    // }
    else if (AllowedFileExtensions.allowedDocumentExtensions.contains(ext)) {
      return CourseContentType.document;
    }
    // else if (AllowedFileExtensions.allowedAudioExtensions.contains(ext)) {
    //   return CourseContentType.audio;
    // }
    else if (['txt', 'md'].contains(ext)) {
      return CourseContentType.note;
    } else {
      return CourseContentType.unknown;
    }
  }
}
