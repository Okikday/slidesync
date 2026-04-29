import 'package:go_router/go_router.dart';
import 'package:slidesync/features/browse/ui/screens/create_course_view.dart';
import 'package:slidesync/routes/routes.dart';

final courseMgmtRoutes = [
  //CREATE COURSE VIEW NAVIGATION
  GoRoute(
    name: Routes.createCourse.name,
    path: Routes.createCourse.path,
    builder: (context, state) {
      final pushToCreated = state.extra as bool? ?? true;
      return CreateCourseView(pushToCreated: pushToCreated);
    },
  ),

  // // SELECT TO MODIFY COURSE VIEW NAVIGATION
  // GoRoute(
  //   name: Routes.selectToModifyCourse.name,
  //   path: Routes.selectToModifyCourse.path,
  //   pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
  //     state.pageKey,
  //     type: TransitionType.rightToLeftWithFade,
  //     duration: Durations.extralong1,
  //     reverseDuration: Durations.medium1,
  //     curve: CustomCurves.defaultIosSpring,
  //     child: SelectToModifyCourseView(),
  //   ),
  // ),
];
