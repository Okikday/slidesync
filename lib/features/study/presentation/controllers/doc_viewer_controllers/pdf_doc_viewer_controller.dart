import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/leak_prevention.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_contents_uc/create_content_preview_image.dart';

const Duration readValidityDuration = Duration(seconds: 5);

class PdfDocViewerController extends LeakPrevention {
  static final ScreenshotController screenshotController = ScreenshotController();
  final CourseContent content;
  final PdfViewerController pdfViewerController;
  final ValueNotifier<ContentTrack?> progressTrackNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isAppBarVisibleNotifier = ValueNotifier(true);
  final ValueNotifier<bool> isToolsMenuVisible = ValueNotifier(true);
  final Stopwatch pageStayStopWatch = Stopwatch();
  bool isUpdatingProgressTrack = false;
  int initialPage = 1;
  int? currentPageNumber;
  int? lastUpdatedPage; // For progress updates

  PdfDocViewerController._(this.content, this.pdfViewerController);

  static PdfDocViewerController of(CourseContent content, {required PdfViewerController pdfViewerController}) =>
      PdfDocViewerController._(content, pdfViewerController);

  static final Future<Isar> _isar = IsarData.isarFuture;
  static final IsarData<ContentTrack> _isarData = IsarData.instance();

  Future<bool> initialize() async {
    final ContentTrack? progressTrack = await getLastProgressTrack(content);
    if (progressTrack == null) return false;
    progressTrackNotifier.value = progressTrack;
    if (progressTrack.pages.isNotEmpty) {
      initialPage = (int.tryParse(progressTrack.pages.last) ?? 1);
      pdfViewerController.addListener(monitorPageListener);
    }
    return true;
  }

  /// Gets the progress of the current document from last session
  static Future<ContentTrack?> getLastProgressTrack(CourseContent content) async {
    final ptm = (await (await _isar).contentTracks.where().contentIdEqualTo(content.contentId).findFirst());
    if (ptm == null) {
      final result = await _createProgressTrackModel(content);
      if (result == null) return null; // A critical error occured!
      return result;
    } else {
      final updatedPtm = await _updateProgressTrack(
        ptm.copyWith(lastRead: DateTime.now(), pages: ptm.pages.isEmpty ? const ["1"] : null),
      );
      return updatedPtm;
    }
  }

  /// Creates a new progress track model if it didn't exist
  static Future<ContentTrack?> _createProgressTrackModel(CourseContent content) async {
    final result = await Result.tryRunAsync<ContentTrack?>(() async {
      final courseId = (await CourseCollectionRepo.getById(content.parentId))?.parentId;
      if (courseId == null) return null;

      final parentId = (await CourseRepo.getCourseById(courseId))?.courseId;
      if (parentId == null) return null;
      final ContentTrack newPtm = ContentTrack.create(
        contentId: content.contentId,
        parentId: parentId,
        title: content.title,
        description: content.description,
        contentHash: content.contentHash,
        progress: 0.0,
        pages: const ["1"],
        lastRead: DateTime.now(),
        metadataJson: jsonEncode({
          'previewPath': CreateContentPreviewImage.genPreviewImagePath(filePath: content.path.filePath),
        }),
      );
      return (await _isarData.getById(await _isarData.store(newPtm)));
    });
    return result.data;
  }

  /// Update progress track
  static Future<ContentTrack> _updateProgressTrack(ContentTrack ptm) async =>
      await _isarData.getById(await _isarData.store(ptm)) ?? ptm;

  void monitorPageListener() async {
    log("Monitoring page");
    if (isUpdatingProgressTrack) return;
    final monitorResult = await Result.tryRunAsync(() async {
      if (!_isPdfCtrllerSettled()) return;

      final pageNumber = pdfViewerController.pageNumber;
      // log("Current pageNumber: $pageNumber");
      // log("\nPrevious pagenumber: $currentPageNumber");
      final prevPageNumber = currentPageNumber;
      if (prevPageNumber == null) {
        pageStayStopWatch.stop();
        currentPageNumber = pageNumber;
        pageStayStopWatch.reset();
        pageStayStopWatch.start();
        // log("This page doesn't count!");
        return;
      } else {
        if (pageNumber == prevPageNumber) {
          // log("Still on same page!");
          pageStayStopWatch.stop();
          if (pageStayStopWatch.elapsed.inSeconds < readValidityDuration.inSeconds) {
            // log("Page under-read: Used ${pageStayStopWatch.elapsed.inSeconds}s on page $pageNumber");
            pageStayStopWatch.start();
            return;
          } else {
            if (lastUpdatedPage == null) return;
            // log("Adding page to progress tracker!");

            isUpdatingProgressTrack = true;
            final progressTrack = progressTrackNotifier.value;
            if (progressTrack == null) {
              isUpdatingProgressTrack = false;
              pageStayStopWatch.reset();
              pageStayStopWatch.start();
              return;
            }

            final newPages = LinkedHashSet<String>.from(progressTrack.pages);
            newPages.add(prevPageNumber.toString());

            // log("Updating read pages: $newPages");
            final totalPageCount = pdfViewerController.pageCount;
            log("new page count: $newPages");

            await _updateProgressTrack(
              progressTrack.copyWith(
                pages: newPages.toList(),
                progress: newPages.length / totalPageCount,
                lastRead: DateTime.now(),
              ),
            );
            lastUpdatedPage = pageNumber;
            isUpdatingProgressTrack = false;
            pageStayStopWatch.reset();
            pageStayStopWatch.start();
            return;
          }
        } else {
          if (lastUpdatedPage == pageNumber) return;
          pageStayStopWatch.stop();

          isUpdatingProgressTrack = true;
          final progressTrack = progressTrackNotifier.value ?? await getLastProgressTrack(content);
          if (progressTrack == null) {
            isUpdatingProgressTrack = false;
            pageStayStopWatch.start();
            return;
          }

          await _updateProgressTrack(
            progressTrack.copyWith(
              lastRead: DateTime.now(),
              pages: progressTrack.pages.isEmpty
                  ? const ["1"]
                  : [...progressTrack.pages, if (pageNumber != null) pageNumber.toString()],
            ),
          );
          isUpdatingProgressTrack = false;
          currentPageNumber = pageNumber;
          lastUpdatedPage = pageNumber;
          // log("Updated page number!");
          pageStayStopWatch.reset();
          pageStayStopWatch.start();

          return;
        }
      }
    });
    monitorResult.onError((e, [st]) {
      isUpdatingProgressTrack = false;
      lastUpdatedPage = null;
      pageStayStopWatch.reset();
      pageStayStopWatch.start();
    });
  }

  bool _isPdfCtrllerSettled() {
    if (!pdfViewerController.isReady) return false;
    if (pdfViewerController.pageNumber == null) return false;
    return true;
  }

  @override
  void onDispose() {
    pdfViewerController.removeListener(monitorPageListener);

    progressTrackNotifier.dispose();
    isAppBarVisibleNotifier.dispose();
    isToolsMenuVisible.dispose();
    pageStayStopWatch
      ..reset()
      ..stop();
    // Future.microtask(() => Result.tryRunAsync(() async => await _addToRecentContents(content.contentId)));
    log("Disposed pdf viewer actions ");
  }
}

// Future<void> _addToRecentContents(String contentId) async {
//   final hiveInstance = AppHiveData.instance;
//   final rawOldRecents = (await hiveInstance.getData(key: HiveDataPathKey.recentContentsIds.name)) as List<String>?;
//   // if (rawOldRecents == null) {
//   //   await hiveInstance.setData(key: HiveDataPathKey.recentContentsIds.name, value: [contentId]);
//   // } else {
//   //   final recents = LinkedHashSet<String>.from(rawOldRecents);
//   //   recents.add(contentId);
//   //   await hiveInstance.setData(key: HiveDataPathKey.recentContentsIds.name, value: recents.toList());
//   // }
//   log("Adding pdf to recents");
//   return;
// }
