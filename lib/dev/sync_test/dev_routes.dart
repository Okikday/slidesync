import 'package:flutter/material.dart';
import 'package:slidesync/dev/sync_test/ui/screens/sync_test_page.dart';

class DevRoutes {
  static const String syncTest = '/dev/sync-test';

  static Map<String, WidgetBuilder> get routes => {syncTest: (context) => const SyncTestPage()};

  static void navigateToSyncTest(BuildContext context) {
    Navigator.pushNamed(context, syncTest);
  }
}
