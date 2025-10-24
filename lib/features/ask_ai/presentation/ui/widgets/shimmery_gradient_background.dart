import 'package:flutter/material.dart';

class ShimmeryGradientBackground extends StatelessWidget {
  const ShimmeryGradientBackground({super.key, required this.gradientAnimation});

  final Animation<double> gradientAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientAnimation,
      child: const SizedBox.expand(),
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // stops: [0.2, 0.8, 1.0],
              colors: [Colors.blue.withAlpha(100), Colors.lime.withAlpha(50), Colors.purple.withAlpha(100)],
              transform: GradientRotation(gradientAnimation.value),
            ),
          ),
          child: child,
        );
      },
    );
  }
}
