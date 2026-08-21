import 'dart:developer';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_overlay_widgets/pdf_scrollbar_overlay.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  const PdfViewerWidget({super.key, required this.content});

  final ModuleContent content;

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  Offset? _tapDownPosition;
  bool _pointerHasMoved = false;
  DateTime? _tapDownTime;
  DateTime? _lastTapTime;

  void _handleSingleTap(WidgetRef ref, Offset position) {
    final controller = PdfDocViewerProvider.state(
      widget.content.uid,
    ).select((s) => s.controller).read(ref);
    // Clear any text selection on tap
    controller.clearSelection();
    _handleTap(ref);
  }

  void _handleDoubleTap(WidgetRef ref) {
    final docViewP = PdfDocViewerProvider.state(widget.content.uid);
    final controller = ref.read(docViewP.select((s) => s.controller));

    // Toggle zoom between 1x and 2x on double tap
    if (controller.zoomLevel > 1.0) {
      controller.zoomLevel = 1.0;
    } else {
      controller.zoomLevel = 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Rebuild pdfviewer widget!!!");

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.white,
        ref.watch(PdfDocViewerProvider.ispdfViewerInDarkMode).value ?? false
            ? BlendMode.difference
            : BlendMode.dst,
      ),
      child: Screenshot(
        controller: PdfDocViewerState.screenshotController,
        child: Consumer(
          builder: (context, ref, child) {
            final docViewP = PdfDocViewerProvider.state(widget.content.uid);
            final pdva = ref.watch(
              docViewP.select(
                (p) => (
                  initialPage: p.initialPage,
                  pdfViewerController: p.controller,
                ),
              ),
            );
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _tapDownPosition = event.localPosition;
                _tapDownTime = DateTime.now();
                _pointerHasMoved = false;
              },
              onPointerMove: (event) {
                // Track if pointer moved significantly (scrolling)
                if (_tapDownPosition != null) {
                  final distance =
                      (event.localPosition - _tapDownPosition!).distance;
                  if (distance > 10) {
                    // 10 pixel threshold
                    _pointerHasMoved = true;
                  }
                }
              },
              onPointerUp: (event) {
                final now = DateTime.now();
                final tapDuration = now.difference(_tapDownTime ?? now);

                // Reject if moved (scrolling) or held too long
                if (_pointerHasMoved || tapDuration.inMilliseconds > 200) {
                  _pointerHasMoved = false;
                  return;
                }

                // Check for double tap
                if (_lastTapTime != null &&
                    now.difference(_lastTapTime!) <
                        Duration(milliseconds: 300)) {
                  _handleDoubleTap(ref);
                  _lastTapTime = null;
                  _pointerHasMoved = false;
                  return;
                }

                _lastTapTime = now;

                Future.delayed(Duration(milliseconds: 300), () {
                  if (_lastTapTime == now) {
                    // Single tap confirmed - use the down position
                    _handleSingleTap(ref, _tapDownPosition!);
                  }
                });

                _pointerHasMoved = false;
              },
              child: Builder(
                builder: (context) {
                  final localPath = widget.content.path.local;
                  return localPath != null && localPath.isNotEmpty
                      ? SfPdfViewer.file(
                          io.File(localPath),
                          initialPageNumber: pdva.initialPage ?? 1,
                          controller: pdva.pdfViewerController,
                          pageSpacing: 0,
                          canShowPageLoadingIndicator: false,
                        )
                      : SfPdfViewer.network(
                          widget.content.path.url ?? '',
                          initialPageNumber: pdva.initialPage ?? 1,
                          controller: pdva.pdfViewerController,
                        );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  bool _handleTap(WidgetRef ref) {
    final docViewP = PdfDocViewerProvider.state(widget.content.uid);
    final searchViewP = PdfDocViewerProvider.searchState(widget.content.uid);

    final bool isSearching = ref
        .read(searchViewP.select((s) => s.isSearchingNotifier))
        .value;
    if (isSearching) return false;
    final bool isAppBarVisible = ref
        .read(docViewP.select((s) => s.isAppBarVisibleNotifier))
        .value;
    if (isAppBarVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      ref.read(docViewP).updateScrollOffset(0);
      final bool isFocusMode = MainProvider.state
          .act(ref)
          .isFocusMode
          .read(ref);

      if (isFocusMode) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
    ref.read(docViewP).setAppBarVisible(!isAppBarVisible);

    return true;
  }
}

class PdfScrollThumbOverlay extends StatelessWidget {
  const PdfScrollThumbOverlay({super.key, required this.pdva});

  final ({int? initialPage, PdfViewerController pdfViewerController}) pdva;

  @override
  Widget build(BuildContext context) {
    final topPadding = context.topPadding;
    return CustomPdfScrollThumb(
      controller: pdva.pdfViewerController,
      thumbSize: Size(160, 52),
      topPadding: topPadding + kToolbarHeight + 8,
      thumbBuilder: (context, thumbSize, pageNumber, controller) {
        return PdfScrollbarOverlay(
          controller: controller,
          pageProgress: "${pageNumber ?? 0}/${controller.pageCount}",
        );
      },
    );
  }
}
