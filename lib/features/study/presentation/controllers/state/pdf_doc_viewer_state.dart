import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

const Duration readValidityDuration = Duration(seconds: 5);

class PdfDocViewerState extends LeakPrevention {
  static final ScreenshotController screenshotController = ScreenshotController();

  final String contentId;
  Ref? ref;

  late final PdfViewerController pdfViewerController;
  late final ValueNotifier<double> scrollOffsetNotifier;
  late final ValueNotifier<ContentTrack?> progressTrackNotifier;
  late final ValueNotifier<bool> isAppBarVisibleNotifier;
  late final ValueNotifier<bool> isToolsMenuVisible;
  final Stopwatch pageStayStopWatch = Stopwatch();
  bool isUpdatingProgressTrack = false;
  int initialPage = 1;
  int? currentPageNumber;
  int? lastUpdatedPage; // For progress updates

  PdfDocViewerState(this.contentId, [this.ref]) {
    pdfViewerController = PdfViewerController();
    scrollOffsetNotifier = ValueNotifier(0.0);
    progressTrackNotifier = ValueNotifier(null);
    isAppBarVisibleNotifier = ValueNotifier(true);
    isToolsMenuVisible = ValueNotifier(true);
    pdfViewerController.addListener(posListener);
  }

  void posListener() {
    if (ref == null) return;
    log("currentPageNumber: ${pdfViewerController.pageNumber}");
    final newValue = double.parse(
      pdfViewerController.value.row1[3].abs().clamp(0.0, double.infinity).toStringAsFixed(2),
    );
    ref!.read(PdfDocViewerController.scrollOffsetNotifierProvider.notifier).update((cb) => newValue);
  }

  Future<bool> initialize() async {
    final ContentTrack? progressTrack = await getLastProgressTrack();
    if (progressTrack == null) return false;
    progressTrackNotifier.value = progressTrack;
    if (progressTrack.pages.isNotEmpty) {
      initialPage = (int.tryParse(progressTrack.pages.last) ?? 1);
      pdfViewerController.addListener(monitorPageListener);
    }
    return true;
  }

  /// Gets the progress of the current document from last session
  Future<ContentTrack?> getLastProgressTrack() async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return null;
    final ptm = (await (await ContentTrackRepo.isar).contentTracks.where().contentIdEqualTo(contentId).findFirst());
    if (ptm == null) {
      final result = await _createProgressTrackModel(content);
      if (result == null) return null; // A critical error occured!
      return result;
    } else {
      final updatedPtm = await _updateProgressTrack(
        ptm.copyWith(
          lastRead: DateTime.now(),
          pages: ptm.pages.isEmpty ? const ["1"] : null,
          metadataJson: jsonEncode(<String, dynamic>{
            'previewPath':
                jsonDecode(content.metadataJson)['previewPath'] ??
                CreateContentPreviewImage.genPreviewImagePath(filePath: content.path.filePath),
          }),
        ),
      );
      return updatedPtm;
    }
  }

  /// Creates a new progress track model if it didn't exist
  Future<ContentTrack?> _createProgressTrackModel(CourseContent content) async {
    log("Creating progress track model");
    final result = await Result.tryRunAsync<ContentTrack?>(() async {
      final courseId = (await CourseCollectionRepo.getById(content.parentId))?.parentId;
      if (courseId == null) return null;
      log("Gotten collection from repo");

      final parentId = (await CourseTrackRepo.getByCourseId(courseId))?.courseId;
      if (parentId == null) return null;
      log("Gotten course track");

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
      log("Creating Content track model");
      return (await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(newPtm)));
    });
    return result.data;
  }

  /// Update progress track
  Future<ContentTrack> _updateProgressTrack(ContentTrack ptm) async {
    log("Updating progress track model");
    return await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(ptm)) ?? ptm;
  }

  Future<void> _updateCourseTrackProgress(ContentTrack? oldPtm) async {
    final ContentTrack? ptm = await getLastProgressTrack();
    if (ptm == null) return;

    final courseTrack = await CourseTrackRepo.getByCourseId(ptm.parentId);
    if (courseTrack == null) return;

    await courseTrack.contentTracks.load();
    final contentsLength = courseTrack.contentTracks.length;
    if (contentsLength == 0) return;

    // Recalculate from all content tracks
    final totalProgress = courseTrack.contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress ?? 0.0));

    final newProgress = totalProgress / contentsLength;
    await CourseTrackRepo.isarData.store(courseTrack.copyWith(progress: newProgress));
  }

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
          final progressTrack = progressTrackNotifier.value ?? await getLastProgressTrack();
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
    pdfViewerController.removeListener(posListener);
    pdfViewerController.removeListener(monitorPageListener);
    final oldPtm = progressTrackNotifier.value;
    scrollOffsetNotifier.dispose();
    progressTrackNotifier.dispose();
    isAppBarVisibleNotifier.dispose();
    isToolsMenuVisible.dispose();
    pageStayStopWatch
      ..reset()
      ..stop();
    Future.microtask(
      () async => await Result.tryRunAsync(() async {
        await _updateCourseTrackProgress(oldPtm);
      }),
    );
    log("Disposed pdf viewer actions ");
  }
}
