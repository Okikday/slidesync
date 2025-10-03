import 'dart:math' as math;
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/library_tab_controller.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class LibraryTabViewHeaderText extends ConsumerWidget {
  const LibraryTabViewHeaderText({super.key, this.title = "Your Library"});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: ref.onBackground);
    final allowedHeight = libraryAppBarMaxHeight - libraryAppBarMinHeight;
    final topPadding = context.topPadding;
    final height = math.max(0.0, allowedHeight - topPadding);

    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 20),
      child: Center(
        child: SizedBox(
          height: height,
          child: Consumer(
            builder: (context, ref, child) {
              final offset = ref.watch(LibraryTabController.scrollOffsetProvider);
              final double percentScroll = (math.min(offset, allowedHeight) / allowedHeight);

              // Interpolate between center and centerLeft.
              final alignment = Alignment.lerp(Alignment.center, Alignment.centerLeft, percentScroll)!;
              return Align(
                alignment: alignment,
                child: CustomText(
                  title,
                  textAlign: TextAlign.center,
                  style: textStyle.copyWith(fontSize: lerpDouble(26, 20, percentScroll)),
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
