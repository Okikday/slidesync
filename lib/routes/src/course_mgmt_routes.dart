import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/manage/presentation/collections/views/modify_collections_view.dart';
import 'package:slidesync/features/manage/presentation/contents/views/modify_contents_view.dart';
import 'package:slidesync/features/manage/presentation/courses/views/create_course_view.dart';
import 'package:slidesync/features/manage/presentation/courses/views/modify_course_view.dart';
import 'package:slidesync/features/manage/presentation/courses/views/select_to_modify_course_view.dart';
import 'package:slidesync/routes/routes.dart';

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
          defaultIncoming: TransitionType.zoom,
          child: ModifyCollectionsView(courseId: (state.extra as String)),
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
