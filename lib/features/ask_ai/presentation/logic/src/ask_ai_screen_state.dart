import 'dart:async';
import 'dart:collection';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/ask_ai/domain/services/ai_gen_client.dart';
import 'package:slidesync/features/ask_ai/presentation/logic/ask_ai_screen_provider.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:uuid/uuid.dart';

class AskAiScreenState extends LeakPrevention with ValueNotifierFactoryMixin {
  ///|
  ///|
  /// ===================================================================================================
  /// VARIABLES
  /// ===================================================================================================
  final Ref ref;
  late final ValueNotifier<Uint8List?> imageToAiNotifier;
  late final ValueNotifier<String?> aiResponseNotifier;
  late final TextEditingController aiFieldInputController;
  late final ValueNotifier<bool> isProcessingNotifier;

  LinkedHashSet<Content> aiChatHistory = LinkedHashSet();
  StreamSubscription<StringBuffer>? aiMessageSub;
  late final InMemoryChatController chatController;

  ///|
  ///|
  /// ===================================================================================================
  /// DISPOSAL
  /// ===================================================================================================

  @override
  void onDispose() {
    disposeNotifiers();
    aiFieldInputController.dispose();
    chatController.dispose();
  }

  ///|
  ///|
  /// ===================================================================================================
  /// INIT
  /// ===================================================================================================
  AskAiScreenState(this.ref) {
    imageToAiNotifier = useValueNotifier(null);
    aiResponseNotifier = useValueNotifier(null);
    isProcessingNotifier = useValueNotifier(false);
    aiFieldInputController = TextEditingController();
    chatController = InMemoryChatController();
  }

  Future<void> sendCurrContentToAi() async {
    if (isProcessingNotifier.value) return;
    final text = aiFieldInputController.text;
    if (text.trim().isEmpty) return;
    aiFieldInputController.clear();

    await Result.tryRunAsync(() async {
      aiMessageSub?.cancel();
      final userId = await ref.read(AskAiScreenProvider.userIdProvider.future);
      // Insert user's message
      final userMessage = Message.text(id: Uuid().v4(), authorId: userId, text: text);
      await chatController.insertMessage(userMessage);

      // Insert a placeholder for AI response
      final aiMessageId = Uuid().v4();

      final image = imageToAiNotifier.value;

      final aiMessage = Message.text(id: aiMessageId, authorId: 'ai', text: '');
      chatController.insertMessage(aiMessage);

      if (aiChatHistory.where((c) => true).whereType<InlineDataPart>().isNotEmpty) {
        imageToAiNotifier.value = null;
      }
      final newContent = Content("User", [
        TextPart(text),
        if (imageToAiNotifier.value != null && image != null) InlineDataPart("image/png", image),
      ]);
      aiChatHistory.add(newContent);
      final allMessages = aiChatHistory.toList();

      final stream = AiGenClient.instance.streamChatAnon(allMessages);
      final StringBuffer buffer = StringBuffer();
      aiMessageSub = stream.listen(
        (response) async {
          buffer.write(response);
          await chatController.updateMessage(
            aiMessage,
            Message.text(id: aiMessageId, authorId: 'ai', text: response.toString()),
          );
        },
        onDone: () async {
          await aiMessageSub?.cancel();
          aiMessageSub = null;
          isProcessingNotifier.value = false;
        },
        onError: (e) async {
          await aiMessageSub?.cancel();
          aiMessageSub = null;
          isProcessingNotifier.value = false;
        },
      );
    });
    isProcessingNotifier.value = false;
  }

  Future<void> captureCurrentView(BuildContext context) async {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final capture = await PdfDocViewerState.screenshotController.capture(pixelRatio: pixelRatio);
    imageToAiNotifier.value = capture;
  }

  void clearCurrentCapture() => imageToAiNotifier.value = null;

  // Future<bool> sendImageToServer() async {
  //   final isSupabaseInitialized = Supabase.instance.isInitialized;
  //   log("isSupabaseInitialized: $isSupabaseInitialized");
  //   if (!isSupabaseInitialized) return false;
  //   log("Sending request");
  //   await GlobalNav.withContextAsync((c) async => await captureCurrentView(c));
  //   final buckets = await Supabase.instance.client.storage
  //       .from("ai_resources")
  //       .uploadBinary("image", imageToAiNotifier.value!);
  //   log("buckets: ${buckets.toString()}");
  //   return true;
  // }
}
