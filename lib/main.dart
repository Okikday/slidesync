
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/constants/constants.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/file_utils.dart';

import 'package:slidesync/app.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

import 'dev/provider_observer.dart';
import 'firebase_options.dart';

final obs = ActiveProvidersObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Result.tryRunAsync(() async => await _initialize());

  runApp(
    const ProviderScope(
      // observers: [obs],
      child: App(),
    ),
  );
}

Future<void> _initialize() async {
  await dotenv.load();
  // {
  //   final supabaseUrl = dotenv.env['SUPABASE_STORAGE_URL'];
  //   final supabaseSecretKey = dotenv.env['SECRET_ACCESS_KEY'];
  //   if (supabaseUrl != null && supabaseSecretKey != null) {
  //     final init = await Supabase.initialize(url: supabaseUrl, anonKey: supabaseSecretKey);
  //     log("Supabase init: $init");
  //   }
  // }
  await Hive.initFlutter();
  await AppHiveData.instance.initialize();

  if (!kIsWeb) await IsarData.initializeDefault();
  pdfrxFlutterInitialize();
  await _firstAppLaunch();
  await _appLaunchRoutine();
}

Future<void> _appLaunchRoutine() async {
  /// Clear App Cache every 23 hours
  final lastDateHive =
      (await AppHiveData.instance.getData(key: HiveDataPathKey.lastClearedCacheDate.name)) as DateTime?;
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
    final token = RootIsolateToken.instance;
    if (token != null) {
      compute(FileUtils.deleteEmptyCoursesDirsInIsolate, {'rootIsolateToken': token});
      await AppHiveData.instance.setData(
        key: HiveDataPathKey.lastClearedCacheDate.name,
        value: DateTime.now().toIso8601String(),
      );
    }
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
