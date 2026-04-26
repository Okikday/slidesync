import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_header/src/animated_shape.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_header/src/custom_wave_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class AnimatedShapeProgressWidget extends ConsumerStatefulWidget {
  const AnimatedShapeProgressWidget({
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

  @override
  ConsumerState<AnimatedShapeProgressWidget> createState() => _ProgressShapeAnimatedWidgetState();
}

class _ProgressShapeAnimatedWidgetState extends ConsumerState<AnimatedShapeProgressWidget> {
  final scaleClickNotifier = ValueNotifier<bool>(false);
  final List<RoundedPolygon> shapes = List.from(materialShapes.map((e) => e.shape));
  late final RoundedPolygon shape;
  @override
  void initState() {
    super.initState();
    shapes.shuffle();
    shape = shapes.first;
  }

  void updateScaleClick(bool newValue) => scaleClickNotifier.value = newValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        updateScaleClick(true);
      },
      onTapCancel: () {
        updateScaleClick(false);
      },
      onTapUp: (details) async {
        await Future.delayed(Durations.short2);
        updateScaleClick(false);
        if (widget.onClick != null) {
          widget.onClick!();
        }
      },
      child: ValueListenableBuilder(
        valueListenable: scaleClickNotifier,
        builder: (context, scaleClick, child) {
          return AnimatedScale(
            scale: scaleClick ? 1.1 : 1.0,
            duration: Durations.medium3,
            curve: CustomCurves.defaultIosSpring,
            child: child!,
          );
        },
        child: ClipRRect(
          child: MaterialShapedWidget(
            shape: shape,
            size: Size.square(widget.shapeSize),
            child: CustomShapeWaveFilledWidget(
              progress: widget.progress,
              waveColor: ref.primary.withAlpha(100),
              waveSize: Size.square(widget.shapeSize),
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ref.primaryColor),
              backgroundWidget: ColoredBox(
                color: ref.altBackgroundPrimary.withValues(alpha: .2),
                child: BuildImagePathWidget(
                  fileDetails: widget.fileDetails,
                  fallbackWidget: const SizedBox(),
                ).animate().fade(begin: 1.0, end: 0.15, duration: Durations.extralong1, curve: CustomCurves.decelerate),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
