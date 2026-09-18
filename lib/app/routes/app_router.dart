import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:slidesync/app/routes/src/splash_route.dart';
import 'package:slidesync/app/routes/sub/content_viewer_route.dart';
import 'package:slidesync/app/routes/sub/contents_action_routes.dart';
import 'package:slidesync/app/routes/sub/course_mgmt_routes.dart';
import 'package:slidesync/app/routes/sub/course_nav_routes.dart';
import 'package:slidesync/app/routes/sub/main_route.dart';
import 'package:slidesync/app/routes/sub/settings_route.dart';
import 'package:slidesync/app/routes/sub/sync_route.dart';
import 'package:slidesync/app/routes/sub/auth_route.dart';
import 'package:slidesync/app/routes/sub/onboarding_route.dart';
import 'package:slidesync/app/routes/sub/test_routes.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/main/ui/screens/main_view.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _mainNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter mainRouter = _router;
  static GlobalKey<NavigatorState> get mainNavKey => _mainNavigatorKey;

  static final GoRouter _router = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    observers: [HeroineController()],
    onException: (context, state, router) {
      final location = state.uri.toString();
      if (location.startsWith('content://') || location.startsWith('file://')) {
        return;
      }
      router.go(Routes.home.path);
    },
    routes: [
      splashRoute,
      authRoute,
      onboardingRoute,
      ShellRoute(
        navigatorKey: _mainNavigatorKey,
        builder: (context, state, child) {
          return Builder(
            builder: (context) {
              log(
                'AppRouter: ShellRoute builder called with location: ${state.matchedLocation}, ${state.pageKey}',
              );
              return ResponsiveView(
                route: state.matchedLocation.replaceFirst('/', ''),
                buildAreaWidget: (context, area) {
                  return child;
                },
              );
            },
          );
        },
        routes: [
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
        ],
      ),
      ...testRoutes,
    ],
  );
}

class ResponsiveView extends StatelessWidget {
  final String route;
  final Widget Function(BuildContext, Area) buildAreaWidget;
  const ResponsiveView({
    super.key,
    required this.route,
    required this.buildAreaWidget,
  });

  static final exclusion = {
    Routes.home.name,
    Routes.library.name,
    Routes.explore.name,
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = DeviceUtils.isDesktopSize(context);
    return MultiSplitView(
      resizable: true,
      dividerThickness: 4,
      dividerHighlightColor: Colors.blueGrey.withAlpha(50),
      builder: (context, area) {
        log(route);
        return isDesktop
            ? switch (area.id) {
                MainPanes.mainContent => MainView(tabIndex: 0),
                MainPanes.contentSidebar => () {
                  if (exclusion.contains(route)) {
                    return null;
                  } else {
                    return buildAreaWidget(context, area);
                  }
                }(),
                _ => null,
              }
            : area.id != MainPanes.mainContent
            ? null
            : buildAreaWidget(context, area);
      },
      initialAreas: [
        Area(id: MainPanes.mainContent),
        Area(id: MainPanes.contentSidebar),
      ],
    );
  }
}
