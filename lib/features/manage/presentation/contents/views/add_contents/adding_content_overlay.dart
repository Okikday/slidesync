
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class LoadingOverlay extends ConsumerWidget {
  final double? progress;
  final String? message;
  const LoadingOverlay({super.key, this.progress, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final loadingCard = ClipRSuperellipse(
      borderRadius: BorderRadius.circular(44),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(color: theme.altBackgroundPrimary),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 40,
        constraints: BoxConstraints(maxWidth: 200),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            CustomText(message ?? "Loading", fontSize: 10, fontWeight: FontWeight.bold, color: theme.supportingText),
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
          Positioned(
            top: context.topPadding + kToolbarHeight + 20,
            left: 16,
            child: Draggable(feedback: loadingCard, childWhenDragging: const SizedBox(), child: loadingCard),
          ),
        ],
      ).animate().fadeIn().slideX(begin: -1, curve: CustomCurves.defaultIosSpring, duration: Durations.extralong1),
    );
  }
}
