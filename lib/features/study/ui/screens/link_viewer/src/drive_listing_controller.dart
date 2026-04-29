import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/native/app_paths.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/store_contents.dart';
import 'package:slidesync/features/browse/logic/entities/add_content_result.dart';
import 'package:slidesync/features/browse/logic/entities/store_content_args.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart' as drive_service;
import 'package:slidesync/features/study/ui/screens/online_viewer.dart';
import 'package:slidesync/features/study/ui/screens/link_viewer/entities/drive_import_models.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:slidesync/features/sync/providers/download_feed_provider.dart';
import 'package:slidesync/features/sync/providers/download_history_provider.dart';
import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/features/sync/providers/selection_provider.dart';
import 'package:slidesync/features/sync/providers/src/transfer_state_notifier.dart';
import 'package:slidesync/features/sync/providers/entities/transfer_state.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class DriveListingController {
  final Ref ref;
  final String collectionId;
  final void Function()? _onOperationStart;
  final void Function()? _onOperationEnd;

  DriveListingController({
    required this.ref,
    required this.collectionId,
    void Function()? onOperationStart,
    void Function()? onOperationEnd,
  }) : _onOperationStart = onOperationStart,
       _onOperationEnd = onOperationEnd;

  void dispose() {
    // Reserved for explicit cleanup if this controller owns resources in the future.
  }

  Future<void> importAll(drive_service.DriveResource resource) async {
    _onOperationStart?.call();
    try {
      final files = (resource.children ?? const <drive_service.DriveFile>[]).where((file) => file.id != null).toList();

      if (files.isEmpty) {
        return;
      }

      final apiKey = dotenv.env['DRIVE_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        _showDriveMessage('Drive API key is missing', FlushbarVibe.error);
        return;
      }

      _showDriveMessage(
        'Downloading ${files.length} item${files.length == 1 ? '' : 's'} from Drive',
        FlushbarVibe.none,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
      );

      final outcome = await _importDriveSelection(resource: resource, selectedFiles: files, apiKey: apiKey);
      _showDriveOperationFeedback(outcome: outcome, successLabel: 'Imported');
    } finally {
      _onOperationEnd?.call();
    }
  }

  Future<void> downloadSelectedItems(
    drive_service.DriveResource resource, {
    Set<String>? selectedIdsSnapshot,
    bool selectionAlreadyCleared = false,
  }) async {
    _onOperationStart?.call();
    try {
      final selection = ref.read(driveSelectionProvider);
      final selectionNotifier = ref.read(driveSelectionProvider.notifier);
      final selectedIds = selectedIdsSnapshot ?? selection.selectedIds;
      final selectedFiles = _selectedFiles(resource, selectedIds);

      if (selectedFiles.isEmpty) {
        _showDriveMessage('Select at least one item first', FlushbarVibe.warning);
        return;
      }

      if (!selectionAlreadyCleared) {
        selectionNotifier.clearSelection();
      }

      final apiKey = dotenv.env['DRIVE_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        _showDriveMessage('Drive API key is missing', FlushbarVibe.error);
        return;
      }

      _showDriveMessage(
        'Downloading ${selectedFiles.length} item${selectedFiles.length == 1 ? '' : 's'} from Drive',
        FlushbarVibe.none,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
      );

      final outcome = await _importDriveSelection(resource: resource, selectedFiles: selectedFiles, apiKey: apiKey);
      _showDriveOperationFeedback(outcome: outcome, successLabel: 'Downloaded');
    } finally {
      _onOperationEnd?.call();
    }
  }

  Future<void> showFileOpenOptions(
    drive_service.DriveFile file, {
    required void Function(String folderId, {String? folderName}) onNavigateToFolder,
  }) async {
    if (file.isFolderLike) {
      final targetFolderId = file.navigationTargetId ?? file.id;
      if (targetFolderId == null) {
        log('DriveListingView: folder-like item ${file.name ?? 'unnamed item'} had no navigation target');
        return;
      }

      onNavigateToFolder(targetFolderId, folderName: file.name ?? targetFolderId);
      return;
    }

    final displayFile = await _resolveFileForOpenOptions(file);
    final inAppKind = _resolveInAppOpenKind(displayFile);

    if (inAppKind == null) {
      await _openInBrowser(file);
      return;
    }

    final actions = <AppActionDialogModel>[
      AppActionDialogModel(
        title: 'Open in browser',
        icon: Icon(HugeIconsSolid.browser, color: Colors.blue),
        onTap: () async {
          GlobalNav.popGlobal();
          await _openInBrowser(file);
        },
      ),
      AppActionDialogModel(
        title: 'Open with app',
        icon: const Icon(Icons.launch_rounded, color: Colors.green),
        onTap: () async {
          GlobalNav.popGlobal();
          await _openInApp(file, preResolvedFile: displayFile, preferredKind: inAppKind);
        },
      ),
    ];

    GlobalNav.withContext((context) {
      UiUtils.showCustomDialog(
        context,
        child: AppActionDialog(title: file.name ?? 'File', actions: actions),
      );
    });
  }

  Future<DriveImportOutcome> _importDriveSelection({
    required drive_service.DriveResource resource,
    required List<drive_service.DriveFile> selectedFiles,
    required String apiKey,
  }) async {
    final course = await _resolveParentCourse();
    if (course == null) {
      return DriveImportOutcome(
        collectionId: collectionId,
        title: 'Drive import',
        type: SyncType.content,
        itemCount: 0,
        totalBytes: 0,
        note: 'Could not resolve the parent course for this collection',
      );
    }

    final collectionTitle = _resolveDriveRootName(resource, selectedFiles);
    final destination = await _resolveOrCreateImportCollection(course.uid, collectionTitle);
    if (destination == null) {
      return DriveImportOutcome(
        collectionId: collectionId,
        title: collectionTitle,
        type: _resolveHistoryType(resource),
        itemCount: 0,
        totalBytes: 0,
        note: 'Could not create or reuse a collection for $collectionTitle',
      );
    }

    final cacheDir = await Directory(
      p.join(
        (await FileUtils.getAppDocumentsDirectory()).path,
        AppPaths.operationsCacheFolder,
        'drive_imports',
        destination.uid,
      ),
    ).create(recursive: true);

    final existingContents = await ModuleContentRepo.getAll();
    final cachedEntries = <DriveCacheEntry>[];
    final encounteredNotes = <String>[];
    final seenSourceKeys = <String>{};

    for (final file in selectedFiles) {
      if (file.id == null || file.name == null) {
        encounteredNotes.add('Skipped unnamed Drive item');
        continue;
      }

      if (file.isFolderLike) {
        final folderOutcome = await _downloadFolderAsFiles(
          folder: file,
          apiKey: apiKey,
          cacheDir: cacheDir,
          existingContents: existingContents,
          seenSourceKeys: seenSourceKeys,
        );

        cachedEntries.addAll(folderOutcome.entries);
        encounteredNotes.addAll(folderOutcome.notes);
        continue;
      }

      final entry = await _downloadAndCacheDriveFileEntry(
        file: file,
        apiKey: apiKey,
        cacheDir: cacheDir,
        existingContents: existingContents,
        seenSourceKeys: seenSourceKeys,
      );

      if (entry.path.isEmpty) {
        if (entry.note != null && entry.note!.isNotEmpty) {
          encounteredNotes.add(entry.note!);
        }
        continue;
      }

      cachedEntries.add(entry);
      seenSourceKeys.add(entry.fingerprint.sourceKey);
    }

    if (cachedEntries.isEmpty) {
      return DriveImportOutcome(
        collectionId: destination.uid,
        title: destination.title,
        type: _resolveHistoryType(resource),
        itemCount: 0,
        totalBytes: 0,
        note: encounteredNotes.isEmpty ? 'Nothing could be cached' : encounteredNotes.join(' • '),
      );
    }

    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      return DriveImportOutcome(
        collectionId: destination.uid,
        title: destination.title,
        type: _resolveHistoryType(resource),
        itemCount: 0,
        totalBytes: 0,
        note: 'Could not start import isolate in the current runtime',
      );
    }

    final addArgs = StoreContentArgs(
      token: rootIsolateToken,
      collectionId: destination.uid,
      filePaths: cachedEntries.map((entry) => entry.path).toList(),
      uuids: cachedEntries.map((entry) => entry.uuid).toList(),
      deleteCache: false,
    ).toMap();

    try {
      final stored = await storeContents(addArgs);
      final addResults = stored.map(AddContentResult.fromMap).toList();
      final successCount = addResults.where((result) => result.isSuccess).length;
      final storedBytes = addResults
          .where((result) => result.isSuccess)
          .fold<int>(0, (sum, result) => sum + (result.fileSize ?? 0));
      final duplicateCount = addResults.where((result) => result.hasDuplicate).length;
      final firstSuccess = addResults.firstWhere(
        (result) => result.isSuccess,
        orElse: () => AddContentResult(isSuccess: false, fileName: ''),
      );

      await _annotateImportedDriveContents(entries: cachedEntries, results: addResults);
      await _recordImportedDownloadHistory(
        destinationCollectionId: destination.uid,
        entries: cachedEntries,
        addResults: addResults,
      );

      final notes = <String>[...encounteredNotes];
      if (duplicateCount > 0) {
        notes.add('$duplicateCount duplicate${duplicateCount == 1 ? '' : 's'} already existed in the library');
      }
      if (successCount == 0 && notes.isEmpty) {
        notes.add('No files were added to the library');
      }

      return DriveImportOutcome(
        collectionId: destination.uid,
        title: destination.title,
        type: _resolveHistoryType(resource),
        itemCount: successCount,
        totalBytes: storedBytes,
        primaryContentId: firstSuccess.contentId,
        note: notes.isEmpty ? null : notes.join(' • '),
      );
    } finally {
      for (final entry in cachedEntries.where((entry) => !entry.reusedExistingPath)) {
        final file = File(entry.path);
        if (!await file.exists()) {
          continue;
        }
        try {
          await file.delete();
        } catch (error, stackTrace) {
          log('DriveListingView: failed to delete cached file ${entry.path}', error: error, stackTrace: stackTrace);
        }
      }
    }
  }

  Future<void> _recordImportedDownloadHistory({
    required String destinationCollectionId,
    required List<DriveCacheEntry> entries,
    required List<AddContentResult> addResults,
  }) async {
    final historyNotifier = ref.read(downloadHistoryProvider.notifier);
    final itemCount = entries.length < addResults.length ? entries.length : addResults.length;

    for (var i = 0; i < itemCount; i++) {
      final result = addResults[i];
      final entry = entries[i];

      if (!result.isSuccess || result.contentId == null || result.contentId!.isEmpty) {
        continue;
      }

      final source = entry.sourceFile;
      final title = source.name ?? result.fileName;

      await historyNotifier.addEntry(
        DownloadHistoryEntry(
          id: result.contentId!,
          title: title,
          type: _resolveHistoryTypeFromFile(source),
          collectionId: destinationCollectionId,
          contentId: result.contentId,
          driveId: source.id,
          sourceName: source.name,
          itemCount: 1,
          totalBytes: result.fileSize ?? entry.bytes,
          createdAt: DateTime.now(),
          note: entry.reusedExistingPath ? 'Opened from existing local copy' : 'Imported from Drive',
        ),
      );
    }
  }

  Future<DriveCacheEntry> _downloadAndCacheDriveFileEntry({
    required drive_service.DriveFile file,
    required String apiKey,
    required Directory cacheDir,
    required List<ModuleContent> existingContents,
    required Set<String> seenSourceKeys,
  }) async {
    final transferNotifier = ref.read(transferStateProvider.notifier);
    final downloadFeedNotifier = ref.read(downloadFeedProvider.notifier);

    if (file.id == null) {
      return DriveCacheEntry(
        path: '',
        uuid: '',
        bytes: 0,
        note: 'Skipped unnamed Drive item',
        sourceFile: file,
        fingerprint: DriveSourceFingerprint.fromFile(file),
      );
    }

    final effectiveFile = await _resolveDriveDownloadSource(file, apiKey);
    if (effectiveFile == null) {
      final fileLabel = file.name ?? 'file';
      return DriveCacheEntry(
        path: '',
        uuid: '',
        bytes: 0,
        note: 'Skipped $fileLabel because its shortcut target could not be resolved',
        sourceFile: file,
        fingerprint: DriveSourceFingerprint.fromFile(file),
      );
    }

    final fingerprint = DriveSourceFingerprint.fromFile(effectiveFile);
    if (seenSourceKeys.contains(fingerprint.sourceKey) ||
        transferNotifier.hasTransferWithSourceKey(fingerprint.sourceKey)) {
      final fileLabel = effectiveFile.name ?? file.name ?? 'file';
      return DriveCacheEntry(
        path: '',
        uuid: '',
        bytes: 0,
        note: 'Skipped $fileLabel because it is already downloading',
        sourceFile: effectiveFile,
        fingerprint: fingerprint,
      );
    }

    final existingContent = await _findExistingDriveContent(effectiveFile, existingContents);
    if (existingContent != null) {
      final existingPath = existingContent.path.local;
      if (existingPath != null && await File(existingPath).exists()) {
        final fileLabel = effectiveFile.name ?? file.name ?? 'file';
        final existingSize = existingContent.fileSizeInBytes > 0
            ? existingContent.fileSizeInBytes
            : await File(existingPath).length();

        return DriveCacheEntry(
          path: existingPath,
          uuid: const Uuid().v4(),
          bytes: existingSize,
          note: 'Reused the local copy for $fileLabel',
          reusedExistingPath: true,
          sourceFile: effectiveFile,
          fingerprint: fingerprint,
        );
      }
    }

    final transferId = 'drive-${effectiveFile.id}-${DateTime.now().microsecondsSinceEpoch}';
    final initialTotalBytes = int.tryParse(effectiveFile.size ?? '') ?? 0;
    final fileLabel = effectiveFile.name ?? file.name ?? 'Drive file';

    downloadFeedNotifier.start(
      id: transferId,
      title: fileLabel,
      type: _resolveHistoryTypeFromFile(effectiveFile),
      totalBytes: initialTotalBytes,
      driveId: effectiveFile.id,
      sourceName: file.name ?? effectiveFile.name,
      logMessage: 'Queued for download',
    );
    downloadFeedNotifier.appendLog(transferId, 'Preparing transfer');

    transferNotifier.upsertTransfer(
      TransferState(
        id: transferId,
        title: 'Downloading $fileLabel',
        type: _resolveTransferType(effectiveFile),
        direction: TransferDirection.download,
        progress: 0.0,
        uploadedBytes: 0,
        totalBytes: initialTotalBytes,
        startedAt: DateTime.now(),
        status: TransferStatus.inProgress,
        sourceKey: fingerprint.sourceKey,
      ),
    );

    try {
      downloadFeedNotifier.appendLog(transferId, 'Starting download');
      final bytes = await _downloadDriveBytes(
        effectiveFile,
        apiKey,
        onProgress: (receivedBytes, totalBytes) {
          final resolvedTotalBytes = totalBytes ?? initialTotalBytes;
          final progress = resolvedTotalBytes > 0 ? receivedBytes / resolvedTotalBytes : 0.0;
          transferNotifier.updateProgress(
            id: transferId,
            progress: progress,
            uploadedBytes: receivedBytes,
            totalBytes: resolvedTotalBytes,
          );
          if (receivedBytes == resolvedTotalBytes || receivedBytes == 0 || receivedBytes % (1024 * 512) == 0) {
            downloadFeedNotifier.updateProgress(
              id: transferId,
              progress: progress,
              uploadedBytes: receivedBytes,
              totalBytes: resolvedTotalBytes,
              logMessage: 'Downloaded ${_formatBytes(receivedBytes)} of ${_formatBytes(resolvedTotalBytes)}',
            );
          } else {
            downloadFeedNotifier.updateProgress(
              id: transferId,
              progress: progress,
              uploadedBytes: receivedBytes,
              totalBytes: resolvedTotalBytes,
            );
          }
          _showDownloadProgressNotification(
            id: transferId,
            title: fileLabel,
            progress: progress,
            receivedBytes: receivedBytes,
            totalBytes: resolvedTotalBytes,
          );
        },
      );

      if (bytes.isEmpty) {
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
        downloadFeedNotifier.fail(transferId, 'Drive returned no data');
        return DriveCacheEntry(
          path: '',
          uuid: '',
          bytes: 0,
          note: 'Skipped ${file.name ?? 'file'} because Drive returned no data',
          sourceFile: effectiveFile,
          fingerprint: fingerprint,
        );
      }

      if (bytes.length > 100 * 1024 * 1024) {
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
        downloadFeedNotifier.fail(transferId, 'Skipped because it exceeds the 100 MB limit');
        return DriveCacheEntry(
          path: '',
          uuid: '',
          bytes: 0,
          note: 'Skipped ${file.name ?? 'file'} because it exceeds the 100 MB limit',
          sourceFile: effectiveFile,
          fingerprint: fingerprint,
        );
      }

      final cachePath = p.join(cacheDir.path, _downloadFileName(effectiveFile));
      await File(cachePath).writeAsBytes(bytes, flush: true);
      downloadFeedNotifier.appendLog(transferId, 'Cached file at ${p.basename(cachePath)}');

      transferNotifier.updateProgress(
        id: transferId,
        progress: 1.0,
        uploadedBytes: bytes.length,
        totalBytes: bytes.length,
      );
      transferNotifier.updateStatus(id: transferId, status: TransferStatus.completed);
      downloadFeedNotifier.complete(transferId, note: 'Downloaded successfully');
      _showCompletionNotification(title: fileLabel, body: 'Download completed');

      return DriveCacheEntry(
        path: cachePath,
        uuid: const Uuid().v4(),
        bytes: bytes.length,
        sourceFile: effectiveFile,
        fingerprint: fingerprint,
      );
    } on HttpException catch (error) {
      transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
      downloadFeedNotifier.fail(transferId, error.message);
      _showCompletionNotification(title: fileLabel, body: 'Download failed: ${error.message}');
      final note = _isUnsupportedDriveExportError(error.message)
          ? 'Skipped ${file.name ?? 'file'} because Drive does not support exporting this file type'
          : 'Skipped ${file.name ?? 'file'} because Drive export failed: ${error.message}';

      return DriveCacheEntry(
        path: '',
        uuid: '',
        bytes: 0,
        note: note,
        sourceFile: effectiveFile,
        fingerprint: fingerprint,
      );
    } catch (error, stackTrace) {
      transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
      downloadFeedNotifier.fail(transferId, 'Skipped because it could not be downloaded');
      _showCompletionNotification(title: fileLabel, body: 'Download failed');
      log('DriveListingView: unexpected download failure', error: error, stackTrace: stackTrace);

      return DriveCacheEntry(
        path: '',
        uuid: '',
        bytes: 0,
        note: 'Skipped ${file.name ?? 'file'} because it could not be downloaded',
        sourceFile: effectiveFile,
        fingerprint: fingerprint,
      );
    } finally {
      _cancelDownloadNotification(transferId);
      transferNotifier.removeTransfer(transferId);
    }
  }

  void _showDownloadProgressNotification({
    required String id,
    required String title,
    required double progress,
    required int receivedBytes,
    required int totalBytes,
  }) {
    try {
      final hasTotal = totalBytes > 0;
      final progressValue = hasTotal ? receivedBytes.clamp(0, totalBytes) : (progress * 100).round().clamp(0, 100);
      final maxProgress = hasTotal ? totalBytes : 100;
      NotificationService.instance.showDownloadProgress(
        idType: NotificationServiceIdType.download,
        title: title,
        progress: progressValue,
        maxProgress: maxProgress,
      );
    } catch (_) {}
  }

  void _showCompletionNotification({required String title, required String body}) {
    try {
      NotificationService.instance.showCompletion(title: title, body: body);
    } catch (_) {}
  }

  void _cancelDownloadNotification(String id) {
    try {
      NotificationService.instance.cancel(NotificationServiceIdType.download);
    } catch (_) {}
  }

  SyncType _resolveHistoryTypeFromFile(drive_service.DriveFile file) {
    if (file.isFolderLike) return SyncType.collection;
    final mime = (file.mimeType ?? '').toLowerCase();
    if (file.isGoogleNative || mime.contains('document') || mime.contains('presentation') || mime.contains('sheet')) {
      return SyncType.course;
    }
    return SyncType.content;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<({List<DriveCacheEntry> entries, List<String> notes})> _downloadFolderAsFiles({
    required drive_service.DriveFile folder,
    required String apiKey,
    required Directory cacheDir,
    required List<ModuleContent> existingContents,
    required Set<String> seenSourceKeys,
  }) async {
    final folderId = folder.navigationTargetId ?? folder.id;
    if (folderId == null) {
      return (entries: <DriveCacheEntry>[], notes: <String>['Folder missing id']);
    }

    final children = await drive_service.DriveBrowser.listFolderContents(folderId, apiKey: apiKey);
    final entries = <DriveCacheEntry>[];
    final notes = <String>[];

    for (final child in children) {
      if (child.isFolderLike || child.id == null) {
        continue;
      }

      final entry = await _downloadAndCacheDriveFileEntry(
        file: child,
        apiKey: apiKey,
        cacheDir: cacheDir,
        existingContents: existingContents,
        seenSourceKeys: seenSourceKeys,
      );

      if (entry.path.isEmpty) {
        if (entry.note != null && entry.note!.isNotEmpty) {
          notes.add(entry.note!);
        }
        continue;
      }

      entries.add(entry);
      seenSourceKeys.add(entry.fingerprint.sourceKey);
    }

    return (entries: entries, notes: notes);
  }

  Future<ModuleContent?> _findExistingDriveContent(
    drive_service.DriveFile file,
    List<ModuleContent> existingContents,
  ) async {
    final fingerprint = DriveSourceFingerprint.fromFile(file);
    for (final content in existingContents) {
      if (fingerprint.matchesContent(content)) {
        return content;
      }
    }

    return null;
  }

  Future<void> _annotateImportedDriveContents({
    required List<DriveCacheEntry> entries,
    required List<AddContentResult> results,
  }) async {
    final limit = entries.length < results.length ? entries.length : results.length;

    for (var index = 0; index < limit; index++) {
      final result = results[index];
      if (!result.isSuccess || result.contentId == null || result.contentId!.isEmpty) {
        continue;
      }

      final content = await ModuleContentRepo.getByUid(result.contentId!);
      if (content == null) {
        continue;
      }
      final fields = content.metadata?.fields;
      final mergedFields = <String, dynamic>{
        if (fields != null) ...fields,
        ...entries[index].fingerprint.toMetadataFields(),
        'downloadedFromDrive': true,
        'reusedExistingPath': entries[index].reusedExistingPath,
      }..removeWhere((key, value) => value == null || value == '');

      final metadata = content.metadata?.copyWith(
        originalFileName: content.metadata?.originalFileName ?? entries[index].fingerprint.sourceName,
        contentOrigin: ContentOrigin.local,
        rawFieldsJson: mergedFields.isEmpty ? null : jsonEncode(mergedFields),
      );

      if (metadata?.rawFieldsJson == content.metadataJson) {
        continue;
      }

      await ModuleContentRepo.add(content.copyWith(xxh3Hash: content.xxh3Hash, metadata: metadata));
    }
  }

  void _showDriveOperationFeedback({required DriveImportOutcome outcome, required String successLabel}) {
    if (outcome.note != null && outcome.note!.isNotEmpty) {
      final countLabel = outcome.itemCount == 1 ? '1 item' : '${outcome.itemCount} items';
      final message = outcome.itemCount > 0
          ? '$successLabel $countLabel with warnings. ${outcome.note!}'
          : outcome.note!;
      _showCompletionNotification(
        title: outcome.itemCount > 0 ? 'Download completed with warnings' : 'Download failed',
        body: '${outcome.title}: $message',
      );
      _showDriveMessage(message, outcome.itemCount > 0 ? FlushbarVibe.warning : FlushbarVibe.error);
      return;
    }

    final countLabel = outcome.itemCount == 1 ? '1 item' : '${outcome.itemCount} items';
    _showCompletionNotification(title: 'Download completed', body: '${outcome.title}: $successLabel $countLabel');
    _showDriveMessage('$successLabel $countLabel', FlushbarVibe.success);
  }

  Future<Course?> _resolveParentCourse() async {
    final collection = await ModuleRepo.getByUid(collectionId);
    if (collection == null) {
      return null;
    }

    return await CourseRepo.getCourseByUid(collection.parentId);
  }

  Future<Module?> _resolveOrCreateImportCollection(String courseId, String title) async {
    final existing = await ModuleRepo.getByTitleAndParentId(title: title, parentId: courseId);
    if (existing != null) {
      return existing;
    }

    final collection = Module.create(parentId: courseId, title: title, description: 'Imported from Drive');

    final result = await ModuleRepo.addCollectionNoDuplicateTitle(collection);
    if (result != null) {
      return await ModuleRepo.getByTitleAndParentId(title: title, parentId: courseId);
    }

    return await ModuleRepo.getByTitleAndParentId(title: title, parentId: courseId);
  }

  SyncType _resolveHistoryType(drive_service.DriveResource resource) {
    if (resource.isFolder) {
      return SyncType.collection;
    }

    final file = resource.file;
    if (file != null) {
      if (file.isFolderLike) {
        return SyncType.collection;
      }
      if (file.isGoogleNative || (file.mimeType ?? '').toLowerCase().contains('document')) {
        return SyncType.course;
      }
    }

    return SyncType.content;
  }

  String _resolveDriveRootName(drive_service.DriveResource resource, List<drive_service.DriveFile> selectedFiles) {
    if (resource.file?.name != null && resource.file!.name!.isNotEmpty) {
      return resource.file!.name!;
    }

    if (selectedFiles.length == 1 && selectedFiles.first.name != null) {
      return selectedFiles.first.name!;
    }

    return 'Drive import';
  }

  Future<void> _openInBrowser(drive_service.DriveFile file) async {
    final url = Uri.parse(file.webViewLink ?? _driveLinkForFile(file));
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened) {
      _showDriveMessage('Could not open file in browser', FlushbarVibe.error);
    }
  }

  Future<void> _openInApp(
    drive_service.DriveFile file, {
    drive_service.DriveFile? preResolvedFile,
    _DriveInAppOpenKind? preferredKind,
  }) async {
    final apiKey = dotenv.env['DRIVE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _showDriveMessage('Drive API key is missing', FlushbarVibe.error);
      return;
    }

    if (file.id == null) {
      _showDriveMessage('Unable to open this file', FlushbarVibe.error);
      return;
    }

    try {
      final resolvedFile = preResolvedFile ?? await _resolveDriveDownloadSource(file, apiKey);
      if (resolvedFile == null) {
        _showDriveMessage('Could not resolve the shortcut target', FlushbarVibe.error);
        return;
      }

      final openKind = preferredKind ?? _resolveInAppOpenKind(resolvedFile);
      if (openKind == null) {
        await _openInBrowser(file);
        return;
      }

      final onlineUrl = _resolveOnlineViewerUrl(resolvedFile);
      if (onlineUrl == null) {
        _showDriveMessage('Could not resolve a preview URL for this file', FlushbarVibe.error);
        return;
      }

      GlobalNav.withContext((context) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnlineViewer(
              args: OnlineViewerArgs(
                title: resolvedFile.name ?? p.basenameWithoutExtension(onlineUrl),
                fallbackUrl: onlineUrl,
                kind: openKind == _DriveInAppOpenKind.pdf ? OnlineViewerKind.pdf : OnlineViewerKind.image,
              ),
            ),
          ),
        );
      });
    } catch (error, stackTrace) {
      log('DriveListingView: open in app failed', error: error, stackTrace: stackTrace);
      _showDriveMessage('Could not open file: $error', FlushbarVibe.error);
    }
  }

  List<drive_service.DriveFile> _selectedFiles(drive_service.DriveResource resource, Set<String> selectedIds) {
    if (resource.isFolder) {
      return resource.children?.where((file) => file.id != null && selectedIds.contains(file.id)).toList() ?? [];
    }

    final file = resource.file;
    if (file != null && file.id != null && selectedIds.contains(file.id)) {
      return [file];
    }

    return const [];
  }

  Future<drive_service.DriveFile?> _resolveDriveDownloadSource(drive_service.DriveFile file, String apiKey) async {
    if (!file.isShortcut) {
      return file;
    }

    if (file.shortcutTargetId == null) {
      return null;
    }

    try {
      return await drive_service.DriveBrowser.getFileMetadata(file.shortcutTargetId!, apiKey: apiKey);
    } catch (error, stackTrace) {
      log('DriveListingView: failed to resolve shortcut target', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<List<int>> _downloadDriveBytes(
    drive_service.DriveFile file,
    String apiKey, {
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    if (file.id == null) {
      throw StateError('File ID is missing');
    }

    if (file.isGoogleNative) {
      final response = await drive_service.DriveBrowser.exportGoogleFile(
        fileId: file.id!,
        mimeType: 'application/pdf',
        apiKey: apiKey,
        onProgress: onProgress,
      );
      return response.bodyBytes;
    }

    final response = await drive_service.DriveBrowser.downloadDriveFile(
      fileId: file.id!,
      apiKey: apiKey,
      onProgress: onProgress,
    );
    return response.bodyBytes;
  }

  TransferType _resolveTransferType(drive_service.DriveFile file) {
    final mimeType = (file.mimeType ?? '').toLowerCase();

    if (file.isFolderLike) {
      return TransferType.collection;
    }
    if (file.isGoogleNative ||
        mimeType.contains('document') ||
        mimeType.contains('presentation') ||
        mimeType.contains('sheet')) {
      return TransferType.course;
    }

    return TransferType.content;
  }

  Future<drive_service.DriveFile> _resolveFileForOpenOptions(drive_service.DriveFile file) async {
    if (!file.isShortcut) return file;

    final apiKey = dotenv.env['DRIVE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return file;
    }

    try {
      return await _resolveDriveDownloadSource(file, apiKey) ?? file;
    } catch (_) {
      return file;
    }
  }

  _DriveInAppOpenKind? _resolveInAppOpenKind(drive_service.DriveFile file) {
    final mimeType = (file.mimeType ?? '').toLowerCase();
    final extension = (file.fileExtension ?? p.extension(file.name ?? '')).replaceFirst('.', '').toLowerCase();

    if (mimeType.startsWith('image/') ||
        const {'png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp', 'heic'}.contains(extension)) {
      return _DriveInAppOpenKind.image;
    }

    if (mimeType.contains('pdf') || extension == 'pdf') {
      return _DriveInAppOpenKind.pdf;
    }

    return null;
  }

  String _downloadFileName(drive_service.DriveFile file) {
    final resolved = file.name?.trim().isNotEmpty == true
        ? file.name!.trim()
        : 'drive_file_${file.id ?? DateTime.now().millisecondsSinceEpoch}';

    if (file.isGoogleNative) {
      if (resolved.toLowerCase().endsWith('.pdf')) {
        return _sanitizeFileName(resolved);
      }
      return _sanitizeFileName('$resolved.pdf');
    }

    final extension = file.fileExtension;
    if (extension != null && extension.isNotEmpty && !resolved.toLowerCase().endsWith('.$extension')) {
      return _sanitizeFileName('$resolved.$extension');
    }

    return _sanitizeFileName(resolved);
  }

  String? _resolveOnlineViewerUrl(drive_service.DriveFile file) {
    if (file.webContentLink != null && file.webContentLink!.trim().isNotEmpty) {
      return file.webContentLink!.trim();
    }

    if (file.webViewLink != null && file.webViewLink!.trim().isNotEmpty) {
      return file.webViewLink!.trim();
    }

    if (file.id == null) {
      return null;
    }

    if (file.isGoogleNative) {
      return 'https://drive.google.com/uc?export=download&id=${file.id}';
    }

    return 'https://drive.google.com/uc?export=view&id=${file.id}';
  }

  String _sanitizeFileName(String name) => name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

  String _driveLinkForFile(drive_service.DriveFile file) {
    if (file.isFolderLike) {
      final folderId = file.navigationTargetId ?? file.id;
      if (folderId != null) {
        return 'https://drive.google.com/drive/folders/$folderId';
      }
    }
    return file.webViewLink ?? 'https://drive.google.com/file/d/${file.id}/view';
  }

  bool _isUnsupportedDriveExportError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('requested conversion is not supported') || normalized.contains('badrequest');
  }

  void _showDriveMessage(
    String message,
    FlushbarVibe vibe, {
    Duration duration = const Duration(seconds: 2),
    FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
  }) {
    GlobalNav.withContext((context) {
      UiUtils.showFlushBar(context, msg: message, vibe: vibe, duration: duration, flushbarPosition: flushbarPosition);
    });
  }
}

enum _DriveInAppOpenKind { pdf, image }

final driveListingControllerProvider = Provider.autoDispose.family<DriveListingController, String>((ref, collectionId) {
  KeepAliveLink? keepAliveLink;
  var activeOperations = 0;

  void startOperation() {
    activeOperations += 1;
    keepAliveLink ??= ref.keepAlive();
  }

  void endOperation() {
    activeOperations = (activeOperations - 1).clamp(0, 1 << 20);
    if (activeOperations == 0) {
      keepAliveLink?.close();
      keepAliveLink = null;
    }
  }

  final controller = DriveListingController(
    ref: ref,
    collectionId: collectionId,
    onOperationStart: startOperation,
    onOperationEnd: endOperation,
  );
  ref.onDispose(controller.dispose);
  return controller;
});
