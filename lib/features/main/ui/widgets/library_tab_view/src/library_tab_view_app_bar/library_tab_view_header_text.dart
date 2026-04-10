import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/animations/animated_sizing.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

class LibraryTabViewHeaderText extends ConsumerWidget {
  const LibraryTabViewHeaderText({super.key, this.title = "Your Library"});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final bgColor = theme.surface;
    final onBackground = theme.onBackground;
    final textStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: onBackground);
    final allowedHeight = libraryAppBarMaxHeight - libraryAppBarMinHeight;
    final topPadding = context.topPadding;
    final height = math.max(0.0, allowedHeight - topPadding);

    final scrollOffsetListenable = MainProvider.library.link(ref).scrollOffset;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 20),
      child: Center(
        child: SizedBox(
          height: height,
          child: AbsorberWatch(
            listenable: scrollOffsetListenable,
            builder: (context, offset, ref, child) {
              final percentScroll = (math.min(offset, allowedHeight) / allowedHeight);
              final completeScroll = percentScroll == 1.0;

              // Interpolate between center and centerLeft.
              final alignment = Alignment.lerp(Alignment.center, Alignment.centerLeft, percentScroll)!;
              return Align(
                alignment: alignment,
                child: AnimatedContainer(
                  duration: 100.inMs,
                  curve: Curves.decelerate,
                  constraints: BoxConstraints(maxHeight: 48),
                  clipBehavior: Clip.hardEdge,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: lerpDouble(0.0, 0.75, percentScroll)),
                    border: Border.fromBorderSide(
                      BorderSide(color: onBackground.withValues(alpha: lerpDouble(0.0, 0.04, percentScroll))),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AnimatedSizing.fast(
                    child: CustomText(
                      completeScroll ? "Library" : title,
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(fontSize: lerpDouble(26, 20, percentScroll)),
                    ).animate(key: ValueKey(completeScroll)).blurXY(begin: 1.0, end: 0),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

double snapToPhysical(BuildContext context, double logical) {
  final dpr = MediaQuery.devicePixelRatioOf(context);
  return (logical * dpr).round() / dpr;
}
