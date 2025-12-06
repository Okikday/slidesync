import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_header/animated_shape.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_header/custom_wave_widget.dart';
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
  final FileDetails fileDetails;
  final void Function()? onClick;

  @override
  ConsumerState<AnimatedShapeProgressWidget> createState() => _ProgressShapeAnimatedWidgetState();
}

class _ProgressShapeAnimatedWidgetState extends ConsumerState<AnimatedShapeProgressWidget> {
  late final NotifierProvider<BoolNotifier, bool> scaleClickProvider;
  final List<RoundedPolygon> shapes = List.from(materialShapes.map((e) => e.shape));
  late final RoundedPolygon shape;
  @override
  void initState() {
    super.initState();
    scaleClickProvider = NotifierProvider<BoolNotifier, bool>(BoolNotifier.new, isAutoDispose: true);
    shapes.shuffle();
    shape = shapes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        updateScaleClickProvider(bool newValue) => ref.read(scaleClickProvider.notifier).update((cb) => newValue);
        return GestureDetector(
          onTapDown: (details) {
            updateScaleClickProvider(true);
          },
          onTapCancel: () {
            updateScaleClickProvider(false);
          },
          onTapUp: (details) async {
            await Future.delayed(Durations.short2);
            updateScaleClickProvider(false);
            if (widget.onClick != null) {
              widget.onClick!();
            }
          },
          child: AnimatedScale(
            scale: ref.watch(scaleClickProvider) ? 1.1 : 1.0,
            duration: Durations.medium3,
            curve: CustomCurves.defaultIosSpring,
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
                    child: BuildImagePathWidget(fileDetails: widget.fileDetails, fallbackWidget: const SizedBox())
                        .animate()
                        .fade(begin: 1.0, end: 0.15, duration: Durations.extralong1, curve: CustomCurves.decelerate),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
