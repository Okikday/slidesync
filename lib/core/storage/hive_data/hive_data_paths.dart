enum HiveDataPathKey {
  /// Miscellaneous
  isBuiltInViewer,

  /// List of filePaths that was being added from last session, appended with the collectionId
  contentsAddingProgressList,

  // User
  userData,

  // Style
  appTheme,

  /// Welcome View
  hasOnboarded,

  /// Home Recents View
  recentContentsIds,

  /// Library Tab View
  libraryCourseSortOption,
  libraryTabCardViewType,

  /// Course Materials View
  courseMaterialscardViewType,
  courseMaterialsSortOption,

  /// Pdf Viewer view
  ispdfViewerInDarkMode,
}

// class HiveDataPaths {
//   static const Map<HiveDataPathKey, String> values = {
//     HiveDataPathKey.hasOnboarded: "hasOnboarded",
//     HiveDataPathKey.userData: "userData",
//     HiveDataPathKey.recentContentsIds: "recentContentsIds",
//     HiveDataPathKey.libraryCourseSortOption: "library/courseSortOption",
//     HiveDataPathKey.libraryTabCardViewType: "library/isListView",
//     HiveDataPathKey.courseMaterialscardViewType: "courseMaterials/cardViewType",
//     HiveDataPathKey.courseMaterialsSortOption: "courseMaterials/sortOption",
//     HiveDataPathKey.ispdfViewerInDarkMode: "pdfViewer/isDarkMode",
//   };
// }
