import 'package:slidesync/core/storage/hive_data/hive_data.dart';
import 'package:slidesync/core/utils/result.dart';

enum HiveDataKey {
  /// Miscellaneous
  isBuiltInViewer,
  globalFileSizeSum,
  lastClearedCacheDate,
  isFirstLaunch,

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
  libraryCourseOrdering,
  libraryCourseCardViewType,

  /// Course Materials View
  moduleContentsCardViewType,
  moduleContentsOrdering,

  /// Pdf Viewer view
  ispdfViewerInDarkMode,

  /// Syncs - Keeps a Map of Id to [SyncType]
  downloads,
  uploads,

  /// Sync history of downloaded/imported items.
  downloadHistory,

  // ── Drive resumable session keys ──────────────────────────────────────────
  // Stored as: driveUploadSession_{operationId} / driveDownloadSession_{operationId}
  // These are automatically cleaned up when the operation completes.
  driveUploadSession,
  driveDownloadSession,
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

extension HiveDataPathKeyStringExtension on String {
  /// Sets the Hive data for the current path key
  Future<void> setHiveData<T>({required T value}) async =>
      await KVStore.me.setData(key: this, value: value);

  /// Gets the Hive data for the current path key
  Future<T?> getHiveData<T>() async => KVStore.me.getData(key: this);

  /// Deletes the Hive data for the current path key
  Future<void> deleteHiveData() async => await KVStore.me.deleteData(key: this);

  /// Try to get the Hive data for the current path key, returns a [Result] with the data or an error
  Future<Result<T?>> tryGet<T>() async => await Result.tryRunAsync<T>(() async {
    return await getHiveData<T>();
  });

  /// Try to set the Hive data for the current path key, returns a [Result] with the success status or an error
  Future<Result<void>> trySet<T>({required T value}) async =>
      await Result.tryRunAsync<void>(() async {
        await setHiveData<T>(value: value);
      });

  /// Try to delete the Hive data for the current path key, returns a [Result] with the success status or an error
  Future<Result<void>> tryDeleteHiveData() async =>
      await Result.tryRunAsync<void>(() async {
        await deleteHiveData();
      });
}

extension HiveDataPathKeyExtension on HiveDataKey {
  Future<Result<void>> setHiveData<T>({required T value}) =>
      Result.tryRunAsync<void>(
        () => KVStore.me.setData(key: name, value: value),
      );

  Future<Result<T?>> getHiveData<T>() =>
      Result.tryRunAsync<T?>(() => KVStore.me.getData(key: name));
}
