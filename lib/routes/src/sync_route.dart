import 'package:go_router/go_router.dart';
import 'package:slidesync/features/sync/ui/screens/sync_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/routes/transition.dart';

final syncRoute = GoRoute(
  path: Routes.syncView.path,
  name: Routes.syncView.name,
  pageBuilder: (context, state) => defaultTransition(state.pageKey, child: SyncView()),
);
