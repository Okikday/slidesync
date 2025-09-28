import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_details_view.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials_view.dart';

final courseNavRoute = GoRoute(
  name: Routes.courseDetails.name,
  path: Routes.courseDetails.path,

  pageBuilder: (context, state) => defaultTransition(
    state.pageKey,
    defaultIncoming: TransitionType.fade,
    // defaultIncomingDuration: Durations.medium2,
    // defaultIncomingCurve: Curves.fastEaseInToSlowEaseOut,
    child: CourseDetailsView(course: state.extra as Course),
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
