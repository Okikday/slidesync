// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/browse/collection/ui/actions/add_contents_actions.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/handle_archive_uc.dart';
import 'package:slidesync/features/settings/providers/settings_provider.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';

class ContentViewGateActions {
  static Future<void> redirectToViewer(WidgetRef ref, CourseContent content, {bool? openOutsideApp}) async {
    final context = ref.context;

    // Handle explicit external opening
    if (openOutsideApp == true) {
      await _openExternally(context, content);
      return;
    }

    // Determine if should use built-in viewer
    final shouldUseBuiltInViewer = await _shouldUseBuiltInViewer(ref, content, openOutsideApp);

    if (!shouldUseBuiltInViewer && content.courseContentType != CourseContentType.link) {
      await _openExternally(context, content);
      return;
    }

    // Route to appropriate viewer
    if (!context.mounted) return;
    await _routeToViewer(ref, context, content);
  }

  // ==================== Private Helper Methods ====================

  static Future<void> _openExternally(BuildContext context, CourseContent content) async {
    if (content.courseContentType == CourseContentType.link) {
      await launchUrl(Uri.parse(content.path.urlPath));
      UiUtils.showFlushBar(context, msg: "Opening link outside app");
    } else {
      // final toOpen = await FileUtils.storeFile(file: File(content.path.filePath), base: AppDirType.cache, newFileName: content.title);
      await OpenFilex.open(content.path.filePath);
      UiUtils.showFlushBar(context, msg: "Opening with external application...");
    }
  }

  static Future<bool> _shouldUseBuiltInViewer(WidgetRef ref, CourseContent content, bool? openOutsideApp) async {
    if (openOutsideApp != null) return !openOutsideApp;

    final settings = await ref.readSettings;
    final userPreference = settings.useBuiltInViewer;

    // Default behavior based on content type and platform
    final defaultBehavior = content.courseContentType == CourseContentType.image ? true : !DeviceUtils.isDesktop();

    return userPreference ?? defaultBehavior;
  }

  static Future<void> _routeToViewer(WidgetRef ref, BuildContext context, CourseContent content) async {
    switch (content.courseContentType) {
      case CourseContentType.document:
        await _handleDocument(ref, context, content);
        break;

      case CourseContentType.image:
        await _handleImage(context, content);
        break;

      case CourseContentType.link:
        await _handleLink(context, content);
        break;

      default:
        await _handleUnknownType(context, content);
        break;
    }
  }

  // ==================== Content Type Handlers ====================

  static Future<void> _handleDocument(WidgetRef ref, BuildContext context, CourseContent content) async {
    final filePath = content.path.filePath;
    final urlPath = content.path.urlPath;
    final isPdf =
        p.extension(filePath).toLowerCase().contains("pdf") || p.extension(urlPath).toLowerCase().contains("pdf");

    if (isPdf) {
      await _stopPaginationIfNeeded(ref, content);
      _navigateTo(context, Routes.pdfDocumentViewer, content);
      return;
    }

    // Non-PDF documents open externally
    await OpenFilex.open(filePath);
    UiUtils.showFlushBar(context, msg: "Opening with external application...");
  }

  static Future<void> _handleImage(BuildContext context, CourseContent content) async {
    _navigateTo(context, Routes.imageViewer, content);
  }

  static Future<void> _handleLink(BuildContext context, CourseContent content) async {
    final urlPath = content.path.urlPath;
    final isUnresolvedDriveLink =
        content.metadataJson.decodeJson['resolved'] != true && DriveBrowser.isGoogleDriveLink(urlPath);

    if (isUnresolvedDriveLink) {
      _navigateTo(context, Routes.driveLinkViewer, content);
      return;
    }
    final launchResult = (await Result.tryRunAsync(() async => await launchUrl(Uri.parse(urlPath)))).data ?? false;

    if (!launchResult && context.mounted) {
      UiUtils.showFlushBar(context, msg: "Unable to open link. Invalid link or try connecting to the internet");
    }
  }

  static Future<void> _handleUnknownType(BuildContext context, CourseContent content) async {
    final filePath = content.path.filePath;
    final file = File(filePath);

    // Check if it's an archive file
    if (await HandleArchiveUc().isSupportedByArchive(file)) {
      await _handleArchiveFile(file, content);
      return;
    }

    // Fall back to external app
    await OpenFilex.open(filePath);
    UiUtils.showFlushBar(context, msg: "Opening with external application...");
  }

  // ==================== Archive Handling ====================

  static Future<void> _handleArchiveFile(File file, CourseContent content) async {
    await Result.tryRunAsync(() async {
      final context = rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      await UiUtils.showCustomDialog(
        context,
        child: AppAlertDialog(
          title: "Unknown archive file",
          content: "We detected this to be an archive file, Would you want to extract it?",
          onCancel: () => context.pop(),
          onConfirm: () async {
            await _extractAndAddArchive(file, content);
          },
        ),
      );
    });
  }

  static Future<void> _extractAndAddArchive(File file, CourseContent content) async {
    final navState = rootNavigatorKey.currentState;
    if (navState == null) return;

    // Close dialog
    navState.pop();

    // Check file size
    UiUtils.showLoadingDialog(navState.context, message: "Processing archive", canPop: false);

    final fileSize = await file.length();
    const maxSize = 1024 * 1000 * 200; // 200MB

    if (fileSize > maxSize) {
      navState.pop();
      UiUtils.showFlushBar(navState.context, msg: "Archive size is too large, couldn't extract.");
      return;
    }

    // Get parent collection
    final collection = await CourseCollectionRepo.getById(content.parentId);
    if (collection == null) {
      navState.pop();
      UiUtils.showFlushBar(navState.context, msg: "Couldn't get parent collection");
      return;
    }

    navState.pop();

    // Extract archive
    UiUtils.showLoadingDialog(navState.context, message: "Unpacking archive", canPop: false);

    final contentsToAdd = await HandleArchiveUc().extractArchiveToCache(file);
    navState.pop();

    log("${rootNavigatorKey.currentWidget}");
    AddContentsActions.onClickToAddContentNoRef(collection: collection, filePaths: contentsToAdd);
  }

  // ==================== Navigation Helpers ====================

  static void _navigateTo(BuildContext context, Routes route, CourseContent content) {
    context.pushNamed(route.name, extra: content);
  }

  static Future<void> _stopPaginationIfNeeded(WidgetRef ref, CourseContent content) async {
    Result.tryRun(() async {
      final pageProvider = await ref.read(
        CollectionMaterialsProvider.contentPaginationProvider(content.parentId).future,
      );
      if (!pageProvider.isUpdating) return;
      pageProvider.stopIsolate();
    });
  }
}
