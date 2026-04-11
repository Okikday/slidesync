import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/ask_ai/logic/services/ai_gen_client.dart';
import 'package:slidesync/features/ask_ai/providers/ask_ai_screen_provider.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:uuid/uuid.dart';

class AskAiViewState {
  final Uint8List? imageToAi;
  final bool isGenerating;

  const AskAiViewState({this.imageToAi, this.isGenerating = false});

  AskAiViewState copyWith({Uint8List? imageToAi, bool? isGenerating}) {
    return AskAiViewState(imageToAi: imageToAi ?? this.imageToAi, isGenerating: isGenerating ?? this.isGenerating);
  }

  @override
  bool operator ==(covariant AskAiViewState other) {
    if (identical(this, other)) return true;

    return other.imageToAi == imageToAi && other.isGenerating == isGenerating;
  }

  @override
  int get hashCode => Object.hash(imageToAi, isGenerating);
}

class AskAiScreenNotifier extends Notifier<AskAiViewState> {
  final TextEditingController aiFieldInputController = TextEditingController();
  final InMemoryChatController chatController = InMemoryChatController();
  final LinkedHashSet<Content> _aiChatHistory = LinkedHashSet();
  StreamSubscription<bool>? _aiMessageSub;
  bool _containsImage = false;

  @override
  AskAiViewState build() {
    ref.onDispose(_dispose);
    return const AskAiViewState();
  }

  void _dispose() {
    _aiMessageSub?.cancel();
    aiFieldInputController.dispose();
    chatController.dispose();
  }

  void clearCurrentCapture() {
    state = state.copyWith(imageToAi: null);
  }

  Future<void> sendCurrContentToAi() async {
    if (state.isGenerating) return;
    final text = aiFieldInputController.text;
    if (text.trim().isEmpty) return;
    aiFieldInputController.clear();

    await Result.tryRunAsync(() async {
      await _aiMessageSub?.cancel();
      final userId = await ref.read(AskAiScreenProvider.userIdProvider.future);

      final userMessage = Message.text(id: Uuid().v4(), authorId: userId, text: text);
      await chatController.insertMessage(userMessage);

      final aiMessageId = Uuid().v4();
      final aiMessage = Message.text(id: aiMessageId, authorId: 'ai', text: '');
      chatController.insertMessage(aiMessage);

      final image = state.imageToAi;

      final newUserContent = Content("user", [
        TextPart(text),
        if (image != null && !_containsImage) DataPart("image/png", image),
      ]);
      if (image != null) _containsImage = true;
      _aiChatHistory.add(newUserContent);

      // Get all messages for the request
      final allMessages = _aiChatHistory.toList();
      final buffer = StringBuffer();
      int failTimes = 0;
      final stream = AiGenClient.instance.streamChatAnon(buffer, messages: allMessages);

      _aiMessageSub = stream.listen(
        (response) async {
          if (!response) failTimes++;
          await chatController.updateMessage(
            aiMessage,
            Message.text(id: aiMessageId, authorId: 'ai', text: buffer.toString()),
          );
        },
        onDone: () async {
          final aiContent = Content("model", [TextPart(buffer.toString())]);
          _aiChatHistory.add(aiContent);
          await _aiMessageSub?.cancel();
          _aiMessageSub = null;
          state = state.copyWith(isGenerating: false);
          log("number of fails: $failTimes");
        },
        onError: (e) async {
          if (_aiChatHistory.isNotEmpty) {
            _aiChatHistory.remove(_aiChatHistory.last);
          }
          await _aiMessageSub?.cancel();
          _aiMessageSub = null;
          state = state.copyWith(isGenerating: false);
          log("number of fails: $failTimes");
        },
      );
    });
    state = state.copyWith(isGenerating: false);
  }

  Future<void> captureCurrentView(BuildContext context) async {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final capture = await PdfDocViewerState.screenshotController.capture(pixelRatio: pixelRatio);
    state = state.copyWith(imageToAi: capture);
  }
}
