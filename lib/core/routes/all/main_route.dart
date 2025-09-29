import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/features/all_tabs/main/main_view/main_view.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_body/recents_view.dart';

final mainRoute = GoRoute(
  path: '/',
  builder: (context, state) => const MainView(tabIndex: 0),
  routes: [
    // HOME ROUTE
    GoRoute(
      name: Routes.home.name,
      path: Routes.home.subPath,
      pageBuilder: (context, state) =>
          PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 0)),
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
      pageBuilder: (context, state) =>
          PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 1)),
    ),

    // EXPLORE ROUTE
    GoRoute(
      name: Routes.explore.name,
      path: Routes.explore.subPath,
      pageBuilder: (context, state) =>
          PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 1)),
    ),
  ],
);
