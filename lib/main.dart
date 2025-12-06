// import 'package:firebase_core/firebase_core.dart';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/constants/constants.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';

import 'package:slidesync/app.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:window_manager/window_manager.dart';

import 'dev/provider_observer.dart';
// import 'firebase_options.dart';

part 'main_.dart';

final obs = ActiveProvidersObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Result.tryRunAsync(() async => await _initialize());

  runApp(
    const ProviderScope(
      // observers: [obs],`
      child: App(),
    ),
  );
}

Future<void> _initialize() async {
  await dotenv.load();
  await Hive.initFlutter();
  await AppHiveData.instance.initialize();

  if (!kIsWeb) await IsarData.initializeDefault();
  pdfrxFlutterInitialize();
  await _firstAppLaunch();
  await _appLaunchRoutine();
  await _initDesktop();
}
