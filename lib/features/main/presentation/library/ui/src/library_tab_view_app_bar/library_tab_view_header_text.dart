import 'dart:math' as math;
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/library/logic/library_tab_provider.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

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

    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 20),
      child: Center(
        child: SizedBox(
          height: height,
          child: ValueListenableBuilder(
            valueListenable: ref.watch(LibraryTabProvider.state.select((s) => s.scrollOffsetNotifier)),
            builder: (context, offset, child) {
              final double percentScroll = (math.min(offset, allowedHeight) / allowedHeight);

              // Interpolate between center and centerLeft.
              final alignment = Alignment.lerp(Alignment.center, Alignment.centerLeft, percentScroll)!;
              return Align(
                alignment: alignment,
                child: Container(
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
                  child: CustomText(
                    title,
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(fontSize: lerpDouble(26, 20, percentScroll)),
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
