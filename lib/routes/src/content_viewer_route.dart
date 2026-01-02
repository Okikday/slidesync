import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/features/study/ui/screens/image_viewer.dart';
import 'package:slidesync/features/study/ui/screens/link_viewer/drive_listing_view.dart';
import 'package:slidesync/features/study/ui/screens/pdf_doc_viewer.dart';
import 'package:slidesync/routes/transition.dart';

final contentViewerRoutes = [
  GoRoute(
    name: Routes.pdfDocumentViewer.name,
    path: Routes.pdfDocumentViewer.path,
    pageBuilder: (context, state) =>
        defaultTransition(state.pageKey, child: PdfDocViewer(content: state.extra as CourseContent)),
  ),
  GoRoute(
    name: Routes.imageViewer.name,
    path: Routes.imageViewer.path,
    pageBuilder: (context, state) =>
        defaultTransition(state.pageKey, child: ImageViewer(content: state.extra as CourseContent)),
  ),

  GoRoute(
    name: Routes.driveLinkViewer.name,
    path: Routes.driveLinkViewer.path,
    pageBuilder: (context, state) {
      final content = (state.extra as CourseContent);
      return defaultTransition(
        state.pageKey,
        child: DriveListingView(initialFolderId: content.path.urlPath, collectionId: content.parentId),
      );
    },
  ),
];
