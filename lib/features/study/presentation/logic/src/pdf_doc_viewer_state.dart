import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class PdfDocViewerState with ValueNotifierFactoryMixin {
  static final screenshotController = ScreenshotController();
  static final scrollOffsetProvider = NotifierProvider.autoDispose<DoubleNotifier, double>(DoubleNotifier.new);

  ///|
  ///|
  /// ===================================================================================================
  /// VARIABLES
  /// ===================================================================================================
  final String contentId;
  final Ref ref;

  late Future<void> isInitialized;

  late final ValueNotifier<double> scrollOffsetNotifier;
  late final ValueNotifier<bool> isAppBarVisibleNotifier;

  final Stopwatch _pageStayStopwatch = Stopwatch();
  int? initialPage;
  late final PdfViewerController controller;
  ContentTrack? progressTrack;
  bool isUpdatingProgressTrack = false;

  int? currentPageNumber;
  int? lastUpdatedPage;

  // Read validity duration constant
  static const Duration readValidityDuration = Duration(seconds: 3);

  PdfDocViewerState(this.ref, this.contentId) {
    controller = PdfViewerController();
    isAppBarVisibleNotifier = useValueNotifier(true);
    scrollOffsetNotifier = useValueNotifier(0.0);
    isInitialized = _initialize();
  }

  Future<void> _initialize() async {
    // Setup listener
    controller.addListener(_posListener);

    // Async initialization
    progressTrack = await _getLastProgressTrack(contentId);
    {
      if (progressTrack != null) {
        initialPage = progressTrack!.pages.isNotEmpty ? (int.tryParse(progressTrack!.pages.last) ?? 1) : 1;
      }
    }

    // Add monitor listener if we have progress
    if (progressTrack?.pages.isNotEmpty ?? false) {
      controller.addListener(_monitorPageListener);
    }
    // GlobalNav.withContext((c) => Result.tryRun(() => updateScrollOffset(c.topPadding + 56.0 + 12)));
  }

  void dispose() {
    controller.removeListener(_posListener);
    controller.removeListener(_monitorPageListener);
    _pageStayStopwatch.stop();
    disposeNotifiers();
    Future.microtask(() => _updateCourseTrackProgress(progressTrack));
  }

  // ============================================================================
  // PUBLIC UPDATE METHODS
  // ============================================================================

  void setAppBarVisible(bool visible) {
    isAppBarVisibleNotifier.value = visible;
  }

  void updateScrollOffset(double offset) {
    scrollOffsetNotifier.value = offset;
    log("Called to update Scroll Offset notifier");
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _posListener() {
    log("currentPageNumber: ${controller.pageNumber}");
    final newValue = double.parse(controller.value.row1[3].abs().clamp(0.0, double.infinity).toStringAsFixed(2));

    ref.read(scrollOffsetProvider.notifier).update((cb) => newValue);
  }

  Future<ContentTrack?> _getLastProgressTrack(String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return null;

    final ptm = await (await ContentTrackRepo.isar).contentTracks.where().contentIdEqualTo(contentId).findFirst();

    if (ptm == null) {
      return await _createProgressTrackModel(content);
    } else {
      return await _updateProgressTrack(
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
    }
  }

  Future<ContentTrack?> _createProgressTrackModel(CourseContent content) async {
    log("Creating progress track model");
    final result = await Result.tryRunAsync<ContentTrack?>(() async {
      final courseId = (await CourseCollectionRepo.getById(content.parentId))?.parentId;
      if (courseId == null) return null;

      final parentId = (await CourseTrackRepo.getByCourseId(courseId))?.courseId;
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

      return await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(newPtm));
    });
    return result.data;
  }

  Future<ContentTrack> _updateProgressTrack(ContentTrack ptm) async {
    log("Updating progress track model");
    progressTrack = await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(ptm)) ?? ptm;
    return progressTrack!;
  }

  Future<void> _updateCourseTrackProgress(ContentTrack? oldPtm) async {
    final ptm = await _getLastProgressTrack(contentId);
    if (ptm == null) return;

    final courseTrack = await CourseTrackRepo.getByCourseId(ptm.parentId);
    if (courseTrack == null) return;

    await courseTrack.contentTracks.load();
    final contentsLength = courseTrack.contentTracks.length;
    if (contentsLength == 0) return;

    final totalProgress = courseTrack.contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress ?? 0.0));

    final newProgress = totalProgress / contentsLength;
    await CourseTrackRepo.isarData.store(courseTrack.copyWith(progress: newProgress));
  }

  void _monitorPageListener() async {
    if (isUpdatingProgressTrack) return;

    final monitorResult = await Result.tryRunAsync(() async {
      if (!_isPdfCtrllerSettled()) return;

      final pageNumber = controller.pageNumber;
      final prevPageNumber = currentPageNumber;

      if (prevPageNumber == null) {
        _pageStayStopwatch.stop();
        currentPageNumber = pageNumber;
        _pageStayStopwatch.reset();
        _pageStayStopwatch.start();
        return;
      }

      if (pageNumber == prevPageNumber) {
        _pageStayStopwatch.stop();
        if (_pageStayStopwatch.elapsed.inSeconds < readValidityDuration.inSeconds) {
          _pageStayStopwatch.start();
          return;
        }

        if (lastUpdatedPage == null) return;

        isUpdatingProgressTrack = true;

        if (progressTrack == null) {
          isUpdatingProgressTrack = false;
          _pageStayStopwatch.reset();
          _pageStayStopwatch.start();
          return;
        }

        final newPages = <String>{...progressTrack!.pages, prevPageNumber.toString()}.toList();
        final totalPageCount = controller.pageCount;

        await _updateProgressTrack(
          progressTrack!.copyWith(
            pages: newPages,
            progress: newPages.length / totalPageCount,
            lastRead: DateTime.now(),
          ),
        );

        lastUpdatedPage = pageNumber;
        isUpdatingProgressTrack = false;
        _pageStayStopwatch.reset();
        _pageStayStopwatch.start();
      } else {
        if (lastUpdatedPage == pageNumber) return;

        _pageStayStopwatch.stop();
        isUpdatingProgressTrack = true;

        final currentProgressTrack = progressTrack ?? await _getLastProgressTrack(contentId);
        if (currentProgressTrack == null) {
          isUpdatingProgressTrack = false;
          _pageStayStopwatch.start();
          return;
        }

        await _updateProgressTrack(
          currentProgressTrack.copyWith(
            lastRead: DateTime.now(),
            pages: currentProgressTrack.pages.isEmpty
                ? const ["1"]
                : [...currentProgressTrack.pages, if (pageNumber != null) pageNumber.toString()],
          ),
        );

        isUpdatingProgressTrack = false;
        currentPageNumber = pageNumber;
        lastUpdatedPage = pageNumber;

        _pageStayStopwatch.reset();
        _pageStayStopwatch.start();
      }
    });

    monitorResult.onError((e, [st]) {
      isUpdatingProgressTrack = false;
      lastUpdatedPage = null;
      _pageStayStopwatch.reset();
      _pageStayStopwatch.start();
    });
  }

  bool _isPdfCtrllerSettled() {
    if (!controller.isReady) return false;
    if (controller.pageNumber == null) return false;
    return true;
  }
}
