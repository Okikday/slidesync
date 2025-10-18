import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/study/presentation/views/content_view_gate.dart';
import 'package:slidesync/features/study/presentation/views/viewers/image_viewer.dart';
import 'package:slidesync/features/study/presentation/views/viewers/link_viewer/drive_listing_view.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_viewer.dart';

final contentViewerRoute = GoRoute(
  name: Routes.contentGate.name,
  path: Routes.contentGate.path,
  pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
    state.pageKey,
    type: TransitionType.rightToLeftWithFade,
    duration: Durations.extralong1,
    reverseDuration: Durations.medium1,
    curve: CustomCurves.defaultIosSpring,
    child: ContentViewGate(content: state.extra as CourseContent),
  ),
  routes: [
    GoRoute(
      name: Routes.pdfDocumentViewer.name,
      path: Routes.pdfDocumentViewer.subPath,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
        state.pageKey,
        type: TransitionType.rightToLeftWithFade,
        duration: Durations.extralong1,
        reverseDuration: Durations.medium1,
        curve: CustomCurves.defaultIosSpring,
        child: PdfDocViewer(content: state.extra as CourseContent),
      ),
    ),
    GoRoute(
      name: Routes.imageViewer.name,
      path: Routes.imageViewer.subPath,
      pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
        state.pageKey,
        type: TransitionType.rightToLeftWithFade,
        duration: Durations.extralong1,
        reverseDuration: Durations.medium1,
        curve: CustomCurves.defaultIosSpring,
        child: ImageViewer(content: state.extra as CourseContent),
      ),
    ),

    GoRoute(
      name: Routes.driveLinkViewer.name,
      path: Routes.driveLinkViewer.subPath,
      pageBuilder: (context, state) {
        final content = (state.extra as CourseContent);
        return PageAnimation.buildCustomTransitionPage(
          state.pageKey,
          type: TransitionType.rightToLeftWithFade,
          duration: Durations.extralong1,
          reverseDuration: Durations.medium1,
          curve: CustomCurves.defaultIosSpring,
          child: DriveListingView(initialFolderId: content.path.urlPath, collectionId: content.parentId),
        );
      },
    ),
  ],
);
