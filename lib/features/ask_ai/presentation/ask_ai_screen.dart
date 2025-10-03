import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/ask_ai/presentation/ai_interaction_view.dart';
import 'package:slidesync/features/content_viewer/presentation/controllers/doc_viewer_controllers/pdf_doc_viewer_controller.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';
import 'package:dotted_border/dotted_border.dart';

class AskAiScreen extends ConsumerStatefulWidget {
  const AskAiScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> {
  late final ValueNotifier<Uint8List?> imageNotifier;
  late final ValueNotifier<String?> aiResponseNotifier;
  late final TextEditingController textEditingController;
  bool isProcessing = false;
  @override
  void initState() {
    super.initState();
    imageNotifier = ValueNotifier(null);
    aiResponseNotifier = ValueNotifier(null);
    textEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => SystemChrome.setPreferredOrientations([]));
    imageNotifier.dispose();
    aiResponseNotifier.dispose();
    textEditingController.dispose();
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
            RepaintBoundary(child: OrganicBackgroundEffect(particleOpacity: 0.4, gradientOpacity: 0.1)),
            Positioned(
              top: (context.topPadding + 12) * 2,
              child: AiScreenCapture(imageNotifier: imageNotifier),
            ),
            SingleChildScrollView(
              child: SizedBox(
                width: context.deviceWidth,
                height: (context.deviceHeight * 0.7 + 24 - (context.viewInsets.bottom / 2)).clamp(100, double.infinity),
                child: AiInteractionView(imageNotifier: imageNotifier),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiScreenCapture extends ConsumerWidget {
  const AiScreenCapture({super.key, required this.imageNotifier});

  final ValueNotifier<Uint8List?> imageNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: imageNotifier,
      builder: (context, value, child) {
        if (value != null) {
          final size = context.deviceHeight * 0.15;
          return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: theme.background.withAlpha(10)),
                child: Image.memory(value),
              )
              .animate()
              .scaleXY(begin: 1.1, end: 1, duration: Durations.medium4, curve: CustomCurves.defaultIosSpring)
              .fadeIn();
        }
        return DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(8),
            color: theme.onBackground,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            strokeCap: StrokeCap.round,
          ),
          child: GestureDetector(
            onTap: () async {
              final pixelRatio = MediaQuery.devicePixelRatioOf(context);
              imageNotifier.value = await PdfDocViewerController.screenshotController.capture(pixelRatio: pixelRatio);
            },
            child: CustomText("Capture screen content behind"),
          ),
        );
      },
    );
  }
}
