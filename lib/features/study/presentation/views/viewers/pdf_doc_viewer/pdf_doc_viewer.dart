import 'dart:async';
import 'dart:math' as math;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart' hide PdfViewerScrollThumb;
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/study/presentation/controllers/doc_viewer_controllers/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/doc_viewer_controllers/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/providers/pdf_doc_viewer_providers.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_viewer_app_bar.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/pdf_scrollbar_overlay.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/pdf_tools_menu.dart';
import 'package:slidesync/features/main/presentation/main/controllers/main_view_controller.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class PdfDocViewer extends ConsumerStatefulWidget {
  final CourseContent content;
  const PdfDocViewer({super.key, required this.content});

  @override
  ConsumerState<PdfDocViewer> createState() => _PdfDocViewerState();
}

class _PdfDocViewerState extends ConsumerState<PdfDocViewer> {
  late final PdfDocViewerController pdva;
  late final PdfDocSearchController pdsa;
  late final PdfViewerController pdfViewerController;

  @override
  void initState() {
    super.initState();
    pdfViewerController = PdfViewerController();

    pdva = PdfDocViewerController.of(widget.content, pdfViewerController: pdfViewerController);
    pdsa = PdfDocSearchController(
      context: context,
      pdfViewerController: pdfViewerController,
      onStateChanged: () {
        setState(() {});
      },
    );
    pdva.initialize().then((data) {
      if (data == true) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() {
            pdva.initialPage;
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    pdsa.dispose();
    pdva.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final content = widget.content;
    return ValueListenableBuilder(
      valueListenable: pdsa.isSearchingNotifier,
      builder: (context, value, child) {
        return PopScope(
          canPop: !value,
          onPopInvokedWithResult: (didPop, result) {
            if (value) pdsa.isSearchingNotifier.value = false;
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          },
          child: AnnotatedRegion(
            value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              // extendBodyBehindAppBar: true,
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pdsa.textSearcher != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
                      child: _NavigationControls(
                        textSearcher: pdsa.textSearcher,
                        onNavigateToInstance: pdsa.navigateToInstance,
                      ),
                    ),
                  ValueListenableBuilder(
                    valueListenable: pdva.isAppBarVisibleNotifier,
                    builder: (context, value, child) {
                      if (!value || pdsa.textSearcher != null) return const SizedBox();
                      return PdfToolsMenu(isVisible: true);
                    },
                  ),
                ],
              ),

              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        ref.watch(PdfDocViewerProviders.ispdfViewerInDarkModeNotifier).value ?? false
                            ? BlendMode.difference
                            : BlendMode.dst,
                      ),
                      child: Screenshot(
                        controller: PdfDocViewerController.screenshotController,
                        child: content.path.filePath.isNotEmpty
                            ? PdfViewer.file(
                                content.path.filePath,
                                initialPageNumber: pdva.initialPage,
                                params: PdfViewerParams(
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
                                  viewerOverlayBuilder: (context, size, handleLinkTap) => [
                                    // ValueListenableBuilder(
                                    //   valueListenable: pdva.isAppBarVisibleNotifier,
                                    //   builder: (context, value, child) {
                                    //     if (!value) return const SizedBox();

                                    //   },
                                    PdfViewerScrollThumb(
                                      controller: pdfViewerController,
                                      thumbSize: Size(160, 52),
                                      topPadding: 130 / 2 + 8,
                                      thumbBuilder: (context, thumbSize, pageNumber, controller) {
                                        return PdfScrollbarOverlay(
                                          pageProgress: "${pageNumber ?? 0}/${controller.pageCount}",
                                        );
                                      },
                                    ),
                                  ],
                                  onGeneralTap: (context, controller, details) {
                                    // Handle this part
                                    // final currentRect = controller.visibleRect;
                                    // final currentPageNum = controller.pageNumber;
                                    if (details.type != PdfViewerGeneralTapType.tap) return false;
                                    controller.textSelectionDelegate.clearTextSelection();
                                    // final currentZoom = controller.currentZoom;
                                    // final currentPosition = controller.centerPosition;

                                    final bool isSearching = pdsa.isSearchingNotifier.value;
                                    if (isSearching) return false;
                                    final bool isAppBarVisible = pdva.isAppBarVisibleNotifier.value;
                                    if (isAppBarVisible) {
                                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                                    } else {
                                      final bool isFocusMode =
                                          ref.read(MainViewController.isFocusModeProvider) ?? false;
                                      if (isFocusMode) {
                                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                                      } else {
                                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                                      }
                                    }
                                    pdva.isAppBarVisibleNotifier.value = !isAppBarVisible;

                                    return true;
                                  },
                                  pagePaintCallbacks: [
                                    (canvas, pageRect, page) {
                                      // forward to the active searcher, if any
                                      pdsa.textSearcher?.pageTextMatchPaintCallback(canvas, pageRect, page);
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
                                controller: pdfViewerController,
                              )
                            : PdfViewer.uri(Uri.parse(content.path.urlPath), initialPageNumber: pdva.initialPage),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder(
                      valueListenable: pdva.isAppBarVisibleNotifier,
                      builder: (context, value, child) {
                        return AppBarContainer(
                          appBarHeight: value ? null : 0,
                          child: PdfDocViewerAppBar(pdva: pdva, pdsa: pdsa, title: content.title),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationControls extends ConsumerWidget {
  const _NavigationControls({required this.textSearcher, required this.onNavigateToInstance});

  final PdfTextSearcher? textSearcher;
  final Future<void> Function(bool) onNavigateToInstance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final s = textSearcher;
    final hasMatches = s?.hasMatches == true;
    final inProgress = s?.isSearching == true;

    final resultText = hasMatches
        ? "${(s!.currentIndex ?? 0) + 1} of ${s.matches.length}${inProgress ? '..' : ''}"
        : "0 of 0";

    final canNavigate = hasMatches;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (resultText != "0 of 0")
          CustomText(
            resultText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: canNavigate ? theme.onBackground : theme.onBackground.withValues(alpha: 0.5),
            ),
          ),
        ConstantSizing.rowSpacing(4),
        _NavigationButton(
          onPressed: canNavigate ? () => onNavigateToInstance(false) : null,
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: "Previous result",
          iconColor: theme.onBackground,
          canNavigate: canNavigate,
        ),
        _NavigationButton(
          onPressed: canNavigate ? () => onNavigateToInstance(true) : null,
          icon: Icons.arrow_forward_ios_rounded,
          tooltip: "Next result",
          iconColor: theme.onBackground,
          canNavigate: canNavigate,
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.canNavigate,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final bool canNavigate;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: canNavigate ? iconColor : iconColor.withValues(alpha: 0.3)),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }
}
