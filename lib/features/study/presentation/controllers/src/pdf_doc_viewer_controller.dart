import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

import '../../../../../shared/global/notifiers/toggle_notifier.dart';

import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
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

const Duration readValidityDuration = Duration(seconds: 5);
final _pdfDocViewerStateProvider = AsyncNotifierProvider.autoDispose.family(
  (String contentId) => PdfDocViewerNotifier(contentId),
);

AsyncNotifierProvider<PdfDocViewerNotifier, PdfDocViewerState> pdfDocViewerStateProvider(String contentId) =>
    _pdfDocViewerStateProvider(contentId);

/// Controller
class PdfDocViewerController {
  static AsyncNotifierProvider<ToggleNotifier, bool> get ispdfViewerInDarkMode => _ispdfViewerInDarkModeNotifier;

  static NotifierProvider<DoubleNotifier, double> get scrollOffsetNotifierProvider => _scrollOffsetNotifierProvider;
}

final AsyncNotifierProvider<ToggleNotifier, bool> _ispdfViewerInDarkModeNotifier =
    AsyncNotifierProvider.autoDispose<ToggleNotifier, bool>(
      () => ToggleNotifier(HiveDataPathKey.ispdfViewerInDarkMode.name),
    );

final _scrollOffsetNotifierProvider = NotifierProvider.autoDispose<DoubleNotifier, double>(DoubleNotifier.new);

class PdfDocViewerNotifier extends AsyncNotifier<PdfDocViewerState> {
  static final ScreenshotController screenshotController = ScreenshotController();
  final String contentId;
  Stopwatch? _pageStayStopwatch;

  PdfDocViewerNotifier(this.contentId);

  @override
  Future<PdfDocViewerState> build() async {
    final controller = PdfViewerController();
    _pageStayStopwatch = Stopwatch();

    // Setup listener
    controller.addListener(_posListener);

    // Async initialization
    final progressTrack = await _getLastProgressTrack(contentId);
    final initialPage = progressTrack != null && progressTrack.pages.isNotEmpty
        ? (int.tryParse(progressTrack.pages.last) ?? 1)
        : 1;

    // Add monitor listener if we have progress
    if (progressTrack?.pages.isNotEmpty ?? false) {
      controller.addListener(_monitorPageListener);
    }

    // Cleanup on dispose
    ref.onDispose(() {
      controller.removeListener(_posListener);
      controller.removeListener(_monitorPageListener);
      _pageStayStopwatch?.stop();
      _pageStayStopwatch = null;

      // Update course track progress in background
      final currentState = state.value;
      if (currentState != null) {
        Future.microtask(() => _updateCourseTrackProgress(currentState.progressTrack));
      }
    });

    return PdfDocViewerState(
      contentId: contentId,
      pdfViewerController: controller,
      progressTrack: progressTrack,
      initialPage: initialPage,
    );
  }

  // ============================================================================
  // PUBLIC UPDATE METHODS
  // ============================================================================

  void setAppBarVisible(bool visible) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isAppBarVisible: visible));
    }
  }

  void setToolsMenuVisible(bool visible) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isToolsMenuVisible: visible));
    }
  }

  void updateScrollOffset(double offset) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(scrollOffset: offset));
    }
  }

  // ============================================================================
  // PRIVATE METHODS (converted from your original code)
  // ============================================================================

  void _posListener() {
    final current = state.value;
    if (current == null) return;

    log("currentPageNumber: ${current.pdfViewerController.pageNumber}");
    final newValue = double.parse(
      current.pdfViewerController.value.row1[3].abs().clamp(0.0, double.infinity).toStringAsFixed(2),
    );

    updateScrollOffset(newValue);
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
    return await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(ptm)) ?? ptm;
  }

  Future<void> _updateCourseTrackProgress(ContentTrack? oldPtm) async {
    final current = state.value;
    if (current == null) return;

    final ptm = await _getLastProgressTrack(current.contentId);
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
    final current = state.value;
    if (current == null || current.isUpdatingProgressTrack) return;

    final monitorResult = await Result.tryRunAsync(() async {
      if (!_isPdfCtrllerSettled(current)) return;

      final pageNumber = current.pdfViewerController.pageNumber;
      final prevPageNumber = current.currentPageNumber;

      if (prevPageNumber == null) {
        _pageStayStopwatch?.stop();
        state = AsyncData(current.copyWith(currentPageNumber: pageNumber));
        _pageStayStopwatch?.reset();
        _pageStayStopwatch?.start();
        return;
      }

      if (pageNumber == prevPageNumber) {
        _pageStayStopwatch?.stop();
        if ((_pageStayStopwatch?.elapsed.inSeconds ?? 0) < readValidityDuration.inSeconds) {
          _pageStayStopwatch?.start();
          return;
        }

        if (current.lastUpdatedPage == null) return;

        state = AsyncData(current.copyWith(isUpdatingProgressTrack: true));

        final progressTrack = current.progressTrack;
        if (progressTrack == null) {
          state = AsyncData(current.copyWith(isUpdatingProgressTrack: false));
          _pageStayStopwatch?.reset();
          _pageStayStopwatch?.start();
          return;
        }

        final newPages = LinkedHashSet<String>.from(progressTrack.pages);
        newPages.add(prevPageNumber.toString());

        final totalPageCount = current.pdfViewerController.pageCount;

        await _updateProgressTrack(
          progressTrack.copyWith(
            pages: newPages.toList(),
            progress: newPages.length / totalPageCount,
            lastRead: DateTime.now(),
          ),
        );

        state = AsyncData(current.copyWith(lastUpdatedPage: pageNumber, isUpdatingProgressTrack: false));
        _pageStayStopwatch?.reset();
        _pageStayStopwatch?.start();
      } else {
        if (current.lastUpdatedPage == pageNumber) return;

        _pageStayStopwatch?.stop();
        state = AsyncData(current.copyWith(isUpdatingProgressTrack: true));

        final progressTrack = current.progressTrack ?? await _getLastProgressTrack(current.contentId);
        if (progressTrack == null) {
          state = AsyncData(current.copyWith(isUpdatingProgressTrack: false));
          _pageStayStopwatch?.start();
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

        state = AsyncData(
          current.copyWith(isUpdatingProgressTrack: false, currentPageNumber: pageNumber, lastUpdatedPage: pageNumber),
        );

        _pageStayStopwatch?.reset();
        _pageStayStopwatch?.start();
      }
    });

    monitorResult.onError((e, [st]) {
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(isUpdatingProgressTrack: false, lastUpdatedPage: null));
      }
      _pageStayStopwatch?.reset();
      _pageStayStopwatch?.start();
    });
  }

  bool _isPdfCtrllerSettled(PdfDocViewerState state) {
    if (!state.pdfViewerController.isReady) return false;
    if (state.pdfViewerController.pageNumber == null) return false;
    return true;
  }
}
