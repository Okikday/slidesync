import 'dart:io';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' hide CustomTransitionPage;
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details_view.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials_view.dart';
import 'package:slidesync/features/desktop/presentation/ui/views/desktop_shell_view.dart';
import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_body/recents_view.dart';
import 'package:slidesync/features/main/presentation/main/ui/main_view.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections_view.dart';
import 'package:slidesync/features/manage/presentation/contents/ui/modify_contents_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/create_course_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/modify_course_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course_view.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/routes/src/content_viewer_route.dart';
import 'package:slidesync/routes/src/course_mgmt_routes.dart';
import 'package:slidesync/routes/src/settings_route.dart';
import 'package:slidesync/splash_view.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter mainRouter = Platform.isWindows ? _desktopRouter : _mobileRouter;

  // MOBILE ROUTER (Your existing setup)
  static final GoRouter _mobileRouter = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    routes: [
      splashRoute,
      // authRoute,
      _mobileMainRoute,
      ...courseMgmtRoutes,
      contentViewerRoute,
      _mobileCourseNavRoute,
      settingsRoute,
    ],
  );

  // DESKTOP ROUTER (New 3-panel layout)
  static final GoRouter _desktopRouter = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: rootNavigatorKey,
    routes: [
      splashRoute,

      // Desktop Shell Route with 3 panels
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return DesktopShellView(child: child);
        },
        routes: [
          GoRoute(path: '/', redirect: (context, state) => Routes.home.path),

          // Empty placeholder route - the "home" for the rightmost panel
          GoRoute(
            name: Routes.home.name,
            path: Routes.home.path,
            pageBuilder: (context, state) => const NoTransitionPage(child: _EmptyStatePlaceholder()),
          ),

          // Library route - also shows empty placeholder
          GoRoute(
            name: Routes.library.name,
            path: Routes.library.path,
            pageBuilder: (context, state) => const NoTransitionPage(child: _EmptyStatePlaceholder()),
          ),

          // Course Details in rightmost panel
          GoRoute(
            name: Routes.courseDetails.name,
            path: Routes.courseDetails.path,
            pageBuilder: (context, state) {
              final courseId = state.extra as String;
              return CustomTransitionPage(
                key: ValueKey('course_$courseId'), // Unique key per course
                transitionsBuilder: _desktopPanelTransition,
                child: CourseDetailsView(courseId: courseId),
              );
            },
            routes: [
              GoRoute(
                name: Routes.courseMaterials.name,
                path: Routes.courseMaterials.subPath,
                pageBuilder: (context, state) => defaultTransition(
                  state.pageKey,
                  child: CourseMaterialsView(collection: state.extra as CourseCollection, isFullScreen: false),
                ),
              ),
            ],
          ),

          // Course Management routes in rightmost panel
          GoRoute(
            name: Routes.createCourse.name,
            path: Routes.createCourse.path,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionsBuilder: _desktopPanelTransition,
              child: const CreateCourseView(),
            ),
          ),
          GoRoute(
            name: Routes.selectToModifyCourse.name,
            path: Routes.selectToModifyCourse.path,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionsBuilder: _desktopPanelTransition,
              child: SelectToModifyCourseView(),
            ),
          ),
          GoRoute(
            name: Routes.modifyCourse.name,
            path: Routes.modifyCourse.path,
            pageBuilder: (context, state) {
              final courseId = state.extra as String;
              return CustomTransitionPage(
                key: state.pageKey,
                transitionsBuilder: _desktopPanelTransition,
                child: ModifyCourseView(courseId: courseId),
              );
            },
            routes: [
              GoRoute(
                name: Routes.modifyCollections.name,
                path: Routes.modifyCollections.subPath,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  transitionsBuilder: _desktopPanelTransition,
                  child: ModifyCollectionsView(courseId: state.extra as String),
                ),
                routes: [
                  GoRoute(
                    name: Routes.modifyContents.name,
                    path: Routes.modifyContents.subPath,
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      transitionsBuilder: _desktopPanelTransition,
                      child: ModifyContentsView(collectionId: state.extra as String),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        name: "${Routes.courseMaterials.name}full",
        path: Routes.courseMaterials.path,
        pageBuilder: (context, state) => defaultTransition(
          state.pageKey,
          child: CourseMaterialsView(collection: state.extra as CourseCollection, isFullScreen: true),
        ),
      ),

      // Full-screen overlays (outside shell)
      contentViewerRoute,
      GoRoute(
        name: Routes.recentsView.name,
        path: Routes.recentsView.path,
        pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
          state.pageKey,
          type: TransitionType.rightToLeftWithFade,
          duration: Durations.extralong1,
          child: const RecentsView(),
        ),
      ),
      settingsRoute,
    ],
  );

  // Desktop panel transition (slide from right)
  static Widget _desktopPanelTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

// Mobile routes (existing setup)
final _mobileMainRoute = GoRoute(
  path: '/',
  builder: (context, state) => const MainView(tabIndex: 0),
  routes: [
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
    GoRoute(
      name: Routes.library.name,
      path: Routes.library.subPath,
      pageBuilder: (context, state) =>
          PageAnimation.buildCustomTransitionPage(state.pageKey, child: const MainView(tabIndex: 1)),
    ),
  ],
);

final _mobileCourseNavRoute = GoRoute(
  name: Routes.courseDetails.name,
  path: Routes.courseDetails.path,
  pageBuilder: (context, state) => defaultTransition(
    state.pageKey,
    defaultIncoming: TransitionType.topLevel,
    child: CourseDetailsView(courseId: state.extra as String),
  ),
  routes: [
    GoRoute(
      name: Routes.courseMaterials.name,
      path: Routes.courseMaterials.subPath,
      pageBuilder: (context, state) => defaultTransition(
        state.pageKey,
        child: CourseMaterialsView(collection: state.extra as CourseCollection, isFullScreen: false),
      ),
    ),
  ],
);

final splashRoute = GoRoute(
  path: Routes.splash.path,
  builder: (context, state) => const SplashView(),
  redirect: (context, state) async {
    return Routes.home.path;
    // final isUserSignedIn = await UserDataFunctions().isUserSignedIn();
    // final hasOnboarded = await AppHiveData.instance.getData(key: HiveDataPathKey.hasOnboarded.name) as bool?;
    // if (hasOnboarded == false) return Routes.welcome.path;
    // if (isUserSignedIn) return Routes.home.path;
    // return Routes.auth.path;
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

class _EmptyStatePlaceholder extends StatelessWidget {
  const _EmptyStatePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Select an item to view details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a course or item from the left panels',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}
