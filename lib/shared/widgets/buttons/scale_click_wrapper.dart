import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/routes/transition.dart';

class ScaleClickWrapper extends ConsumerStatefulWidget {
  final double borderRadius;
  // default size, and then when clicked
  final (double from, double to) scaleBetween;
  final void Function(TapDownDetails details)? onTapDown;

  /// Can delay when calling onTapUp to delay when action takes place
  final void Function(TapUpDetails details)? onTapUp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration animationDuration;
  final Duration? delayReverseDuration;
  final Curve? curve;
  final Color? splashColor;
  final Color? overlayColor;
  final Widget child;
  final HitTestBehavior? behavior;
  const ScaleClickWrapper({
    super.key,
    this.scaleBetween = (1.0, 0.9),
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onLongPress,
    this.splashColor,
    this.overlayColor,
    this.animationDuration = Durations.medium2,
    this.delayReverseDuration,
    this.borderRadius = 0,
    this.behavior,
    this.curve,
    required this.child,
  });

  @override
  ConsumerState<ScaleClickWrapper> createState() => _ScaleClickWrapperState();
}

class _ScaleClickWrapperState extends ConsumerState<ScaleClickWrapper> {
  final ValueNotifier<bool> scaleClickNotifier = ValueNotifier(false);

  @override
  void dispose() {
    scaleClickNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: scaleClickNotifier,
      builder: (context, value, child) {
        return AnimatedScale(
          scale: value ? widget.scaleBetween.$2 : widget.scaleBetween.$1,
          duration: widget.animationDuration,
          curve: widget.curve ?? defaultCurve,
          child: _InnerScaleClickWrapper(
            scaleClickNotifier: scaleClickNotifier,
            borderRadius: widget.borderRadius,
            onTapDown: widget.onTapDown,
            onTapUp: widget.onTapUp,
            onTap: widget.onTap,
            delayReverseDuration: widget.delayReverseDuration,
            onLongPress: widget.onLongPress,
            behavior: widget.behavior,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _InnerScaleClickWrapper extends ConsumerWidget {
  const _InnerScaleClickWrapper({
    required this.scaleClickNotifier,
    this.borderRadius = 0,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onLongPress,
    this.delayReverseDuration,
    this.behavior,
    required this.child,
  });

  final ValueNotifier<bool> scaleClickNotifier;
  final double borderRadius;
  final void Function(TapDownDetails details)? onTapDown;
  final void Function(TapUpDetails details)? onTapUp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration? delayReverseDuration;
  final HitTestBehavior? behavior;
  final Widget child;

  void updateScaleClickNotifier(bool newValue) {
    if (scaleClickNotifier.value == newValue) return;
    scaleClickNotifier.value = newValue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(borderRadius),
      child: GestureDetector(
        behavior: behavior,
        onTapDown: (details) {
          updateScaleClickNotifier(true);
          if (onTapDown != null) onTapDown!(details);
        },
        onTapCancel: () {
          updateScaleClickNotifier(false);
        },
        onTapUp: (details) async {
          await Future.delayed(delayReverseDuration ?? Durations.short1);
          if (!context.mounted) return;
          updateScaleClickNotifier(false);
          if (onTapUp != null) onTapUp!(details);
        },
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTap: onLongPress,
        onSecondaryTapDown: (details) {
          updateScaleClickNotifier(true);
          if (onTapDown != null) onTapDown!(details);
        },
        onSecondaryTapCancel: () {
          updateScaleClickNotifier(false);
        },
        onSecondaryTapUp: (details) async {
          await Future.delayed(delayReverseDuration ?? Durations.short1);
          if (!context.mounted) return;
          updateScaleClickNotifier(false);
          if (onTapUp != null) onTapUp!(details);
        },
        child: child,
      ),
    );
  }
}
