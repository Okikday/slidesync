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

import 'dev/provider_observer.dart';
import 'firebase_options.dart';

final obs = ActiveProvidersObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await AppHiveData.instance.initialize();
  await dotenv.load();
  if (!kIsWeb) await IsarData.initializeDefault();
  pdfrxFlutterInitialize();
  await IsolateWorker.init();
  runApp(
    const ProviderScope(
      // observers: [obs],
      child: App(),
    ),
  );
}
