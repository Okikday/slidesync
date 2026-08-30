import 'package:flutter/material.dart';
import 'package:slidesync/app/src/ui/app.dart';
import 'package:slidesync/app/src/startup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Object? globalInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  startup().then((_) => runApp(const ProviderScope(child: App())));
}
