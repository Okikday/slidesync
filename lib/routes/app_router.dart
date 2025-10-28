import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/auth/domain/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/routes/src/auth_route.dart';
import 'package:slidesync/routes/src/content_viewer_route.dart';
import 'package:slidesync/routes/src/course_mgmt_routes.dart';
import 'package:slidesync/routes/src/course_nav_routes.dart';
import 'package:slidesync/routes/src/main_route.dart';
import 'package:slidesync/routes/src/onboarding_route.dart';
import 'package:slidesync/routes/src/settings_route.dart';
import 'package:slidesync/splash_view.dart';

import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter mainRouter = _router;

  static final GoRouter _router = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    routes: [
      splashRoute,
      authRoute,
      onboardingRoute,

      // Home, Library, Explore tabs
      mainRoute,

      // MANAGE COURSES
      // -> CREATE COURSE
      // -> SELECT TO MODIFY COURSE / MODIFY EXISTING COURSE
      // -> MODIFY COURSE
      //    -> EDIT COURSE
      ...courseMgmtRoutes,
      contentViewerRoute,

      courseNavRoute,

      settingsRoute,
    ],
  );
}

final splashRoute = GoRoute(
  path: Routes.splash.path,
  builder: (context, state) => const SplashView(),
  redirect: (context, state) async {
    final isUserSignedIn = await UserDataFunctions().isUserSignedIn();
    final hasOnboarded = await AppHiveData.instance.getData(key: HiveDataPathKey.hasOnboarded.name) as bool?;
    if (hasOnboarded == null && !isUserSignedIn) return Routes.welcome.path;
    if (isUserSignedIn) return Routes.home.path;
    return Routes.auth.path;
  },
);

dynamic defaultTransition(
  LocalKey pageKey, {
  required Widget child,
  TransitionType defaultIncoming = TransitionType.rightToLeft,
  TransitionType? outgoing,
}) {
  return PageAnimation.buildCustomTransitionPage(
    pageKey,
    type: TransitionType.paired(
      incoming: defaultIncoming,
      outgoing: outgoing ?? TransitionType.slide(begin: const Offset(0, 0), end: const Offset(-0.4, 0)),
      outgoingDuration: Durations.medium4,
      reverseDuration: Durations.medium2,
      curve: CustomCurves.defaultIosSpring,
      reverseCurve: CustomCurves.defaultIosSpring,
    ),
    duration: Durations.extralong2,
    reverseDuration: Durations.medium2,

    child: child,
  );
}
