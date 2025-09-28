import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_details/course_details_header/animated_shape.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_details/course_details_header/custom_wave_widget.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/widgets/build_image_path_widget.dart';

class ProgressShapeAnimatedWidget extends ConsumerStatefulWidget {
  const ProgressShapeAnimatedWidget({
    super.key,
    required this.shapeSize,
    required this.progress,
    required this.fileDetails,
  });
  final double progress;
  final double shapeSize;
  final FileDetails fileDetails;

  @override
  ConsumerState<ProgressShapeAnimatedWidget> createState() => _ProgressShapeAnimatedWidgetState();
}

class _ProgressShapeAnimatedWidgetState extends ConsumerState<ProgressShapeAnimatedWidget> {
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
                  waveSize: Size.square(widget.shapeSize),
                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ref.primaryColor),
                  backgroundWidget:
                      BuildImagePathWidget(fileDetails: widget.fileDetails, fallbackWidget: const SizedBox())
                          .animate()
                          .fade(begin: 1.0, end: 0.15, duration: Durations.extralong1, curve: CustomCurves.decelerate),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
