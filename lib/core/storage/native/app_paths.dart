import 'dart:io';

class AppPaths {
  static const _appFolderName = "slidesync";
  static const _coursesFolderName = "courses";
  static const _previews = "previews";

  //// All relative paths
  static final coursesFolder = _appFolderName + Platform.pathSeparator + _coursesFolderName;
  static final previewsFolder = _appFolderName + Platform.pathSeparator + _previews;
  
}

