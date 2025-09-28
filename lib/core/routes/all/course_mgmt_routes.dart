import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections_view.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/modify_contents_view.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/create_course_view.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/modify_course_view.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/select_to_modify_course_view.dart';
import 'package:slidesync/core/routes/routes.dart';

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
      child: CreateCourseView(),
    ),
  ),

  // SELECT TO MODIFY COURSE VIEW NAVIGATION
  GoRoute(
    name: Routes.selectToModifyCourse.name,
    path: Routes.selectToModifyCourse.path,
    pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
      state.pageKey,
      type: TransitionType.rightToLeftWithFade,
      duration: Durations.extralong1,
      reverseDuration: Durations.medium1,
      curve: CustomCurves.defaultIosSpring,
      child: SelectToModifyCourseView(),
    ),
  ),

  //MODIFY COURSE VIEW NAVIGATION
  GoRoute(
    name: Routes.modifyCourse.name,
    path: Routes.modifyCourse.path,
    pageBuilder: (context, state) =>
        defaultTransition(state.pageKey, child: ModifyCourseView(course: state.extra as Course)),
    routes: [
      //MODIFY COLLECTIONS VIEW NAVIGATION
      GoRoute(
        name: Routes.modifyCollections.name,
        path: Routes.modifyCollections.subPath,
        pageBuilder: (context, state) => defaultTransition(
          state.pageKey,
          defaultIncoming: TransitionType.slide(begin: const Offset(0, 0.6), end: Offset(0, 0), fade: true),
          child: ModifyCollectionsView(courseDbId: (state.extra as Course).id),
        ),
        routes: [
          //MODIFY CONTENTS VIEW NAVIGATION
          GoRoute(
            name: Routes.modifyContents.name,
            path: Routes.modifyContents.subPath,
            pageBuilder: (context, state) => defaultTransition(
              state.pageKey,
              child: ModifyContentsView(collection: state.extra as CourseCollection),
            ),
          ),
        ],
      ),
    ],
  ),
];
