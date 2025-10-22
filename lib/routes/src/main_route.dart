import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/features/desktop/presentation/ui/desktop_main_view.dart';
import 'package:slidesync/features/main/presentation/home/ui/desktop_home/desktop_home_view.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/features/main/presentation/main/ui/main_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_body/recents_view.dart';

final mainRoute = GoRoute(
  path: '/',
  builder: (context, state) => Platform.isWindows ? const DesktopHomeView() : const MainView(tabIndex: 0),
  routes: [
    // HOME ROUTE
    GoRoute(
      name: Routes.home.name,
      path: Routes.home.subPath,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
        state.pageKey,
        child: Platform.isWindows ? const DesktopMainView(tabIndex: 0) : const MainView(tabIndex: 0),
      ),
      routes: [
        GoRoute(
          name: Routes.recentsView.name,
          path: Routes.recentsView.subPath,
          pageBuilder: (context, state) => defaultTransition(state.pageKey, child: const RecentsView()),
        ),
      ],
    ),

    // LIBRARY ROUTE
    GoRoute(
      name: Routes.library.name,
      path: Routes.library.subPath,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
        state.pageKey,
        child: Platform.isWindows ? const DesktopHomeView() : const MainView(tabIndex: 1),
      ),
    ),

    // EXPLORE ROUTE
    GoRoute(
      name: Routes.explore.name,
      path: Routes.explore.subPath,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
        state.pageKey,
        child: Platform.isWindows ? const DesktopHomeView() : const MainView(tabIndex: 2),
      ),
    ),
  ],
);
