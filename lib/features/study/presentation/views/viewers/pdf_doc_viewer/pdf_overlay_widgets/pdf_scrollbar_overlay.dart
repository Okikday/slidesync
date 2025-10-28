import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfScrollbarOverlay extends ConsumerStatefulWidget {
  final PdfViewerController controller;
  final String pageProgress;

  const PdfScrollbarOverlay({super.key, required this.controller, required this.pageProgress});

  @override
  ConsumerState<PdfScrollbarOverlay> createState() => _PdfScrollbarOverlayState();
}

class _PdfScrollbarOverlayState extends ConsumerState<PdfScrollbarOverlay> {
  bool _isVisible = false;
  Timer? _hideTimer;
  double? _lastScrollPosition;

  @override
  void initState() {
    super.initState();
    // Listen to scroll changes
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final currentPosition = double.parse(
      widget.controller.value.row1[3].abs().clamp(0.0, double.infinity).toStringAsFixed(2),
    );

    // Check if actually scrolling (position changed)
    if (currentPosition != _lastScrollPosition) {
      _lastScrollPosition = currentPosition;

      // Show overlay
      if (!_isVisible) {
        setState(() => _isVisible = true);
      }

      // Cancel existing timer
      _hideTimer?.cancel();

      // Start new hide timer (2 seconds)
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isVisible = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Transform.translate(
        offset: const Offset(16, 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Page indicator container
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 60),
                  child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey[800]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        widget.pageProgress,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(-2, 2)),
                    ],
                  ),
                  child: SizedBox.square(
                    dimension: kToolbarHeight,
                    child: Center(child: Icon(Icons.drag_indicator, color: theme.colorScheme.onSurface, size: 24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom scroll thumb for [PdfViewer] with top padding support.
class CustomPdfScrollThumb extends StatefulWidget {
  const CustomPdfScrollThumb({
    required this.controller,
    this.orientation = ScrollbarOrientation.right,
    this.thumbSize,
    this.margin = 2,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.thumbBuilder,
    super.key,
  });

  final PdfViewerController controller;
  final ScrollbarOrientation orientation;
  final Size? thumbSize;
  final double margin;
  final double topPadding;
  final double bottomPadding;
  final Widget? Function(BuildContext context, Size thumbSize, int? pageNumber, PdfViewerController controller)?
  thumbBuilder;

  bool get isVertical => orientation == ScrollbarOrientation.left || orientation == ScrollbarOrientation.right;

  @override
  State<CustomPdfScrollThumb> createState() => _CustomPdfScrollThumbState();
}

class _CustomPdfScrollThumbState extends State<CustomPdfScrollThumb> {
  double _panStartOffset = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isReady) {
      return const SizedBox();
    }
    return widget.isVertical ? _buildVertical(context) : _buildHorizontal(context);
  }

  /// Calculate the correct page number based on visible viewport
  int _getCorrectPageNumber() {
    if (!widget.controller.isReady) return 1;

    final pages = widget.controller.pages;
    final pageCount = widget.controller.pageCount;
    if (pages.isEmpty || pageCount == 0) return 1;

    final visibleRect = widget.controller.visibleRect;
    final documentSize = widget.controller.documentSize;

    // Calculate cumulative page positions
    double cumulativeHeight = 0;
    final boundaryMargin = widget.controller.params.boundaryMargin;
    final pageSpacing = widget.controller.params.margin;

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      // if (page == null) continue;

      final pageHeight = page.height;
      final pageTop = cumulativeHeight;
      final pageBottom = cumulativeHeight + pageHeight;

      // Check if visible rect intersects with this page
      if (visibleRect.bottom > pageTop && visibleRect.top < pageBottom) {
        // Calculate how much of this page is visible
        final visibleTop = visibleRect.top > pageTop ? visibleRect.top : pageTop;
        final visibleBottom = visibleRect.bottom < pageBottom ? visibleRect.bottom : pageBottom;
        final visibleHeight = visibleBottom - visibleTop;

        // If more than 50% of viewport shows this page, or if it's the most visible
        if (visibleHeight > visibleRect.height * 0.3) {
          return page.pageNumber;
        }
      }

      cumulativeHeight += pageHeight + pageSpacing;
    }

    // Fallback: use viewport center position
    final viewportCenterY = visibleRect.center.dy;
    final avgPageHeight = documentSize.height / pageCount;
    final estimatedPage = (viewportCenterY / avgPageHeight).floor() + 1;

    return estimatedPage.clamp(1, pageCount);
  }

  Widget _buildVertical(BuildContext context) {
    final thumbSize = widget.thumbSize ?? const Size(25, 40);
    final view = widget.controller.visibleRect;
    final all = widget.controller.documentSize;
    final boundaryMargin = widget.controller.params.boundaryMargin;

    final effectiveDocHeight = boundaryMargin == null || boundaryMargin.vertical.isInfinite
        ? all.height
        : all.height + boundaryMargin.vertical;

    if (effectiveDocHeight <= view.height) return const SizedBox();

    final scrollRange = effectiveDocHeight - view.height;
    final minScrollY = boundaryMargin == null || boundaryMargin.vertical.isInfinite ? 0.0 : -boundaryMargin.top;

    final y = (-widget.controller.value.y - minScrollY) / scrollRange;

    // Adjust available height for thumb movement (accounting for both paddings)
    final availableHeight =
        view.height * widget.controller.currentZoom - thumbSize.height - widget.topPadding - widget.bottomPadding;
    final top = y * availableHeight + widget.topPadding;

    // Calculate correct page number based on visible area center
    final pageNumber = _getCorrectPageNumber();

    return Positioned(
      left: widget.orientation == ScrollbarOrientation.left ? widget.margin : null,
      right: widget.orientation == ScrollbarOrientation.right ? widget.margin : null,
      top: top,
      width: thumbSize.width,
      height: thumbSize.height,
      child: GestureDetector(
        child:
            widget.thumbBuilder?.call(context, thumbSize, pageNumber, widget.controller) ??
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(127),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Center(child: Text(pageNumber.toString())),
            ),
        onPanStart: (details) {
          _panStartOffset = top - details.localPosition.dy;
        },
        onPanUpdate: (details) {
          final adjustedY = (_panStartOffset + details.localPosition.dy - widget.topPadding) / availableHeight;
          final m = widget.controller.value.clone();
          m.y = -(adjustedY * scrollRange + minScrollY);
          widget.controller.value = m;
        },
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final thumbSize = widget.thumbSize ?? const Size(40, 25);
    final view = widget.controller.visibleRect;
    final all = widget.controller.documentSize;
    final boundaryMargin = widget.controller.params.boundaryMargin;

    final effectiveDocWidth = boundaryMargin == null || boundaryMargin.horizontal.isInfinite
        ? all.width
        : all.width + boundaryMargin.horizontal;

    if (effectiveDocWidth <= view.width) return const SizedBox();

    final scrollRange = effectiveDocWidth - view.width;
    final minScrollX = boundaryMargin == null || boundaryMargin.horizontal.isInfinite ? 0.0 : -boundaryMargin.left;

    final x = (-widget.controller.value.x - minScrollX) / scrollRange;
    final vw = view.width * widget.controller.currentZoom - thumbSize.width;
    final left = x * vw;

    return Positioned(
      top: widget.orientation == ScrollbarOrientation.top ? widget.margin : null,
      bottom: widget.orientation == ScrollbarOrientation.bottom ? widget.margin : null,
      left: left,
      width: thumbSize.width,
      height: thumbSize.height,
      child: GestureDetector(
        child:
            widget.thumbBuilder?.call(context, thumbSize, widget.controller.pageNumber, widget.controller) ??
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(127),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Center(child: Text(widget.controller.pageNumber.toString())),
            ),
        onPanStart: (details) {
          _panStartOffset = left - details.localPosition.dx;
        },
        onPanUpdate: (details) {
          final x = (_panStartOffset + details.localPosition.dx) / vw;
          final m = widget.controller.value.clone();
          m.x = -(x * scrollRange + minScrollX);
          widget.controller.value = m;
        },
      ),
    );
  }
}
