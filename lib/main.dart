import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/isolate_worker.dart';

import 'package:slidesync/app.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  {
    final supabaseUrl = dotenv.env['SUPABASE_STORAGE_URL'];
    final supabaseSecretKey = dotenv.env['SECRET_ACCESS_KEY'];
    if (supabaseUrl != null && supabaseSecretKey != null) {
      final init = await Supabase.initialize(url: supabaseUrl, anonKey: supabaseSecretKey);
      log("Supabase init: $init");
    }
  }
  await Hive.initFlutter();
  await AppHiveData.instance.initialize();

  if (!kIsWeb) await IsarData.initializeDefault();
  pdfrxFlutterInitialize();
  await IsolateWorker.init();
}
