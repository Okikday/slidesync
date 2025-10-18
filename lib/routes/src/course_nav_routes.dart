import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials_view.dart';

final courseNavRoute = GoRoute(
  name: Routes.courseDetails.name,
  path: Routes.courseDetails.path,

  pageBuilder: (context, state) => defaultTransition(
    state.pageKey,
    defaultIncoming: TransitionType.scale(from: .8, to: 1, alignment: Alignment.bottomCenter, fade: true),
    // defaultIncomingDuration: Durations.medium2,
    // defaultIncomingCurve: Curves.fastEaseInToSlowEaseOut,
    child: CourseDetailsView(courseId: state.extra as String),
  ),
  routes: [
    GoRoute(
      name: Routes.courseMaterials.name,
      path: Routes.courseMaterials.subPath,
      pageBuilder: (context, state) =>
          defaultTransition(state.pageKey, child: CourseMaterialsView(collection: state.extra as CourseCollection)),
    ),
  ],
);
