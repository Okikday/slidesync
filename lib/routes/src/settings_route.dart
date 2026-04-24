import 'package:go_router/go_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/settings/ui/screens/settings_view.dart';

final settingsRoute = GoRoute(
  name: Routes.settings.name,
  path: Routes.settings.path,
  // pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
  //   state.pageKey,
  //   type: TransitionType.rightToLeft,
  //   duration: Durations.extralong1,
  //   reverseDuration: Durations.medium1,
  //   curve: CustomCurves.defaultIosSpring,
  //   child: const SettingsView(),
  // ),
  builder: (context, state) => const SettingsView(),
);
