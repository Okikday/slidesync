import 'package:go_router/go_router.dart';
import 'package:slidesync/dev/sync_test/ui/screens/sync_test_page.dart';
import 'package:slidesync/routes/routes.dart';

final testRoutes = [
  GoRoute(path: Routes.syncTest.path, name: Routes.syncTest.name, builder: (context, state) => SyncTestPage()),
];
