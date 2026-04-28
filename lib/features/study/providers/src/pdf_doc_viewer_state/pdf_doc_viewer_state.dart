import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/base/mixins/use_value_notifier.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/features/study/logic/usecases/content_progress_tracker.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

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
  static const Duration readValidityDuration = Duration(seconds: 13);

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
    progressTrack = await ProgressTracker.getLastTrack(contentId, defaultPages: const ["1"]);
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
    Future.microtask(() => ProgressTracker.updateCourseTrackProgress(contentId));
  }

  // ============================================================================
  // PUBLIC UPDATE METHODS
  // ============================================================================

  void setAppBarVisible(bool visible) {
    isAppBarVisibleNotifier.value = visible;
  }

  void updateScrollOffset(double offset) {
    scrollOffsetNotifier.value = offset;
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _posListener() {
    // log("currentPageNumber: ${controller.pageNumber}");
    final newValue = double.parse(controller.value.row1[3].abs().clamp(0.0, double.infinity).toStringAsFixed(2));

    ref.read(scrollOffsetProvider.notifier).update((cb) => newValue);
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

        if (lastUpdatedPage == pageNumber) return;

        isUpdatingProgressTrack = true;

        if (progressTrack == null) {
          isUpdatingProgressTrack = false;
          _pageStayStopwatch.reset();
          _pageStayStopwatch.start();
          return;
        }

        final newPages =
            (LinkedHashSet<String>.from(progressTrack!.pages)
                  ..remove(prevPageNumber.toString())
                  ..add(prevPageNumber.toString()))
                .toList();
        final totalPageCount = controller.pageCount;

        progressTrack = await ProgressTracker.saveTrack(
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

        final currentProgressTrack =
            progressTrack ?? await ProgressTracker.getLastTrack(contentId, defaultPages: const ["1"]);
        if (currentProgressTrack == null) {
          isUpdatingProgressTrack = false;
          _pageStayStopwatch.start();
          return;
        }
        log("Updating page: $pageNumber");
        final LinkedHashSet<String> pagesToAdd = LinkedHashSet<String>.from(currentProgressTrack.pages)
          ..remove(pageNumber.toString())
          ..add(pageNumber.toString());
        progressTrack = await ProgressTracker.saveTrack(
          currentProgressTrack.copyWith(
            lastRead: DateTime.now(),
            pages: currentProgressTrack.pages.isEmpty ? const ["1"] : pagesToAdd.toList(),
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
