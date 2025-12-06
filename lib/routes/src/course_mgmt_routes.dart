import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/features/browse/course/ui/screens/collections_view.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/features/browse/course/ui/screens/create_course_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/routes/transition.dart';

final courseMgmtRoutes = [
  //CREATE COURSE VIEW NAVIGATION
  GoRoute(
    name: Routes.createCourse.name,
    path: Routes.createCourse.path,
    pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
      state.pageKey,
      type: TransitionType.rightToLeftWithFade,
      duration: Durations.extralong1,
      reverseDuration: Durations.medium1,
      curve: CustomCurves.defaultIosSpring,
      child: const CreateCourseView(),
    ),
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
