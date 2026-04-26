import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class LoadingOverlay extends ConsumerStatefulWidget {
  final double? progress;
  final String? message;
  final void Function(WidgetRef ref)? onCancel;

  const LoadingOverlay({super.key, this.progress, this.message, this.onCancel});

  @override
  ConsumerState<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends ConsumerState<LoadingOverlay> {
  bool _showCancelBar = false;
  bool _isOverCancel = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    final loadingCard = ClipRRect(
      borderRadius: BorderRadius.circular(44),
      child: Container(
        decoration: BoxDecoration(color: theme.adjustBgAndPrimaryWithLerpExtra.withAlpha(200)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                widget.message ?? "Loading",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.onBackground),
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: theme.primaryColor),
            ),
          ],
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // =======================
          // Cancel Bar (bottom)
          // =======================
          if (_showCancelBar)
            Align(
              alignment: Alignment.bottomCenter,
              child: DragTarget<int>(
                onWillAcceptWithDetails: (_) {
                  setState(() => _isOverCancel = true);
                  return true;
                },
                onLeave: (_) => setState(() => _isOverCancel = false),
                onAcceptWithDetails: (_) {
                  widget.onCancel?.call(ref);
                  setState(() {
                    _isOverCancel = false;
                    _showCancelBar = false;
                  });
                },
                builder: (context, _, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isOverCancel ? Colors.red.withValues(alpha: 0.9) : Colors.red.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Release to cancel",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),

          // =======================
          // Draggable Card
          // =======================
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            left: 16,
            child: LongPressDraggable<int>(
              data: 1,
              feedback: loadingCard,
              childWhenDragging: const SizedBox(),
              onDragStarted: () => setState(() => _showCancelBar = true),
              onDragEnd: (_) => setState(() => _showCancelBar = false),
              child: loadingCard,
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: -1, curve: Curves.easeOutBack, duration: const Duration(milliseconds: 600)),
    );
  }
}
