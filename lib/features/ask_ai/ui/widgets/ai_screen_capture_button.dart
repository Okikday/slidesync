import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/ask_ai/providers/ask_ai_screen_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AiScreenCaptureButton extends ConsumerWidget {
  const AiScreenCaptureButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: ref.watch(AskAiScreenProvider.state.select((s) => s.imageToAiNotifier)),
      builder: (context, value, child) {
        if (value != null) {
          final size = context.deviceHeight * 0.15;
          return GestureDetector(
            onTap: () {
              CustomDialog.show(
                context,
                barrierColor: Colors.black.withAlpha(150),
                transitionType: TransitionType.download,
                curve: CustomCurves.defaultIosSpring,
                transitionDuration: Durations.extralong1,
                child: GestureDetector(
                  onTap: () => CustomDialog.hide(context),
                  child: SizedBox.expand(
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.memory(value, width: context.deviceWidth * 0.9),
                    ),
                  ),
                ),
              );
            },
            onLongPress: () => AskAiScreenProvider.state.read(ref).imageToAiNotifier.value = null,
            onDoubleTap: () => AskAiScreenProvider.state.read(ref).imageToAiNotifier.value = null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4.0,
              children: [
                Container(
                      height: size,
                      decoration: BoxDecoration(color: theme.background.withAlpha(10)),
                      child: Image.memory(value),
                    )
                    .animate()
                    .scaleXY(begin: 1.1, end: 1, duration: Durations.medium4, curve: CustomCurves.defaultIosSpring)
                    .fadeIn(),
                CustomText(
                  "Long press to clear selection",
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: ref.onBackground,
                ),
              ],
            ),
          );
        }
        return GestureDetector(
          onTap: () async {
            final state = AskAiScreenProvider.state.read(ref);
            final hasImage = state.imageToAiNotifier.value != null;
            if (!hasImage) {
              await state.captureCurrentView(context);
            }
          },
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(8),
              color: theme.onBackground,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              strokeCap: StrokeCap.round,
            ),
            child: CustomText("Capture screen context"),
          ),
        );
      },
    );
  }
}
