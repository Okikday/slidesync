import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/ask_ai/providers/ask_ai_screen_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AiChatTextfield extends ConsumerStatefulWidget {
  const AiChatTextfield({super.key});

  @override
  ConsumerState<AiChatTextfield> createState() => _AiChatTextfieldState();
}

class _AiChatTextfieldState extends ConsumerState<AiChatTextfield> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> gradientAnimation;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    animationController.loop(reverse: true, count: 1);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return AnimatedBuilder(
          animation: gradientAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withValues(alpha: gradientAnimation.value),
                    theme.secondary.withValues(alpha: gradientAnimation.value),
                  ],
                  transform: GradientRotation(gradientAnimation.value * 2 * 3.14159),
                ),
              ),
              child: child,
            );
          },
          child: CustomTextfield(
            autoDispose: false,
            controller: ref.watch(AskAiScreenProvider.state.select((s) => s.aiFieldInputController)),
            hint: "How may i assist you?",
            hintStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
            inputTextStyle: TextStyle(fontSize: 16, color: theme.onSurface),
            inputContentPadding: EdgeInsets.only(left: 12, bottom: 20, top: 20),
            backgroundColor: theme.background.lightenColor(ref.isDarkMode ? 0.2 : 0.8),
            maxLines: 4,
            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(40)),
            alwaysShowSuffixIcon: true,
            onTapOutside: () {},
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CustomElevatedButton(
                pixelHeight: 48,
                onClick: () async {
                  await AskAiScreenProvider.state.read(ref).sendCurrContentToAi();
                  if (context.mounted) FocusScope.of(context).unfocus();
                },
                shape: CircleBorder(),
                contentPadding: EdgeInsets.all(12.0),
                backgroundColor: Colors.white.withAlpha(20),
                child: Icon(Iconsax.send_2_copy, size: 22, color: context.isDarkMode ? Colors.white : Colors.white),
              ),
            ),
          ),
        )
        .animate()
        .scaleXY(
          begin: 0.2,
          end: 1.0,
          alignment: Alignment.bottomRight,
          curve: CustomCurves.defaultIosSpring,
          duration: Durations.extralong2,
        )
        .slideY(begin: -0.1, end: 0, curve: CustomCurves.defaultIosSpring, duration: Durations.extralong2)
        .fadeIn(duration: Durations.medium3);
  }
}
