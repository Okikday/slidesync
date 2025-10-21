import 'dart:collection';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';
import 'package:slidesync/features/ask_ai/presentation/logic/ask_ai_screen_provider.dart';
import 'package:slidesync/features/ask_ai/presentation/ui/widgets/ai_chat_textfield.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AiInteractionView extends ConsumerStatefulWidget {
  const AiInteractionView({super.key});

  @override
  ConsumerState<AiInteractionView> createState() => _AiInteractionViewState();
}

class _AiInteractionViewState extends ConsumerState<AiInteractionView> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final state = ref.watch(AskAiScreenProvider.state);
    final chatController = state.chatController;
    return Chat(
      currentUserId: ref.watch(AskAiScreenProvider.userIdProvider).value ?? "user",

      resolveUser: (String id) async => User(id: id),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        // color: ref.watch(AskAiScreenProvider.state).chatController.messages.isEmpty ? null : theme.background,
      ),
      builders: Builders(
        emptyChatListBuilder: (context) {
          return Center(
            child: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(dimension: 60, child: Image.asset("assets/logo/ic_foreground.png")),
                CustomText("AI Study assistant", style: TextStyle(color: theme.onBackground)),
                CustomText(
                  "Powered by Gemini\nAI responses may contain mistakes",
                  style: TextStyle(fontSize: 8, color: theme.onBackground),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        textMessageBuilder: (context, message, index, {groupStatus, required isSentByMe}) {
          final aiTextStyle = TextStyle(color: theme.onSurface, fontSize: 12, fontWeight: FontWeight.bold);
          final userTextStyle = TextStyle(color: theme.onPrimary, fontSize: 12.5, fontWeight: FontWeight.bold);
          if (isSentByMe) {
            return SelectionArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: CustomText(
                  message.text,
                  // chunkSize: 4,
                  style: userTextStyle,
                  // typingSpeed: Duration.zero,
                  // fadeInDuration: Duration.zero,
                  // latexStyle: userTextStyle,
                  // latexEnabled: true,
                  // animationsEnabled: false,
                ),
              ),
            );
          } else {
            if (index == chatController.messages.length - 1) {
              return ValueListenableBuilder<bool>(
                valueListenable: state.isProcessingNotifier,
                builder: (context, value, child) {
                  if (message.text.trim().isEmpty) {
                    return LoadingLogo(color: theme.primary, rotate: false);
                  }
                  return StreamingTextMarkdown.chatGPT(
                    text: message.text,

                    styleSheet: aiTextStyle,
                    latexStyle: aiTextStyle,
                    latexEnabled: true,
                    markdownEnabled: true,
                  );
                },
              );
            }
            return SelectionArea(
              child: StreamingTextMarkdown(
                text: message.text,
                styleSheet: aiTextStyle,
                typingSpeed: Duration.zero,
                fadeInDuration: Duration.zero,
                latexStyle: aiTextStyle,
                latexEnabled: true,
                markdownEnabled: true,
                animationsEnabled: false,
              ),
            );
          }
        },
        chatMessageBuilder: (context, message, index, animation, child, {groupStatus, isRemoved, required isSentByMe}) {
          final messages = chatController.messages;
          final hasPrev = index < 1 ? null : messages.elementAtOrNull(index - 1);
          final hasNext = messages.length > index + 1 ? messages.elementAtOrNull(index + 1) : null;
          final isSameNextUser = hasNext != null ? (hasNext.authorId == message.authorId) : false;
          bool isSamePrevUser = hasPrev != null ? hasPrev.authorId == message.authorId : false;
          final bool isLast = chatController.messages.length - 1 == index;
          final bool isFirst = index == 0;
          return Align(
            alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child:
                AnimatedContainer(
                      duration: Durations.extralong1,
                      curve: CustomCurves.defaultIosSpring,
                      margin: EdgeInsets.only(
                        bottom: isLast ? 60 : (isSamePrevUser || isSameNextUser ? 4 : 12),
                        right: 12,
                        left: isSentByMe ? 48 : 12,
                        top: isFirst ? 20 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isSentByMe ? null : theme.surface,
                        gradient: isSentByMe
                            ? LinearGradient(
                                colors: [theme.primary, theme.secondary],
                                stops: [0.9, 1],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.only(
                          topRight: isSentByMe
                              ? (isSamePrevUser ? Radius.circular(24) : Radius.circular(2))
                              : Radius.circular(24),
                          topLeft: isSentByMe
                              ? Radius.circular(24)
                              : (isSamePrevUser ? Radius.circular(24) : Radius.circular(2)),
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: child,
                    )
                    .animate()
                    .scaleX(
                      alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                      begin: 0.98,
                      end: 1,
                      duration: Durations.medium1,
                    )
                    .fadeIn(),
          );
        },
        composerBuilder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20), child: AiChatTextfield())
                .animate()
                .scaleXY(begin: 0.8, end: 1.0, alignment: Alignment.bottomCenter)
                .slideY(begin: -0.1, end: 0)
                .fadeIn(duration: Durations.medium3),
          );
        },
      ),
      chatController: chatController,
    );
  }
}

String fixMarkdown(String text) {
  return text
      .replaceAll(r'\*\*', '**')
      .replaceAll(RegExp(r'\*\*\s*([^*\n]+?)\s*\*\*'), r'**$1**')
      .replaceAll('***', '**');
}
