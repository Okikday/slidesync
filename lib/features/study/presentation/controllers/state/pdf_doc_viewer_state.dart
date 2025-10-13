import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';

class PdfDocViewerState {
  final String contentId;
  final PdfViewerController pdfViewerController;
  final double scrollOffset;
  final ContentTrack? progressTrack;
  final bool isAppBarVisible;
  final bool isToolsMenuVisible;
  final int initialPage;
  final int? currentPageNumber;
  final int? lastUpdatedPage;
  final bool isUpdatingProgressTrack;

  const PdfDocViewerState({
    required this.contentId,
    required this.pdfViewerController,
    this.scrollOffset = 0.0,
    this.progressTrack,
    this.isAppBarVisible = true,
    this.isToolsMenuVisible = true,
    this.initialPage = 1,
    this.currentPageNumber,
    this.lastUpdatedPage,
    this.isUpdatingProgressTrack = false,
  });

  PdfDocViewerState copyWith({
    String? contentId,
    PdfViewerController? pdfViewerController,
    double? scrollOffset,
    ContentTrack? progressTrack,
    bool? isAppBarVisible,
    bool? isToolsMenuVisible,
    int? initialPage,
    int? currentPageNumber,
    int? lastUpdatedPage,
    bool? isUpdatingProgressTrack,
  }) {
    return PdfDocViewerState(
      contentId: contentId ?? this.contentId,
      pdfViewerController: pdfViewerController ?? this.pdfViewerController,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      progressTrack: progressTrack ?? this.progressTrack,
      isAppBarVisible: isAppBarVisible ?? this.isAppBarVisible,
      isToolsMenuVisible: isToolsMenuVisible ?? this.isToolsMenuVisible,
      initialPage: initialPage ?? this.initialPage,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      lastUpdatedPage: lastUpdatedPage ?? this.lastUpdatedPage,
      isUpdatingProgressTrack: isUpdatingProgressTrack ?? this.isUpdatingProgressTrack,
    );
  }
}
