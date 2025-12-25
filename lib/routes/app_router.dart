import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:slidesync/routes/src/content_viewer_route.dart';
import 'package:slidesync/routes/src/course_mgmt_routes.dart';
import 'package:slidesync/routes/src/course_nav_routes.dart';
import 'package:slidesync/routes/src/main_route.dart';
import 'package:slidesync/routes/src/settings_route.dart';
import 'package:slidesync/routes/src/sync_route.dart';
import 'package:slidesync/splash_view.dart';

import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter mainRouter = _router;

  static final GoRouter _router = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    observers: [HeroineController()],
    routes: [
      splashRoute,
      // authRoute,
      // onboardingRoute,

      // Home, Library, Explore tabs
      mainRoute,

      // MANAGE COURSES
      // -> CREATE COURSE
      // -> SELECT TO MODIFY COURSE / MODIFY EXISTING COURSE
      // -> MODIFY COURSE
      //    -> EDIT COURSE
      ...courseMgmtRoutes,
      contentViewerRoute,

      ...courseNavRoutes,

      settingsRoute,
      syncRoute,
    ],
  );
}

final splashRoute = GoRoute(
  path: Routes.splash.path,
  builder: (context, state) => const SplashView(),
  redirect: (context, state) async {
    return Routes.home.path;
    // final isUserSignedIn = await UserDataFunctions().isUserSignedIn();
    // final hasOnboarded = await AppHiveData.instance.getData(key: HiveDataPathKey.hasOnboarded.name) as bool?;
    // if (hasOnboarded == null && !isUserSignedIn) return Routes.welcome.path;
    // if (isUserSignedIn) return Routes.home.path;
    // return Routes.auth.path;
  },
);
