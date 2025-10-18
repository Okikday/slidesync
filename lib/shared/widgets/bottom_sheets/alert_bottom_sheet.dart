import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AlertBottomSheet extends ConsumerWidget {
  final Size maxSize;
  final Widget child;
  const AlertBottomSheet({super.key, this.maxSize = const Size(300, 300), required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return  Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: Durations.medium2,
        constraints: BoxConstraints(maxHeight: maxSize.height, maxWidth: maxSize.width),
        margin: EdgeInsets.fromLTRB(20, 0, 20, context.bottomPadding),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withValues(alpha: 0.1))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: child,
      ).animate().fadeIn().scaleY(
        begin: 0.4,
        end: 1,
        alignment: Alignment.bottomRight,
        duration: Duration(milliseconds: 500),
        curve: CustomCurves.defaultIosSpring,
      ),
    );
  }
}