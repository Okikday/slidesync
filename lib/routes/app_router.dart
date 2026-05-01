import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/routes/src/content_viewer_route.dart';
import 'package:slidesync/routes/src/contents_action_routes.dart';
import 'package:slidesync/routes/src/course_mgmt_routes.dart';
import 'package:slidesync/routes/src/course_nav_routes.dart';
import 'package:slidesync/routes/src/main_route.dart';
import 'package:slidesync/routes/src/settings_route.dart';
import 'package:slidesync/routes/src/sync_route.dart';
import 'package:slidesync/routes/src/auth_route.dart';
import 'package:slidesync/routes/src/onboarding_route.dart';
import 'package:slidesync/routes/src/test_routes.dart';
import 'package:slidesync/splash_view.dart';

import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter mainRouter = _router;

  static final GoRouter _router = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    observers: [HeroineController()],
    onException: (context, state, router) {
    final location = state.uri.toString();
    if (location.startsWith('content://') || location.startsWith('file://')) return;
    router.go(Routes.home.path);
  },
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
      ...contentViewerRoutes,

      ...courseNavRoutes,
      ...contentActionsRoutes,

      settingsRoute,
      syncRoute,
      ...testRoutes,
    ],
  );
}

final splashRoute = GoRoute(
  path: Routes.splash.path,
  builder: (context, state) => const SplashView(),
  redirect: (context, state) async {
    // return Routes.home.path;
    final isUserSignedIn = await UserDataFunctions().isUserSignedIn();
    final hasOnboarded = await AppHiveData.instance.getData(key: HiveDataPathKey.hasOnboarded.name) as bool?;
    if (hasOnboarded == null && !isUserSignedIn) return Routes.welcome.path;
    if (hasOnboarded == true || isUserSignedIn) return Routes.home.path;
    return Routes.auth.path;
  },
);
