import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kickin_storage/kickin_storage.dart';
import 'package:path_provider/path_provider.dart' as pp;

import 'package:slidesync/core/storage/hive_data/hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:slidesync/firebase_options.dart';
import 'package:window_manager/window_manager.dart';

// ignore: implementation_imports
// import 'package:pdfrx/src/utils/platform.dart';

final startup = _initialize;

Future<void> _initialize() async {
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).tryRunAsync(),

    KHive.on
        .initialize(initApp: true)
        .tryRunAsync()
        .then((_) async => await KVStore.me.initialize().tryRunAsync()),

    if (!kIsWeb) IsarData.initializeDefault(),
  ]);

  await NotificationService.instance.initialize().tryRunAsync();

  // pdfrxFlutterInitialize().tryRunAsync();
  await _appLaunchRoutine().tryRunAsync();
  await _initIfDesktop().tryRunAsync();
}

/// Pdfrx check initialized
// bool _isPdfrxInitialized = false;

Future<void> _appLaunchRoutine() async {
  /// Clear App Cache every 23 hours
  final lastDateHive = DateTime.tryParse(
    (await HiveDataKey.lastClearedCacheDate.name.tryGet<String>()).data ?? '',
  );
  if (lastDateHive == null) {
    await HiveDataKey.lastClearedCacheDate.name.trySet(
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

// Future<void> _firstAppLaunch() async {
// final isFirstLaunch = (await AppHiveData.instance.getData(key: HiveDataPathKey.isFirstLaunch.name)) as bool?;
// if (isFirstLaunch == null) {

//   final referenceCollection = Module.create(
//     parentId: AppCourseCollections.references.name,
//     uid: AppCourseCollections.references.name,
//     title: "References",
//     description: "This is the Default App Reference collections",
//   );
//   final bookMarkCollection = Module.create(
//     parentId: AppCourseCollections.bookmarks.name,
//     uid: AppCourseCollections.bookmarks.name,
//     title: "Bookmarks",
//     description: "This is the Default App Bookmark collections",
//   );
//   await ModuleRepo.add(referenceCollection);
//   await ModuleRepo.add(bookMarkCollection);
//   await HiveDataPathKey.isFirstLaunch.name.trySetHiveData(value: false);
// }
// }

Future<void> _initIfDesktop() async {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      // defaultTargetPlatform == TargetPlatform.macOS ||
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

// ///
// Future<void> pdfrxFlutterInitializeInIsolate({
//   bool dismissPdfiumWasmWarnings = false,
// }) async {
//   if (_isInitialized) return;

//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//   } catch (e) {
//     log("Couldn't init flutter bindings");
//   }

//   if (pdfrxEntryFunctionsOverride != null) {
//     PdfrxEntryFunctions.instance = pdfrxEntryFunctionsOverride!;
//   }

//   Pdfrx.loadAsset ??= (name) async {
//     final asset = await rootBundle.load(name);
//     return asset.buffer.asUint8List();
//   };
//   Pdfrx.cacheDirectoryPath ??= await pp.getApplicationCacheDirectory().then(
//     (r) => r.path,
//   );

//   // Checking pdfium.wasm availability for Web and debug builds.
//   if (kDebugMode && !dismissPdfiumWasmWarnings) {
//     () async {
//       try {
//         await Pdfrx.loadAsset!('packages/pdfrx/assets/pdfium.wasm');
//         if (!kIsWeb) {
//           debugPrint(
//             '⚠️\u001b[37;41;1mDEBUG TIME WARNING: The app is bundling PDFium WASM module (about 4MB) as a part of the app.\u001b[0m\n'
//             '\u001b[91mFor production use (not for Web/Debug), you\'d better remove the PDFium WASM module.\u001b[0m\n'
//             '\u001b[91mSee https://github.com/espresso3389/pdfrx/tree/master/packages/pdfrx#note-for-building-release-builds for more details.\u001b[0m\n',
//           );
//         }
//       } catch (e) {
//         if (kIsWeb) {
//           debugPrint(
//             '⚠️\u001b[37;41;1mDEBUG TIME WARNING: The app is running on Web, but the PDFium WASM module is not bundled with the app.\u001b[0m\n'
//             '\u001b[91mMake sure to include the PDFium WASM module in your web project.\u001b[0m\n'
//             '\u001b[91mIf you explicitly set Pdfrx.pdfiumWasmModulesUrl, you can ignore this warning.\u001b[0m\n'
//             '\u001b[91mSee https://github.com/espresso3389/pdfrx/tree/master/packages/pdfrx#note-for-building-release-builds for more details.\u001b[0m\n',
//           );
//         }
//       }
//     }();
//   }

//   /// NOTE: it's actually async, but hopefully, it finishes quickly...
//   await platformInitialize();

//   _isInitialized = true;
// }

// ================================================
// EMERGENCY REPAIR: Clear Smart Switch ghost locks
// ================================================
Future<void> repairCorruptDB() async {
  if (!kIsWeb) {
    try {
      final targetFiles = await pp.getApplicationDocumentsDirectory().then(
        (dir) => [
          File('${dir.path}/isar.lock'),
          File('${dir.path}/default.lock'),
        ],
      );

      await Future.wait(
        targetFiles.map((file) async {
          if (await file.exists()) {
            await file.delete();
            debugPrint("SlideSync System: Cleared stale lock: ${file.path}");
          }
        }),
      );
    } catch (e, stack) {
      debugPrint("SlideSync System Repair Warning: $e");
      debugPrint(stack.toString());
    }
  }
}
