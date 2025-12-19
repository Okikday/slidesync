import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/browse/course/ui/screens/collections_view.dart';
import 'package:slidesync/features/browse/course/ui/screens/course_details_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/collection/ui/screens/collection_materials_view.dart';
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
      child: CourseDetailsView(courseId: state.extra as String),
    ),
    routes: [
      GoRoute(
        name: Routes.courseMaterials.name,
        path: Routes.courseMaterials.subPath,
        pageBuilder: (context, state) => defaultTransition(
          state.pageKey,
          child: CollectionMaterialsView(collection: state.extra as CourseCollection, isFullScreen: false),
        ),
      ),
    ],
  ),
  GoRoute(
    name: Routes.collectionsView.name,
    path: Routes.collectionsView.path,
    pageBuilder: (context, state) =>
        defaultTransition(state.pageKey, child: CollectionsView(courseId: (state.extra as String))),
  ),
];
