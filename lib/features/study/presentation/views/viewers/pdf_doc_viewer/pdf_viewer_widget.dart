import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/main/presentation/main/controllers/main_view_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';

class PdfViewerWidget extends ConsumerWidget {
  const PdfViewerWidget({super.key, required this.content});

  final CourseContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    log("Rebuild pdfviewer widget!!!");
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.white,
        ref.watch(PdfDocViewerController.ispdfViewerInDarkMode).value ?? false ? BlendMode.difference : BlendMode.dst,
      ),
      child: Screenshot(
        controller: PdfDocViewerNotifier.screenshotController,
        child:
            // content.path.filePath.isNotEmpty
            //     ?
            Consumer(
              builder: (context, ref, child) {
                final docViewP = pdfDocViewerStateProvider(content.contentId);
                final pdvaN = ref.watch(
                  docViewP.select(
                    (s) => s.whenData((p) => (initialPage: p.initialPage, pdfViewerController: p.pdfViewerController)),
                  ),
                );
                return pdvaN.when(
                  data: (pdva) {
                    return PdfViewer.file(
                      content.path.filePath,
                      initialPageNumber: pdva.initialPage,
                      params: PdfViewerParams(
                        scrollPhysics: BouncingScrollPhysics(),
                        // layoutPages: (pages, params) {
                        //   final width = pages.fold(0.0, (w, p) => math.max(w, p.width)) + params.margin * 2;

                        //   final pageLayout = <Rect>[];
                        //   double y = params.margin + (130);
                        //   for (int i = 0; i < pages.length; i++) {
                        //     final page = pages[i];
                        //     final rect = Rect.fromLTWH((width - page.width) / 2, y, page.width, page.height);
                        //     pageLayout.add(rect);
                        //     y += page.height + params.margin;
                        //   }

                        //   return PdfPageLayout(pageLayouts: pageLayout, documentSize: Size(width, y));
                        // },
                        backgroundColor: theme.background,
                        activeMatchTextColor: theme.primary.withValues(alpha: 0.5),
                        // viewerOverlayBuilder: (context, size, handleLinkTap) => [
                        //   // ValueListenableBuilder(
                        //   //   valueListenable: pdva.isAppBarVisibleNotifier,
                        //   //   builder: (context, value, child) {
                        //   //     if (!value) return const SizedBox();

                        //   //   },
                        //   PdfViewerScrollThumb(
                        //     controller: pdva.pdfViewerController,
                        //     thumbSize: Size(160, 52),
                        //     thumbBuilder: (context, thumbSize, pageNumber, controller) {
                        //       return PdfScrollbarOverlay(pageProgress: "${pageNumber ?? 0}/${controller.pageCount}");
                        //     },
                        //   ),
                        // ],
                        onGeneralTap: (context, controller, details) {
                          // if (details.type == PdfViewerGeneralTapType.doubleTap) {
                          //   if (controller.currentZoom > controller.minScale) {
                          //     controller.setZoom(controller.centerPosition, controller.minScale);
                          //   } else {
                          //     controller.setZoom(controller.centerPosition, 2.0);
                          //   }

                          //   return false;
                          // }
                          // if (controller.textSelectionDelegate.hasSelectedText &&
                          //     details.type == PdfViewerGeneralTapType.tap) {
                          //   return false;
                          // }
                          // if (details.type != PdfViewerGeneralTapType.tap) return false;
                          // if (controller.textSelectionDelegate.hasSelectedText) {
                          //   controller.textSelectionDelegate.clearTextSelection();
                          // }
                          // final currentZoom = controller.currentZoom;
                          // final currentPosition = controller.centerPosition;
                          final docViewP = pdfDocViewerStateProvider(content.contentId);
                          final searchViewP = pdfDocSearchStateProvider(content.contentId);

                          final bool isSearching = ref.read(searchViewP.select((s) => s.value?.isSearching ?? true));
                          if (isSearching) return false;
                          final bool? isAppBarVisible = ref.read(docViewP.select((s) => s.value?.isAppBarVisible));
                          if (isAppBarVisible == true) {
                            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                          } else {
                            ref.read(docViewP.notifier).updateScrollOffset(0);
                            final bool isFocusMode = ref.read(MainViewController.isFocusModeProvider) ?? false;
                            if (isFocusMode) {
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                            } else {
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                            }
                          }
                          // log("isAppBarVisible: $isAppBarVisible");
                          if (isAppBarVisible != null) ref.read(docViewP.notifier).setAppBarVisible(!isAppBarVisible);

                          return true;
                        },
                        pagePaintCallbacks: [
                          (canvas, pageRect, page) {
                            final searchViewP = pdfDocSearchStateProvider(content.contentId);
                            // forward to the active searcher, if any
                            ref
                                .read(searchViewP.select((s) => s.value?.textSearcher))
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
                    );
                  },
                  error: (e, st) => Icon(Icons.error),
                  loading: () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularLoadingIndicator(dimension: 40)],
                  ),
                );
              },
            ),
        // : PdfViewer.uri(Uri.parse(content.path.urlPath), initialPageNumber: pdva.initialPage),
      ),
    );
  }
}
