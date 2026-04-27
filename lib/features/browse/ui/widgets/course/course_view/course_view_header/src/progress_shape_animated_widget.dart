import 'dart:math' as math;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_header/src/animated_shape.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_header/src/custom_wave_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class AnimatedShapeProgressWidget extends ConsumerWidget {
  AnimatedShapeProgressWidget({
    super.key,
    required this.shapeSize,
    required this.progress,
    required this.fileDetails,
    this.onClick,
  });
  final double progress;
  final double shapeSize;
  final FilePath fileDetails;
  final void Function()? onClick;

  final shape = materialShapes[math.Random().nextInt(materialShapes.length)].shape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaleClickWrapper(
      scaleBetween: (1.0, 1.1),
      onTap: onClick,
      animationDuration: 500.inMs,
      curve: CustomCurves.defaultIosSpring,
      child: ClipRRect(
        child: MaterialShapedWidget(
          shape: shape,
          size: Size.square(shapeSize),
          child: CustomShapeWaveFilledWidget(
            progress: progress,
            waveColor: ref.primary.withAlpha(100),
            waveSize: Size.square(shapeSize),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ref.primaryColor),
            backgroundWidget: ColoredBox(
              color: ref.altBackgroundPrimary.withValues(alpha: .2),
              child: BuildImagePathWidget(
                fileDetails: fileDetails,
                fallbackWidget: const SizedBox(),
              ).animate().fade(begin: 1.0, end: 0.15, duration: Durations.extralong1, curve: CustomCurves.decelerate),
            ),
          ),
        ),
      ),
    );
  }
}
