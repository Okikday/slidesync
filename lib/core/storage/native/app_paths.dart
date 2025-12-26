import 'dart:io';

class AppPaths {
  static const _appFolderName = "slidesync";
  static const _coursesFolderName = "courses";
  static const _previewsFolderName = "previews";
  static const _materialsFolderName = "materials";
  static const _thumbnailsFolderName = "thumbnails";

  //// All relative paths
  // static final coursesFolder = _appFolderName + Platform.pathSeparator + _coursesFolderName;
  static final materialsFolder = "$_appFolderName${Platform.pathSeparator}$_materialsFolderName";
  static final previewsFolder = _appFolderName + Platform.pathSeparator + _previewsFolderName;
  static final thumbnailsFolder = "$_appFolderName${Platform.pathSeparator}$_thumbnailsFolderName";
  static final contentsThumbnailsFolder =
      "$_appFolderName${Platform.pathSeparator}$_thumbnailsFolderName${Platform.pathSeparator}contents";
  static final coursesThumbnailsFolder =
      "$_appFolderName${Platform.pathSeparator}$_thumbnailsFolderName${Platform.pathSeparator}courses";

  static final operationsCacheFolder = "$_appFolderName${Platform.pathSeparator}operations_cache";

  static final tempFolder = "$_appFolderName${Platform.pathSeparator}temp";

  /// Others
}
