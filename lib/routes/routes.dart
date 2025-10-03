enum Routes {
  /// Splash Screen
  splash,

  /// Auth Screens
  auth,

  /// Onboarding Screens
  welcome,
  onboarding1,

  /// Main View tabs
  home,
  library,
  explore,

  // Under home
  recentsView,

  /// Course Nav screens
  courseDetails,
  courseMaterials,

  contentGate,
  createCourse,
  modifyCourse,
  selectToModifyCourse,
  modifyCollections,
  modifyContents,
  pdfDocumentViewer,
  imageViewer,
  driveLinkViewer,
  settings,
}

extension RoutesExtension on Routes {
  String get path => name.withSlashPrefix;
  String get subPath => name;
}

extension RoutesHelper on String {
  String get lastRoutePath => substring(lastIndexOf('/') + 1);
  String get withSlashPrefix => startsWith('/') ? this : '/$this';
}
