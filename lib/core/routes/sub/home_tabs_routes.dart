import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/features/main/presentation/views/main_view.dart';
import 'package:slidesync/core/routes/routes_strings.dart';

class HomeTabsRoutes {
  static List<GoRoute> routes = [
    // HOME ROUTE
    GoRoute(
      path: RoutesStrings.homeView,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 0)),
    ),

    // LIBRARY ROUTE
    GoRoute(
      path: RoutesStrings.libraryView,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 1)),
    ),

    // EXPLORE ROUTE
    GoRoute(
      path: RoutesStrings.exploreView,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 1)),
    ),

    
  ];
}
