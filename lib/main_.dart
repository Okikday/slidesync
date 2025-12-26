part of 'main.dart';

/// Pdfrx check initialized
// bool _isPdfrxInitialized = false;

Future<void> _appLaunchRoutine() async {
  /// Clear App Cache every 23 hours
  final lastDateHive = DateTime.tryParse(
    (await Result.tryRunAsync<String>(() async {
          return (await AppHiveData.instance.getData<String?>(key: HiveDataPathKey.lastClearedCacheDate.name));
        })).data ??
        '',
  );
  if (lastDateHive == null) {
    await AppHiveData.instance.setData(
      key: HiveDataPathKey.lastClearedCacheDate.name,
      value: DateTime.now().toIso8601String(),
    );
    return;
  }
  final lastDate = lastDateHive;
  final dateDiff = lastDate.difference(DateTime.now());
  if (dateDiff.inHours > 20) {
    // final token = RootIsolateToken.instance;
    // if (token != null) {
    //   compute(FileUtils.deleteEmptyCoursesDirsInIsolate, {'rootIsolateToken': token});
    //   await AppHiveData.instance.setData(
    //     key: HiveDataPathKey.lastClearedCacheDate.name,
    //     value: DateTime.now().toIso8601String(),
    //   );
    // }
  }
}

Future<void> _firstAppLaunch() async {
  final isFirstLaunch = (await AppHiveData.instance.getData(key: HiveDataPathKey.isFirstLaunch.name)) as bool?;
  if (isFirstLaunch == null) {
    final referenceCollection = CourseCollection.create(
      parentId: AppCourseCollections.references.name,
      collectionId: AppCourseCollections.references.name,
      collectionTitle: "References",
      description: "This is the Default App Reference collections",
    );
    final bookMarkCollection = CourseCollection.create(
      parentId: AppCourseCollections.bookmarks.name,
      collectionId: AppCourseCollections.bookmarks.name,
      collectionTitle: "Bookmarks",
      description: "This is the Default App Bookmark collections",
    );
    await CourseCollectionRepo.add(referenceCollection);
    await CourseCollectionRepo.add(bookMarkCollection);
    await AppHiveData.instance.setData(key: HiveDataPathKey.isFirstLaunch.name, value: false);
  }
}

Future<void> _initDesktop() async {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      minimumSize: Size(800, 600), // Minimum width for 3 panels
      size: Size(1366, 768), // Default comfortable size
      // fullScreen: true,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }
}

// Future<void> initPdfrx({bool dismissPdfiumWasmWarnings = false}) async {
//   if (_isPdfrxInitialized) return;

//   Pdfrx.loadAsset ??= (name) async {
//     final asset = await rootBundle.load(name);
//     return asset.buffer.asUint8List();
//   };

//   /// NOTE: it's actually async, but hopefully, it finishes quickly...
//   await PdfrxEntryFunctions.instance.initPdfium();
//   _isPdfrxInitialized = true;
// }
