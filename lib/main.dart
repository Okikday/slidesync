import 'package:flutter/material.dart';
import 'package:slidesync/app.dart';
import 'package:slidesync/app/startup.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

Object? globalInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  startup().then((_) => runApp(const ProviderScope(child: App())));
}
