import 'package:go_router/go_router.dart';
import 'package:slidesync/features/sync/ui/screens/sync_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/routes/transition.dart';

final syncRoute = GoRoute(
  path: Routes.sync.path,
  name: Routes.sync.name,
  pageBuilder: (context, state) => defaultTransition(state.pageKey, child: SyncView()),
);
