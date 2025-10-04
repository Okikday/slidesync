// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';

import 'package:slidesync/features/study/domain/services/drive_browser.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/add_contents_actions.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/handle_archive_uc.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';

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
          context.pushReplacementNamed(Routes.pdfDocumentViewer.name, extra: content);
          return;
        }
      case CourseContentType.image:
        context.pushReplacementNamed(Routes.imageViewer.name, extra: content);
        return;

      case CourseContentType.link:
        final urlPath = content.path.urlPath;
        if (DriveBrowser.isGoogleDriveLink(urlPath)) {
          context.pushReplacementNamed(Routes.driveLinkViewer.name, extra: urlPath);
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
