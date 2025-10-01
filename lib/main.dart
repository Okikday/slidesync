import 'package:firebase_core/firebase_core.dart';
import 'package:slidesync/test/provider_observer.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/app.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/storage/isar_data/isar_schemas.dart';

final obs = ActiveProvidersObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppHiveData.instance.initialize();
  await dotenv.load();

  if (!kIsWeb) await IsarData.initialize(collectionSchemas: isarSchemas);
  pdfrxFlutterInitialize();

  runApp(
    ProviderScope(
      // observers: [obs],
      child: const App(),
    ),
  );
}
