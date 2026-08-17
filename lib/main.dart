import 'package:flutter/material.dart';
import 'package:slidesync/app.dart';
<<<<<<< HEAD
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/firebase_options.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';

// import 'dev/provider_observer.dart';
// import 'firebase_options.dart';
import 'dart:async';
import 'dart:io';

// ignore: implementation_imports
import 'package:pdfrx/src/utils/platform.dart';

part 'main_.dart';
=======
import 'package:slidesync/app/startup.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
>>>>>>> a28bdf2 (quick changes)

Object? globalInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  startup().then((_) => runApp(const ProviderScope(child: App())));
}
