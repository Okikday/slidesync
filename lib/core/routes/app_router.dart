import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/all/auth_route.dart';
import 'package:slidesync/core/routes/all/course_nav_routes.dart';
import 'package:slidesync/core/routes/all/settings_route.dart';
import 'package:slidesync/core/routes/all/course_mgmt_routes.dart';
import 'package:slidesync/core/routes/all/home_tabs_routes.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/auth/domain/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/splash_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class RouteManager {
  static final GoRouter mainRouter = _router;

  static final GoRouter _router = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    routes: [
      splashRoute,
      authRoute,

      // Home, Library, Explore tabs
      mainRoute,

      // MANAGE COURSES
      // -> CREATE COURSE
      // -> SELECT TO MODIFY COURSE / MODIFY EXISTING COURSE
      // -> MODIFY COURSE
      //    -> EDIT COURSE
      ...courseMgmtRoutes,

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
    if (hasOnboarded == false) return Routes.welcome.path;
    if (isUserSignedIn) return Routes.home.path;
    return Routes.auth.path;
  },
);

dynamic defaultTransition(
  pageKey, {
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
