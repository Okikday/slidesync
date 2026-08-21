import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  Offset? _lastScrollOffset;

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
    final currentOffset = widget.controller.scrollOffset;

    // Check if actually scrolling (position changed)
    if (currentOffset != _lastScrollOffset) {
      _lastScrollOffset = currentOffset;

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

/// Custom scroll thumb for [SfPdfViewer] with top padding support.
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
  @override
  Widget build(BuildContext context) {
    final pageCount = widget.controller.pageCount;
    final pageNumber = widget.controller.pageNumber;

    if (pageCount == 0) {
      return const SizedBox();
    }

    return widget.isVertical
        ? _buildVertical(context, pageNumber, pageCount)
        : _buildHorizontal(context, pageNumber, pageCount);
  }

  Widget _buildVertical(BuildContext context, int pageNumber, int pageCount) {
    final thumbSize = widget.thumbSize ?? const Size(25, 40);

    // Calculate thumb position based on current page / total pages
    final progress = pageCount > 1 ? (pageNumber - 1) / (pageCount - 1) : 0.0;
    final availableHeight =
        MediaQuery.of(context).size.height - thumbSize.height - widget.topPadding - widget.bottomPadding;
    final top =
        (progress * availableHeight + widget.topPadding).clamp(widget.topPadding, widget.topPadding + availableHeight);

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
        onPanUpdate: (details) {
          // Navigate pages via drag
          final newProgress = ((top + details.delta.dy - widget.topPadding) / availableHeight).clamp(0.0, 1.0);
          final targetPage = ((newProgress * (pageCount - 1)) + 1).round().clamp(1, pageCount);
          if (targetPage != pageNumber) {
            widget.controller.jumpToPage(targetPage);
          }
        },
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context, int pageNumber, int pageCount) {
    final thumbSize = widget.thumbSize ?? const Size(40, 25);

    final progress = pageCount > 1 ? (pageNumber - 1) / (pageCount - 1) : 0.0;
    final availableWidth = MediaQuery.of(context).size.width - thumbSize.width;
    final left = (progress * availableWidth).clamp(0.0, availableWidth);

    return Positioned(
      top: widget.orientation == ScrollbarOrientation.top ? widget.margin : null,
      bottom: widget.orientation == ScrollbarOrientation.bottom ? widget.margin : null,
      left: left,
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
        onPanUpdate: (details) {
          final newProgress = ((left + details.delta.dx) / availableWidth).clamp(0.0, 1.0);
          final targetPage = ((newProgress * (pageCount - 1)) + 1).round().clamp(1, pageCount);
          if (targetPage != pageNumber) {
            widget.controller.jumpToPage(targetPage);
          }
        },
      ),
    );
  }
}
