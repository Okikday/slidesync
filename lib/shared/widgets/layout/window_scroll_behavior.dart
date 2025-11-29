import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

/// A ScrollBehavior that applies Windows-style scrollbars on desktop platforms.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   scrollBehavior: WindowsScrollBehavior(),
///   // ... rest of your app
/// )
/// ```
class WindowsScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Only apply custom scrollbar on Windows
    if (defaultTargetPlatform != TargetPlatform.windows) {
      return super.buildScrollbar(context, child, details);
    }

    return WindowsScrollbar(controller: details.controller, child: child);
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

/// Windows-style scrollbar with native behavior:
/// - Click arrows to scroll gradually
/// - Hold arrows for continuous scrolling
/// - Drag thumb to scroll
/// - Click track to jump to position
class WindowsScrollbar extends ConsumerStatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final bool thumbVisibility;
  final bool trackVisibility;
  final double thickness;
  final Radius? radius;
  final bool interactive;

  const WindowsScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.thumbVisibility = false,
    this.trackVisibility = false,
    this.thickness = 16.0,
    this.radius,
    this.interactive = true,
  });

  @override
  ConsumerState<WindowsScrollbar> createState() => _WindowsScrollbarState();
}

class _WindowsScrollbarState extends ConsumerState<WindowsScrollbar> {
  final ValueNotifier<bool> _isHovering = ValueNotifier(false);
  final ValueNotifier<bool> _isDraggingThumb = ValueNotifier(false);
  final ValueNotifier<bool> _isPressingUpArrow = ValueNotifier(false);
  final ValueNotifier<bool> _isPressingDownArrow = ValueNotifier(false);
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);
  final FocusNode _focusNode = FocusNode();

  ScrollController? _effectiveController;

  // Continuous scroll state
  bool _isContinuousScrolling = false;
  bool _scrollingUp = false;

  static const double _arrowSize = 16.0;
  static const double _scrollIncrement = 100.0;
  static const Duration _initialScrollDelay = Duration(milliseconds: 400);
  static const Duration _continuousScrollInterval = Duration(milliseconds: 50);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateController();
  }

  @override
  void didUpdateWidget(WindowsScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateController();
    }
  }

  void _updateController() {
    final newController = widget.controller ?? PrimaryScrollController.maybeOf(context);
    if (newController != _effectiveController) {
      _effectiveController?.removeListener(_onScroll);
      _effectiveController = newController;
      _effectiveController?.addListener(_onScroll);
      _onScroll();
    }
  }

  void _onScroll() {
    if (_effectiveController?.hasClients ?? false) {
      _scrollOffset.value = _effectiveController!.offset;
    }
  }

  @override
  void dispose() {
    _effectiveController?.removeListener(_onScroll);
    _focusNode.dispose();
    _isHovering.dispose();
    _isDraggingThumb.dispose();
    _isPressingUpArrow.dispose();
    _isPressingDownArrow.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: MouseRegion(
        onEnter: (_) {
          _isHovering.value = true;
          _focusNode.requestFocus();
        },
        onExit: (_) => _isHovering.value = false,
        child: Stack(children: [widget.child, if (widget.interactive) _buildScrollbar()]),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (_effectiveController == null || !_effectiveController!.hasClients) {
      return KeyEventResult.ignored;
    }

    bool? scrollUp;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      scrollUp = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      scrollUp = false;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      scrollUp = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      scrollUp = false;
    } else {
      return KeyEventResult.ignored;
    }

    _scrollByIncrement(up: scrollUp);
    return KeyEventResult.handled;
  }

  Widget _buildScrollbar() {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollOffset,
      builder: (context, offset, _) {
        if (_effectiveController == null || !_effectiveController!.hasClients) {
          return const SizedBox.shrink();
        }

        try {
          final position = _effectiveController!.position;
          final scrollExtent = position.maxScrollExtent;

          if (scrollExtent <= 0) return const SizedBox.shrink();

          final viewportDimension = position.viewportDimension;

          // Calculate thumb metrics
          final totalTrackHeight = viewportDimension - (2 * _arrowSize);
          final thumbHeight = (viewportDimension / (scrollExtent + viewportDimension)) * totalTrackHeight;
          final clampedThumbHeight = thumbHeight.clamp(30.0, totalTrackHeight);

          final scrollPercentage = scrollExtent > 0 ? offset / scrollExtent : 0.0;
          final availableSpace = totalTrackHeight - clampedThumbHeight;
          final thumbOffset = scrollPercentage * availableSpace;

          return ValueListenableBuilder<bool>(
            valueListenable: _isHovering,
            builder: (context, isHovering, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isDraggingThumb,
                builder: (context, isDragging, _) {
                  final shouldShow = widget.thumbVisibility || isHovering || isDragging;

                  return Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: shouldShow ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: SizedBox(
                        width: widget.thickness,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.trackVisibility || isHovering
                                ? (Colors.grey[200])?.withAlpha(20)
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              _buildArrowButton(ref, isUp: true),
                              Expanded(
                                child: _buildTrackAndThumb(
                                  totalTrackHeight,
                                  thumbOffset,
                                  clampedThumbHeight,
                                  isHovering,
                                  isDragging,
                                ),
                              ),
                              _buildArrowButton(ref, isUp: false),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        } catch (e) {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildArrowButton(WidgetRef ref, {required bool isUp}) {
    return ValueListenableBuilder<bool>(
      valueListenable: isUp ? _isPressingUpArrow : _isPressingDownArrow,
      builder: (context, isPressed, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isHovering,
          builder: (context, isHovering, _) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (_) => _handleArrowPress(up: isUp),
                onTapUp: (_) => _handleArrowRelease(up: isUp),
                onTapCancel: () => _handleArrowRelease(up: isUp),
                child: SizedBox(
                  height: _arrowSize,
                  width: widget.thickness,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isPressed
                          ? ref.adjustBgAndSecondaryWithLerpExtra
                          : isHovering
                          ? ref.adjustBgAndSecondaryWithLerp
                          : ref.adjustBgAndSecondaryWithLerp,
                      // border: Border(
                      //   bottom: isUp ? BorderSide(color: Colors.grey[300]!, width: 1) : BorderSide.none,
                      //   top: !isUp ? BorderSide(color: Colors.grey[300]!, width: 1) : BorderSide.none,
                      // ),
                    ),
                    child: Icon(isUp ? Iconsax.arrow_up_1 : Iconsax.arrow_down, size: 16, color: ref.onBackground),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrackAndThumb(
    double totalTrackHeight,
    double thumbOffset,
    double thumbHeight,
    bool isHovering,
    bool isDragging,
  ) {
    return GestureDetector(
      onTapDown: (details) {
        _handleTrackTap(details.localPosition.dy, totalTrackHeight, thumbOffset, thumbHeight);
      },
      child: Stack(
        children: [
          Positioned(
            top: thumbOffset,
            left: 2,
            right: 2,
            child: GestureDetector(
              onVerticalDragStart: (_) => _isDraggingThumb.value = true,
              onVerticalDragUpdate: (details) {
                _handleThumbDrag(details.delta.dy, totalTrackHeight, thumbHeight);
              },
              onVerticalDragEnd: (_) => _isDraggingThumb.value = false,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  height: thumbHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDragging
                          ? Colors.grey[600]
                          : isHovering
                          ? Colors.grey[500]
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleArrowPress({required bool up}) {
    if (up) {
      _isPressingUpArrow.value = true;
    } else {
      _isPressingDownArrow.value = true;
    }

    _scrollByIncrement(up: up);

    Future.delayed(_initialScrollDelay, () {
      if ((up && _isPressingUpArrow.value) || (!up && _isPressingDownArrow.value)) {
        _startContinuousScroll(up: up);
      }
    });
  }

  void _handleArrowRelease({required bool up}) {
    if (up) {
      _isPressingUpArrow.value = false;
    } else {
      _isPressingDownArrow.value = false;
    }
    _isContinuousScrolling = false;
  }

  void _scrollByIncrement({required bool up}) {
    if (_effectiveController == null || !_effectiveController!.hasClients) return;

    final offset = _effectiveController!.offset + (up ? -_scrollIncrement : _scrollIncrement);
    final clampedOffset = offset.clamp(0.0, _effectiveController!.position.maxScrollExtent);

    _effectiveController!.animateTo(clampedOffset, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
  }

  void _startContinuousScroll({required bool up}) {
    if (_isContinuousScrolling) return;

    _isContinuousScrolling = true;
    _scrollingUp = up;
    _continuousScrollLoop();
  }

  void _continuousScrollLoop() async {
    while (_isContinuousScrolling &&
        ((_scrollingUp && _isPressingUpArrow.value) || (!_scrollingUp && _isPressingDownArrow.value))) {
      _scrollByIncrement(up: _scrollingUp);
      await Future.delayed(_continuousScrollInterval);
    }
  }

  void _handleTrackTap(double tapPosition, double trackHeight, double thumbOffset, double thumbHeight) {
    if (_effectiveController == null || !_effectiveController!.hasClients) return;

    // Check if tap is on thumb
    if (tapPosition >= thumbOffset && tapPosition <= thumbOffset + thumbHeight) {
      return;
    }

    final tapPercentage = tapPosition / trackHeight;
    final targetOffset = tapPercentage * _effectiveController!.position.maxScrollExtent;

    _effectiveController!.animateTo(
      targetOffset.clamp(0.0, _effectiveController!.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _handleThumbDrag(double delta, double trackHeight, double thumbHeight) {
    if (_effectiveController == null || !_effectiveController!.hasClients) return;

    final scrollExtent = _effectiveController!.position.maxScrollExtent;
    final availableSpace = trackHeight - thumbHeight;

    if (availableSpace <= 0) return;

    final scrollDelta = (delta / availableSpace) * scrollExtent;
    final newOffset = (_effectiveController!.offset + scrollDelta).clamp(0.0, scrollExtent);

    _effectiveController!.jumpTo(newOffset);
  }
}
