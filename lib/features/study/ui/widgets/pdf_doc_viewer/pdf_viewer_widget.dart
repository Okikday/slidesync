import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_overlay_widgets/pdf_scrollbar_overlay.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  const PdfViewerWidget({super.key, required this.content});

  final CourseContent content;

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  Offset? _tapDownPosition;
  bool _pointerHasMoved = false;
  DateTime? _tapDownTime;
  DateTime? _lastTapTime;

  void _handleSingleTap(WidgetRef ref, Offset position) {
    final controller = PdfDocViewerProvider.state(widget.content.contentId).select((s) => s.controller).read(ref);
    if (controller.textSelectionDelegate.hasSelectedText) {
      controller.textSelectionDelegate.clearTextSelection();
    }
    _handleTap(ref);
  }

  void _handleDoubleTap(WidgetRef ref) {
    final docViewP = PdfDocViewerProvider.state(widget.content.contentId);
    final controller = ref.read(docViewP.select((s) => s.controller));

    if (controller.currentZoom > controller.minScale) {
      controller.setZoom(controller.centerPosition, controller.minScale);
    } else {
      controller.setZoom(controller.centerPosition, 2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    log("Rebuild pdfviewer widget!!!");
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.white,
        ref.watch(PdfDocViewerProvider.ispdfViewerInDarkMode).value ?? false ? BlendMode.difference : BlendMode.dst,
      ),
      child: Screenshot(
        controller: PdfDocViewerState.screenshotController,
        child: Consumer(
          builder: (context, ref, child) {
            final docViewP = PdfDocViewerProvider.state(widget.content.contentId);
            final pdva = ref.watch(
              docViewP.select((p) => (initialPage: p.initialPage, pdfViewerController: p.controller)),
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
                  final distance = (event.localPosition - _tapDownPosition!).distance;
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
                if (_lastTapTime != null && now.difference(_lastTapTime!) < Duration(milliseconds: 300)) {
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
              child: widget.content.path.filePath.isNotEmpty
                  ? PdfViewer.file(
                      widget.content.path.filePath,
                      initialPageNumber: pdva.initialPage ?? 1,
                      params: PdfViewerParams(
                        panAxis: PanAxis.aligned,
                        scrollPhysics: BouncingScrollPhysics(),
                        layoutPages: (pages, params) {
                          final width = pages.fold(0.0, (w, p) => math.max(w, p.width)) + params.margin * 2;

                          final pageLayout = <Rect>[];
                          double y = params.margin + (130);
                          for (int i = 0; i < pages.length; i++) {
                            final page = pages[i];
                            final rect = Rect.fromLTWH((width - page.width) / 2, y, page.width, page.height);
                            pageLayout.add(rect);
                            y += page.height + params.margin;
                          }

                          return PdfPageLayout(pageLayouts: pageLayout, documentSize: Size(width, y));
                        },
                        backgroundColor: theme.background,
                        activeMatchTextColor: theme.primary.withValues(alpha: 0.5),
                        linkHandlerParams: PdfLinkHandlerParams(
                          onLinkTap: (link) async {
                            // log("Link tapped: ${link.url ?? link.dest}");
                            if (link.url != null) {
                              UiUtils.showFlushBar(context, msg: "Opening link...");
                              await launchUrl(link.url!, mode: LaunchMode.platformDefault);
                            }
                          },
                          linkColor: Colors.blue.withValues(alpha: 0.04),
                        ),
                        viewerOverlayBuilder: (context, size, handleLinkTap) => [
                          // ValueListenableBuilder(
                          //   valueListenable: pdva.isAppBarVisibleNotifier,
                          //   builder: (context, value, child) {
                          //     if (!value) return const SizedBox();

                          //   },
                          PdfScrollThumbOverlay(pdva: pdva),
                        ],
                        // onGeneralTap: (context, controller, details) {
                        //   log("normal tap");
                        //   if (details.type == PdfViewerGeneralTapType.doubleTap) {
                        //     if (controller.currentZoom > controller.minScale) {
                        //       controller.setZoom(controller.centerPosition, controller.minScale);
                        //     } else {
                        //       controller.setZoom(controller.centerPosition, 2.0);
                        //     }

                        //     return false;
                        //   }
                        //   // if (controller.textSelectionDelegate.hasSelectedText &&
                        //   //     details.type == PdfViewerGeneralTapType.tap) {
                        //   //   return false;
                        //   // }
                        //   if (details.type != PdfViewerGeneralTapType.tap) return false;
                        //   if (controller.textSelectionDelegate.hasSelectedText) {
                        //     controller.textSelectionDelegate.clearTextSelection();
                        //   }
                        //   return _handleTap(ref);
                        // },
                        pagePaintCallbacks: [
                          (canvas, pageRect, page) {
                            final searchViewP = PdfDocViewerProvider.searchState(widget.content.contentId);
                            // forward to the active searcher, if any
                            ref
                                .read(searchViewP.select((s) => s.textSearcher))
                                ?.pageTextMatchPaintCallback(canvas, pageRect, page);
                          },
                          // other page paint callbacks...
                        ],
                        textSelectionParams: PdfTextSelectionParams(
                          buildSelectionHandle: (context, anchor, state) {
                            final isStart = anchor.type == PdfTextSelectionAnchorType.a;
                            return Transform.translate(
                              offset: Offset(isStart ? 0 : 0, isStart ? 36 : 0),
                              child: MaterialTextSelectionControls().buildHandle(
                                context,
                                isStart ? TextSelectionHandleType.left : TextSelectionHandleType.right,
                                anchor.rect.height,
                              ),
                            );
                          },
                        ),
                      ),
                      controller: pdva.pdfViewerController,
                    )
                  : PdfViewer.uri(Uri.parse(widget.content.path.urlPath), initialPageNumber: pdva.initialPage ?? 1),
            );
          },
        ),
      ),
    );
  }

  bool _handleTap(WidgetRef ref) {
    final docViewP = PdfDocViewerProvider.state(widget.content.contentId);
    final searchViewP = PdfDocViewerProvider.searchState(widget.content.contentId);

    final bool isSearching = ref.read(searchViewP.select((s) => s.isSearchingNotifier)).value;
    if (isSearching) return false;
    final bool isAppBarVisible = ref.read(docViewP.select((s) => s.isAppBarVisibleNotifier)).value;
    if (isAppBarVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      ref.read(docViewP).updateScrollOffset(0);
      final bool isFocusMode = ref.read(MainProvider.isFocusModeProvider) ?? false;
      if (isFocusMode) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
    // log("isAppBarVisible: $isAppBarVisible");
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
        return PdfScrollbarOverlay(controller: controller, pageProgress: "${pageNumber ?? 0}/${controller.pageCount}");
      },
    );
  }
}
