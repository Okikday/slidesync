import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/ui/screens/modules_view.dart';
import 'package:slidesync/features/browse/ui/screens/course_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/ui/screens/module_contents_view.dart';
import 'package:slidesync/routes/transition.dart';

final courseNavRoutes = [
  GoRoute(
    name: Routes.courseDetails.name,
    path: Routes.courseDetails.path,

    pageBuilder: (context, state) => defaultTransition(
      state.pageKey,
      defaultIncoming: TransitionType.topLevel,
      //.scale(from: .8, to: 1, alignment: Alignment.bottomCenter, fade: true)
      // defaultIncomingDuration: Durations.medium2,
      // defaultIncomingCurve: Curves.fastEaseInToSlowEaseOut,
      child: CourseView(courseId: state.extra as String),
    ),
    routes: [
      GoRoute(
        name: Routes.moduleContentsView.name,
        path: Routes.moduleContentsView.subPath,
        // pageBuilder: (context, state) => defaultTransition(
        //   state.pageKey,
        //   outgoing: TransitionType.fade,
        //   child: CollectionMaterialsView(collection: state.extra as CourseCollection, isFullScreen: false),
        // ),
        builder: (context, state) => ModuleContentsView(collection: state.extra as Module, isFullScreen: false),
      ),
    ],
  ),
  GoRoute(
    name: Routes.modulesView.name,
    path: Routes.modulesView.path,
    // pageBuilder: (context, state) =>
    //     defaultTransition(state.pageKey, child: CollectionsView(courseId: (state.extra as String))),
    builder: (context, state) => ModulesView(courseId: (state.extra as String)),
  ),
];
