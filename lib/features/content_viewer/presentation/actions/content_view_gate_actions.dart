import 'dart:developer';
import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/routes/app_route_navigator.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/sub/course_content.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/content_viewer/domain/services/drive_browser.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/actions/add_contents_actions.dart';
import 'package:slidesync/features/manage_all/manage_contents/usecases/add_contents_uc.dart';
import 'package:slidesync/features/manage_all/manage_contents/usecases/create_contents_uc/handle_archive_uc.dart';
import 'package:slidesync/features/manage_all/manage_contents/usecases/create_contents_uc/store_contents_uc.dart';
import 'package:slidesync/shared/components/dialogs/app_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentViewGateActions {
  static Future<void> redirectToViewer(BuildContext context, CourseContent content) async {
    await Future.delayed(Durations.medium2);
    if (!context.mounted) return;
    final filePath = content.path.filePath;
    final urlPath = content.path.urlPath;
    final filenameExt = p.extension(filePath);
    switch (content.courseContentType) {
      case CourseContentType.document:
        if (filenameExt.toLowerCase().contains("pdf") || p.extension(urlPath).toLowerCase().contains("pdf")) {
          AppRouteNavigator.to(context, isPushedAsReplacement: true).pdfDocumentViewerRoute(content);
          return;
        }
      case CourseContentType.image:
        AppRouteNavigator.to(context, isPushedAsReplacement: true).imageViewerRoute(content);
        return;

      case CourseContentType.link:
        final urlPath = content.path.urlPath;
        if (DriveBrowser.isGoogleDriveLink(urlPath)) {
          AppRouteNavigator.to(context, isPushedAsReplacement: true).driveLinkViewerRoute(urlPath);
          return;
        }
        context.pop();
        final bool launchResult =
            (await Result.tryRunAsync(() async => await launchUrl(Uri.parse(urlPath)))).data ?? false;

        if (!launchResult) {
          if (context.mounted) {
            UiUtils.showFlushBar(context, msg: "Unable to open link. Invalid link or try connecting to the internet");
          }
        }
        return;

      default:
        if (context.mounted) context.pop();

        if (await HandleArchiveUc().isSupportedByArchive(File(filePath))) {
          await Result.tryRunAsync(() async {
            if (rootNavigatorKey.currentContext!.mounted) {
              UiUtils.showCustomDialog(
                rootNavigatorKey.currentContext!,
                child: AppAlertDialog(
                  title: "Unknown archive file",
                  content: "We detected this to be an archive file, Would you want to extract it?",
                  onCancel: () {
                    rootNavigatorKey.currentContext!.pop();
                  },
                  onConfirm: () async {
                    rootNavigatorKey.currentState!.pop();
                    UiUtils.showLoadingDialog(
                      rootNavigatorKey.currentState!.context,
                      message: "Processing archive",
                      canPop: false,
                    );
                    final file = File(filePath);
                    if (await file.length() > 1024 * 1000 * 200) {
                      rootNavigatorKey.currentState!.pop();
                      UiUtils.showFlushBar(
                        rootNavigatorKey.currentState!.context,
                        msg: "Archive size is too large, couldn't extract.",
                      );
                      return;
                    }
                    final collection = await CourseCollectionRepo.getById(content.parentId);
                    if (collection == null) {
                      rootNavigatorKey.currentState!.pop();
                      UiUtils.showFlushBar(
                        rootNavigatorKey.currentState!.context,
                        msg: "Couldn't get parent collection",
                      );
                      return;
                    }
                    rootNavigatorKey.currentState!.pop();

                    UiUtils.showLoadingDialog(
                      rootNavigatorKey.currentState!.context,
                      message: "Unpacking archive",
                      canPop: false,
                    );

                    final contentsToAdd = await HandleArchiveUc().extractArchiveToCache(File(filePath));
                    rootNavigatorKey.currentState!.pop();
                    log("${rootNavigatorKey.currentWidget}");
                    AddContentsActions.onClickToAddContentNoRef(collection: collection, filePaths: contentsToAdd);
                  },
                ),
              );
            }
          });
        }
        // if (context.mounted) UiUtils.showFlushBar(context, msg: "This content is not supported right now!");

        return;
    }
  }
}
