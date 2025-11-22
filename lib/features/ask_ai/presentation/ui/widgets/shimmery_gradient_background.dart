import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ShimmeryGradientBackground extends ConsumerStatefulWidget {
  const ShimmeryGradientBackground({super.key});

  @override
  ConsumerState<ShimmeryGradientBackground> createState() => _ShimmeryGradientBackgroundState();
}

class _ShimmeryGradientBackgroundState extends ConsumerState<ShimmeryGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> gradientAnimation;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    animationController.loop(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final firstColor = theme.primary.withValues(alpha: 0.4);
    final midColor = Colors.transparent;
    final secondColor = theme.secondary.withValues(alpha: 0.4);
    final extraColor = Colors.lime.withValues(alpha: 0.4);
    return AnimatedBuilder(
      animation: gradientAnimation,
      child: const SizedBox.expand(),
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.4, 0.5, 0.7, 1.0],
              colors: [firstColor, midColor, extraColor, secondColor],
              transform: GradientRotation(gradientAnimation.value * math.pi),
            ),
          ),
          child: child,
        );
      },
    );
  }
}
