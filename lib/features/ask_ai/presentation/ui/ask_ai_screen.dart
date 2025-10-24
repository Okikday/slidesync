import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/ask_ai/presentation/ui/ai_interaction_view.dart';
import 'package:slidesync/features/ask_ai/presentation/ui/widgets/ai_screen_capture_button.dart';
import 'package:slidesync/features/ask_ai/presentation/ui/widgets/shimmery_gradient_background.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AskAiScreen extends ConsumerStatefulWidget {
  final String contentId;
  const AskAiScreen({super.key, required this.contentId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> gradientAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    animationController.loop(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      // Future.microtask(
      //   () async => ref.read(PdfDocViewerProvider.state(widget.contentId)).setAppBarVisible(false),
      // );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => SystemChrome.setPreferredOrientations([]));
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = ref;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ShimmeryGradientBackground(gradientAnimation: gradientAnimation),
            Positioned(top: 24, right: 12, child: CloseButton()),
            Positioned(top: (context.topPadding + 12) * 2, child: const AiScreenCaptureButton()),
            SingleChildScrollView(
              child: SizedBox(
                width: context.deviceWidth,
                height: (context.deviceHeight * 0.7 + 24 - (context.viewInsets.bottom / 2)).clamp(100, double.infinity),
                child: const AiInteractionView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
