import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:slidesync/features/ask_ai/domain/models/study_guide_prompt.dart';

class AiGenClient {
  static final AiGenClient instance = AiGenClient._();
  AiGenClient._();

  static GenerativeModel _model({String? model, Content? systemInstruction, bool useGoogleSearch = false}) =>
      FirebaseAI.googleAI().generativeModel(
        model: model ?? 'gemini-2.5-flash',
        tools: useGoogleSearch ? [Tool.googleSearch()] : null,
        systemInstruction: systemInstruction ?? Content.system(studyGuidePrompt),
      );

  /// Streams chat responses for anonymous conversations
  Stream<StringBuffer> streamChatAnon(List<Content> messages) {
    final model = _model();
    final buffer = StringBuffer();

    return model.generateContentStream(messages).map((response) {
      final text = response.text ?? '';
      buffer.write(text);
      return buffer;
    });
  }

  /// Gets a single chat response for anonymous conversations
  Future<String> chatAnon(List<Content> messages) async {
    final model = _model();
    final response = await model.generateContent(messages);
    return response.text ?? '';
  }
}
