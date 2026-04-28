import 'dart:developer';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/features/study/logic/usecases/content_progress_tracker.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
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

    if (!shouldUseBuiltInViewer && content.type != ModuleContentType.link) {
      await _openExternally(content);
      return;
    }

    if (ref is WidgetRef && !ref.context.mounted) return;
    await _routeToViewer(refCon, content);
    ContentProgressTracker().registerContentAccess(content.uid);
  }

  // ==================== Private Helper Methods ====================

  static Future<void> _openExternally(ModuleContent content) async {
    final isLink = content.type == ModuleContentType.link;
    if (isLink) {
      final url = content.path.url;
      if (url != null) await launchUrl(Uri.parse(url));
      ContentProgressTracker().registerContentAccess(content.uid);
    } else {
      ContentProgressTracker().registerContentAccess(content.uid);
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
    final isUnresolvedDriveLink = Result.from(() => DriveBrowser.isGoogleDriveLink(urlPath), fallback: true);

    if (isUnresolvedDriveLink) {
      _navigateTo(Routes.driveLinkViewer, content);
      return;
    }
    final launchResult = await Result.fromAsync(() async => await launchUrl(Uri.parse(urlPath)), fallback: false);

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

  static Future<void> _handleUnknownType(ModuleContent content) async {
    final filePath = content.path.local ?? '';
    final file = File(filePath);

    // Check if it's an archive file
    if (await HandleArchiveUc().isSupportedByArchive(file)) {
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
          content: "We detected this to be an archive file, Would you want to extract it?",
          onCancel: () => context.pop(),
          onConfirm: () async {
            await _extractAndAddArchive(file, content);
          },
        ),
      );
    });
  }

  static Future<void> _extractAndAddArchive(File file, ModuleContent content) async {
    final navState = rootNavigatorKey.currentState;
    if (navState == null) return;

    GlobalNav.popGlobal();

    // Check file size
    GlobalNav.withContext(
      (context) => UiUtils.showLoadingDialog(context, message: "Processing archive, please wait...", canPop: false),
    );

    final fileSize = await file.length();
    const maxSize = 1024 * 1000 * 200; // 200MB

    if (fileSize > maxSize) {
      navState.pop();
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(navState.context, msg: "Archive size is too large, couldn't extract."),
      );
      return;
    }

    // Get parent collection
    final collection = await ModuleRepo.getByUid(content.parentId);
    if (collection == null) {
      navState.pop();
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(navState.context, msg: "Unable to load collection for this content."),
      );

      return;
    }

    navState.pop();

    // Extract archive

    GlobalNav.withContext(
      (context) => UiUtils.showLoadingDialog(navState.context, message: "Unpacking archive", canPop: false),
    );

    final contentsToAdd = await HandleArchiveUc().extractArchiveToCache(file);
    navState.pop();

    log("${rootNavigatorKey.currentWidget}");
    AddContentsActions.onClickToAddContentNoRef(collection: collection, filePaths: contentsToAdd);
  }

  // ==================== Navigation Helpers ====================

  static void _navigateTo(Routes route, ModuleContent content) {
    GlobalNav.withContext((context) => context.pushNamed(route.name, extra: content));
  }
}
