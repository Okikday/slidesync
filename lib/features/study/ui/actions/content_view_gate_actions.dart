import 'dart:developer';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/storage_utils/clean_up_utils.dart';
import 'package:slidesync/features/study/logic/usecases/content_progress_tracker.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/add_contents_actions.dart';
import 'package:slidesync/features/browse/logic/src/contents/handle_archive_uc.dart';
import 'package:slidesync/features/settings/providers/settings_provider.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';

class ContentViewGateActions {
  ///
  static Future<void> redirectToViewer(MutationTarget ref, ModuleContent content, {bool? openOutsideApp}) async {
    final refCon = ref.container;

    // Handle explicit external opening
    if (openOutsideApp == true) {
      await _openExternally(content);
      return;
    }

    // Determine if should use built-in viewer
    final shouldUseBuiltInViewer = await _shouldUseBuiltInViewer(ref, content, openOutsideApp);

    if (!shouldUseBuiltInViewer) {
      await _openExternally(content);
      return;
    }

    if (ref is WidgetRef && !ref.context.mounted) return;
    await _routeToViewer(refCon, content);
    ProgressTracker.registerContentAccess(content.uid);
  }

  // ==================== Private Helper Methods ====================

  static Future<void> _openExternally(ModuleContent content) async {
    final isLink = content.type == ModuleContentType.link;
    if (isLink) {
      final url = content.path.url;
      await _tryLaunchLink(url);
      ProgressTracker.registerContentAccess(content.uid);
    } else {
      ProgressTracker.registerContentAccess(content.uid);
      final local = content.path.local;
      if (local == null || local.isEmpty) {
        GlobalNav.withContext(
          (context) => UiUtils.showFlushBar(context, msg: "File path not found, cannot open content"),
        );
        return;
      }
      // Launching outside application
      final extWithDot = p.extension(local);
      final toOpen = await FileUtils.storeFile(
        file: File(local),
        base: AppDirType.temporary,
        newFileName: content.title + extWithDot,
      );

      await OpenFilex.open(toOpen);
    }
    GlobalNav.withContext(
      (context) => UiUtils.showFlushBar(
        context,
        msg: isLink ? "Opening link outside app" : "Opening with external application...",
      ),
    );
  }

  static Future<bool> _shouldUseBuiltInViewer(MutationTarget ref, ModuleContent content, bool? openOutsideApp) async {
    if (openOutsideApp != null) return !openOutsideApp;

    final settings = await ref.container.read(SettingsProvider.settingsProvider.future);
    final userPreference = settings.useBuiltInViewer;

    // Default behavior based on content type and platform
    final defaultBehavior = content.type == ModuleContentType.image ? true : !DeviceUtils.isDesktop();

    return userPreference ?? defaultBehavior;
  }

  static Future<void> _routeToViewer(MutationTarget ref, ModuleContent content) async {
    switch (content.type) {
      case ModuleContentType.document:
        await _handleDocument(ref, content);
        break;

      case ModuleContentType.image:
        await _handleImage(content);
        break;

      case ModuleContentType.link:
        await _handleLink(content);
        break;

      default:
        await _handleUnknownType(content);
        break;
    }
  }

  // ==================== Content Type Handlers ====================

  static Future<void> _handleDocument(MutationTarget ref, ModuleContent content) async {
    final filePath = content.path.local ?? '';
    final urlPath = content.path.url ?? '';
    final isPdf =
        p.extension(filePath).toLowerCase().contains("pdf") || p.extension(urlPath).toLowerCase().contains("pdf");

    if (isPdf) {
      // await _stopPaginationIfNeeded(ref, content);
      _navigateTo(Routes.pdfDocumentViewer, content);
      return;
    }

    // Non-PDF documents open externally
    await OpenFilex.open(filePath);
    GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Opening with external application..."));
  }

  static Future<void> _handleImage(ModuleContent content) async => _navigateTo(Routes.imageViewer, content);

  static Future<void> _handleLink(ModuleContent content) async {
    final urlPath = content.path.url ?? '';
    if (urlPath.isEmpty) return;
    final isUnresolvedDriveLink = Result.from(() => DriveBrowser.isGoogleDriveLink(urlPath), fallback: true);

    if (isUnresolvedDriveLink) {
      _navigateTo(Routes.driveLinkViewer, content);
      return;
    }
    final launchResult = await _tryLaunchLink(urlPath);

    if (!launchResult) {
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(
          context,
          msg: urlPath.contains('.')
              ? "Unable to open link. Invalid link or try connecting to the internet"
              : "Invalid link!. Try adjusting or removing",
        ),
      );
    }
  }

  static Future<bool> _tryLaunchLink(String? url) => Result.fromAsync(() async {
    bool couldLaunch = false;
    if (url != null) {
      final uri = Uri.parse(url);
      couldLaunch = await Result.fromAsync(() => launchUrl(uri, mode: LaunchMode.platformDefault), fallback: false);
      if (!couldLaunch) {
        couldLaunch = await Result.fromAsync(() => launchUrl(uri, mode: LaunchMode.inAppBrowserView), fallback: false);
      }
      if (!couldLaunch) {
        couldLaunch = await Result.fromAsync(
          () => launchUrl(uri, mode: LaunchMode.externalApplication),
          fallback: false,
        );
      }
    }
    return couldLaunch;
  }, fallback: false);

  static Future<void> _handleUnknownType(ModuleContent content) async {
    final filePath = content.path.local ?? '';
    final file = File(filePath);

    GlobalNav.withContext(
      (context) => UiUtils.showLoadingDialog(context, message: "Attempting to recognize content...", canPop: false),
    );

    final isArchive = await HandleArchiveUc().isSupportedByArchive(file);

    GlobalNav.withContext((context) => UiUtils.hideDialog(context));
    // Check if it's an archive file
    if (isArchive) {
      await _handleArchiveFile(file, content);
      return;
    }

    // Fall back to external app
    await OpenFilex.open(filePath);
    GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Opening with external application..."));
  }

  // ==================== Archive Handling ====================

  static Future<void> _handleArchiveFile(File file, ModuleContent content) async {
    await Result.tryRunAsync(() async {
      final context = rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      await UiUtils.showCustomDialog(
        context,
        child: AppAlertDialog(
          title: "Unknown archive file",
          content: "We detected this to be an archive file, Would you like to extract it?",
          onCancel: () => context.pop(),
          onConfirm: () async => await _extractAndAddArchive(file, content),
        ),
      );
    });
  }

  static Future<void> _extractAndAddArchive(File file, ModuleContent content) async {
    final navState = rootNavigatorKey.currentState;
    if (navState == null) return;

    GlobalNav.popGlobal();

    var loadingDialogOpen = false;
    Future<void> closeLoadingDialog() async {
      if (!loadingDialogOpen) return;
      loadingDialogOpen = false;
      try {
        navState.pop();
      } catch (_) {}
    }

    GlobalNav.withContext(
      (context) => UiUtils.showLoadingDialog(context, message: "Processing archive, please wait...", canPop: false),
    );
    loadingDialogOpen = true;

    final fileSize = await file.length();
    const maxSize = 1024 * 1000 * 1024; // 1gb

    if (fileSize > maxSize) {
      await closeLoadingDialog();
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(navState.context, msg: "Archive size is too large, couldn't extract."),
      );
      return;
    }

    try {
      final groupedContents = await HandleArchiveUc().extractArchiveToCache(file);
      if (groupedContents.isEmpty) {
        await closeLoadingDialog();
        GlobalNav.withContext(
          (context) => UiUtils.showFlushBar(navState.context, msg: "No extractable files were found in the archive."),
        );
        return;
      }

      final course = Course.create(title: content.title, description: 'Imported from archive: ${content.title}');
      final courseDbId = await CourseRepo.addCourse(course);
      if (courseDbId == -1) {
        await closeLoadingDialog();
        GlobalNav.withContext(
          (context) => UiUtils.showFlushBar(navState.context, msg: "Unable to create a course for the archive."),
        );
        return;
      }

      final sortedNames = groupedContents.keys.toList()
        ..sort((left, right) {
          if (left == 'Base') return -1;
          if (right == 'Base') return 1;
          return left.toLowerCase().compareTo(right.toLowerCase());
        });

      final modulesToAdd = [
        for (final name in sortedNames)
          Module.create(parentId: course.uid, title: name, description: 'Archive collection: $name'),
      ];

      final addedCollections = await ModuleRepo.addMultipleCollections(course.uid, modulesToAdd);
      await closeLoadingDialog();

      if (addedCollections.isEmpty) {
        GlobalNav.withContext(
          (context) => UiUtils.showFlushBar(navState.context, msg: "Unable to create collections for the archive."),
        );
        return;
      }

      for (final collection in addedCollections) {
        final contentsToAdd = groupedContents[collection.title] ?? const <String>[];
        if (contentsToAdd.isEmpty) continue;

        try {
          await AddContentsActions.onClickToAddContentNoRef(collection: collection, filePaths: contentsToAdd);
        } catch (e) {
          log('Failed to add archive collection ${collection.title}: $e');
        }
      }

      await CleanUpUtils().clearCacheOrTemp();

      GlobalNav.withContext((context) => UiUtils.showFlushBar(navState.context, msg: 'Archive imported successfully.'));
    } catch (e, stackTrace) {
      log('❌ Error extracting archive: $e\n$stackTrace');
      await closeLoadingDialog();
      await CleanUpUtils().clearCacheOrTemp();
      GlobalNav.withContext(
        (context) =>
            UiUtils.showFlushBar(navState.context, msg: 'Error importing archive: $e', vibe: FlushbarVibe.error),
      );
    }
  }

  // ==================== Navigation Helpers ====================

  static void _navigateTo(Routes route, ModuleContent content) {
    GlobalNav.withContext((context) => context.pushNamed(route.name, extra: content));
  }
}
