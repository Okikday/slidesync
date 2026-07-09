// import 'package:firebase_core/firebase_core.dart';

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';

import 'package:slidesync/app.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/firebase_options.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:window_manager/window_manager.dart';

// import 'dev/provider_observer.dart';
// import 'firebase_options.dart';
import 'dart:async';

// ignore: implementation_imports
import 'package:pdfrx/src/utils/platform.dart';

part 'main_.dart';

Object? globalInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final result = await Result.tryRunAsync(() => _initialize());

  // Store the error payload globally if initialization failed
  if (result.data != null) {
    globalInitError = result.data;
  }

  runApp(const ProviderScope(child: App()));
}

Future<void> _initialize() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ==========================================
  // EMERGENCY REPAIR: Clear Smart Switch ghost locks
  // ==========================================
  if (!kIsWeb) {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // Check for both Isar and standard Hive lock signatures
      final targets = [
        File('${dir.path}/isar.lock'),
        File('${dir.path}/default.lock'),
      ];

      for (final file in targets) {
        if (await file.exists()) {
          await file.delete();
          debugPrint(
            "SlideSync System: Cleared stale migration lock: ${file.path}",
          );
        }
      }
    } catch (e, stack) {
      debugPrint("SlideSync System Repair Warning: $e");
      debugPrint(stack.toString());
    }
  }
  // ==========================================
  await Hive.initFlutter();
  await AppHiveData.instance.initialize();

  if (!kIsWeb) await IsarData.initializeDefault();

  await NotificationService.instance.initialize();

  pdfrxFlutterInitialize();
  await _appLaunchRoutine();
  await _initIfDesktop();
}
