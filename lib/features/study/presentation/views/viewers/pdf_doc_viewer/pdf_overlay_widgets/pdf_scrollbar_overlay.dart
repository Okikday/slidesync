
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfScrollbarOverlay extends ConsumerWidget {
  final String pageProgress;
  const PdfScrollbarOverlay({super.key, required this.pageProgress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Transform.translate(
      offset: Offset(16, 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 160),
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
                      pageProgress,
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
                  color: theme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(-2, 2)),
                  ],
                ),
                child: SizedBox.square(
                  dimension: kToolbarHeight,
                  child: Center(child: Icon(Icons.drag_indicator, color: theme.onSurface, size: 24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// /// Scroll thumb for [PdfViewer].
// ///
// /// Use with [PdfViewerParams.viewerOverlayBuilder] to add scroll thumbs to the viewer.
// class PdfViewerScrollThumb extends StatefulWidget {
//   const PdfViewerScrollThumb({
//     required this.controller,
//     this.orientation = ScrollbarOrientation.right,
//     this.thumbSize,
//     this.margin = 2,
//     this.thumbBuilder,
//     this.topPadding = 0.0,
//     super.key,
//   });

//   /// [PdfViewerController] attached to the [PdfViewer].
//   final PdfViewerController controller;

//   /// Position/Orientation of the scroll thumb.
//   final ScrollbarOrientation orientation;

//   /// Size of the scroll thumb.
//   final Size? thumbSize;

//   /// Margin from the viewer's edge.
//   final double margin;

//   /// Function to customize the thumb widget.
//   final Widget? Function(BuildContext context, Size thumbSize, int? pageNumber, PdfViewerController controller)?
//   thumbBuilder;

//   /// Determine whether the orientation is vertical or not.
//   bool get isVertical => orientation == ScrollbarOrientation.left || orientation == ScrollbarOrientation.right;

//   //Top padding for app bar
//   final double topPadding;

//   @override
//   State<PdfViewerScrollThumb> createState() => _PdfViewerScrollThumbState();
// }

// class _PdfViewerScrollThumbState extends State<PdfViewerScrollThumb> {
//   double _panStartOffset = 0;
//   Timer? _hideTimer;
//   bool _visible = false;
//   bool _isDraggingThumb = false;
//   VoidCallback? _controllerListener;

//   static const Duration _fadeDuration = Duration(milliseconds: 200);
//   static const Duration _visibleDuration = Duration(seconds: 3);

//   @override
//   void initState() {
//     super.initState();
//     _attachControllerListener();
//   }

//   @override
//   void didUpdateWidget(covariant PdfViewerScrollThumb oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.controller != widget.controller) {
//       _detachControllerListener(oldWidget.controller);
//       _attachControllerListener();
//     }
//   }

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     _detachControllerListener(widget.controller);
//     super.dispose();
//   }

//   void _attachControllerListener() {
//     // assume controller is a ChangeNotifier or has addListener()
//     // make a local callback so we can remove it later
//     _controllerListener = () {
//       _onControllerChange();
//     };
//     try {
//       widget.controller.addListener(_controllerListener!);
//     } catch (e) {
//       // If controller doesn't support addListener, silently ignore.
//       // If you want to support another API, tell me the controller's API.
//     }
//   }

//   void _detachControllerListener(PdfViewerController controller) {
//     if (_controllerListener == null) return;
//     try {
//       controller.removeListener(_controllerListener!);
//     } catch (e) {
//       // ignore
//     }
//     _controllerListener = null;
//   }

//   void _onControllerChange() {
//     // called frequently as the view scrolls/zooms; keep work minimal
//     if (_isDraggingThumb) return; // while dragging, keep visible
//     _showTemporarily();
//   }

//   void _showTemporarily() {
//     // only call setState when visibility actually changes
//     if (!_visible) {
//       setState(() => _visible = true);
//     }
//     // restart hide timer
//     _hideTimer?.cancel();
//     _hideTimer = Timer(_visibleDuration, () {
//       if (mounted && !_isDraggingThumb) {
//         setState(() => _visible = false);
//       }
//     });
//   }

//   void _cancelHideTimer() {
//     _hideTimer?.cancel();
//     _hideTimer = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.controller.isReady) {
//       return const SizedBox();
//     }
//     return widget.isVertical ? _buildVertical(context) : _buildHorizontal(context);
//   }

//   Widget _wrapWithVisibility({required Widget child}) {
//     // AnimatedOpacity for fade, IgnorePointer so invisible thumb doesn't block touches
//     return AnimatedOpacity(
//       duration: _fadeDuration,
//       opacity: _visible ? 1.0 : 0.0,
//       child: IgnorePointer(ignoring: !_visible, child: child),
//     );
//   }

//   Widget _buildVertical(BuildContext context) {
//     final thumbSize = widget.thumbSize ?? const Size(25, 40);
//     final view = widget.controller.visibleRect;
//     final all = widget.controller.documentSize;
//     if (all.height <= view.height) return const SizedBox();

//     final y = -widget.controller.value.y / (all.height - view.height);
//     final vh = view.height * widget.controller.currentZoom - thumbSize.height - widget.topPadding;
//     final top = y * vh;

//     return Positioned(
//       left: widget.orientation == ScrollbarOrientation.left ? widget.margin : null,
//       right: widget.orientation == ScrollbarOrientation.right ? widget.margin : null,
//       top: top + widget.topPadding,
//       width: thumbSize.width,
//       height: thumbSize.height,
//       child: _wrapWithVisibility(
//         child: GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onPanStart: (details) {
//             _isDraggingThumb = true;
//             _cancelHideTimer();
//             _panStartOffset = top - details.localPosition.dy;
//             // ensure visible when user starts dragging
//             if (!_visible) setState(() => _visible = true);
//           },
//           onPanUpdate: (details) {
//             final y = (_panStartOffset + details.localPosition.dy) / (vh);
//             final m = widget.controller.value.clone();
//             m.y = -y * (all.height - view.height);
//             widget.controller.value = m;
//           },
//           onPanEnd: (details) {
//             _isDraggingThumb = false;
//             // restart timer to hide after inactivity
//             _showTemporarily();
//           },
//           child:
//               widget.thumbBuilder?.call(context, thumbSize, widget.controller.pageNumber, widget.controller) ??
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(127),
//                       spreadRadius: 1,
//                       blurRadius: 1,
//                       offset: const Offset(1, 1),
//                     ),
//                   ],
//                 ),
//                 child: Center(child: Text(widget.controller.pageNumber.toString())),
//               ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHorizontal(BuildContext context) {
//     final thumbSize = widget.thumbSize ?? const Size(40, 25);
//     final view = widget.controller.visibleRect;
//     final all = widget.controller.documentSize;
//     if (all.width <= view.width) return const SizedBox();

//     final x = -widget.controller.value.x / (all.width - view.width);
//     final vw = view.width * widget.controller.currentZoom - thumbSize.width;
//     final left = x * vw;

//     return Positioned(
//       top: widget.orientation == ScrollbarOrientation.top ? widget.margin : null,
//       bottom: widget.orientation == ScrollbarOrientation.bottom ? widget.margin : null,
//       left: left,
//       width: thumbSize.width,
//       height: thumbSize.height,
//       child: _wrapWithVisibility(
//         child: GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onPanStart: (details) {
//             _isDraggingThumb = true;
//             _cancelHideTimer();
//             _panStartOffset = left - details.localPosition.dx;
//             if (!_visible) setState(() => _visible = true);
//           },
//           onPanUpdate: (details) {
//             final x = (_panStartOffset + details.localPosition.dx) / vw;
//             final m = widget.controller.value.clone();
//             m.x = -x * (all.width - view.width);

//             widget.controller.value = m;
//           },
//           onPanEnd: (details) {
//             _isDraggingThumb = false;
//             _showTemporarily();
//           },
//           child:
//               widget.thumbBuilder?.call(context, thumbSize, widget.controller.pageNumber, widget.controller) ??
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(127),
//                       spreadRadius: 1,
//                       blurRadius: 1,
//                       offset: const Offset(1, 1),
//                     ),
//                   ],
//                 ),
//                 child: Center(child: Text(widget.controller.pageNumber.toString())),
//               ),
//         ),
//       ),
//     );
//   }
// }
