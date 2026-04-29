// import 'package:firebase_core/firebase_core.dart';

import 'dart:developer';

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

import 'package:slidesync/app.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/firebase_options.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:window_manager/window_manager.dart';

// import 'dev/provider_observer.dart';
// import 'firebase_options.dart';
import 'dart:async';

// ignore: implementation_imports
import 'package:pdfrx/src/utils/platform.dart';

part 'main_.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Result.tryRunAsync(() => _initialize());

  runApp(const ProviderScope(child: App()));
}

Future<void> _initialize() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await AppHiveData.instance.initialize();

  await dotenv.load();

  if (!kIsWeb) await IsarData.initializeDefault();

  await NotificationService.instance.initialize();

  pdfrxFlutterInitialize();

  await _firstAppLaunch();
  await _appLaunchRoutine();
  await _initIfDesktop();
}
