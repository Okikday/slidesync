part of 'main.dart';

/// Pdfrx check initialized
// bool _isPdfrxInitialized = false;

Future<void> _appLaunchRoutine() async {
  /// Clear App Cache every 23 hours
  final lastDateHive = DateTime.tryParse(
    (await HiveDataPathKey.lastClearedCacheDate.name.tryGetHiveData<String>()).data ?? '',
  );
  if (lastDateHive == null) {
    await HiveDataPathKey.lastClearedCacheDate.name.trySetHiveData(value: DateTime.now().toIso8601String());
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
    await HiveDataPathKey.isFirstLaunch.name.trySetHiveData(value: false);
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

bool _isInitialized = false;

Future<void> pdfrxFlutterInitializeInIsolate({bool dismissPdfiumWasmWarnings = false}) async {
  if (_isInitialized) return;

  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e) {
    log("Couldn't init flutter bindings");
  }

  if (pdfrxEntryFunctionsOverride != null) {
    PdfrxEntryFunctions.instance = pdfrxEntryFunctionsOverride!;
  }

  Pdfrx.loadAsset ??= (name) async {
    final asset = await rootBundle.load(name);
    return asset.buffer.asUint8List();
  };
  Pdfrx.getCacheDirectory ??= getCacheDirectory;

  // Checking pdfium.wasm availability for Web and debug builds.
  if (kDebugMode && !dismissPdfiumWasmWarnings) {
    () async {
      try {
        await Pdfrx.loadAsset!('packages/pdfrx/assets/pdfium.wasm');
        if (!kIsWeb) {
          debugPrint(
            '⚠️\u001b[37;41;1mDEBUG TIME WARNING: The app is bundling PDFium WASM module (about 4MB) as a part of the app.\u001b[0m\n'
            '\u001b[91mFor production use (not for Web/Debug), you\'d better remove the PDFium WASM module.\u001b[0m\n'
            '\u001b[91mSee https://github.com/espresso3389/pdfrx/tree/master/packages/pdfrx#note-for-building-release-builds for more details.\u001b[0m\n',
          );
        }
      } catch (e) {
        if (kIsWeb) {
          debugPrint(
            '⚠️\u001b[37;41;1mDEBUG TIME WARNING: The app is running on Web, but the PDFium WASM module is not bundled with the app.\u001b[0m\n'
            '\u001b[91mMake sure to include the PDFium WASM module in your web project.\u001b[0m\n'
            '\u001b[91mIf you explicitly set Pdfrx.pdfiumWasmModulesUrl, you can ignore this warning.\u001b[0m\n'
            '\u001b[91mSee https://github.com/espresso3389/pdfrx/tree/master/packages/pdfrx#note-for-building-release-builds for more details.\u001b[0m\n',
          );
        }
      }
    }();
  }

  /// NOTE: it's actually async, but hopefully, it finishes quickly...
  await platformInitialize();

  _isInitialized = true;
}
