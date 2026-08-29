import 'package:flutter/material.dart';
import 'package:slidesync/app/src/ui/app.dart';
import 'package:slidesync/app/src/startup.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

Object? globalInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  startup().then((_) => runApp(const ProviderScope(child: App())));
}
