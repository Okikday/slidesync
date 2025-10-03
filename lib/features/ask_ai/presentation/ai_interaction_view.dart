import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/ask_ai/domain/services/ai_gen_client.dart';
import 'package:slidesync/features/auth/domain/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

import 'package:uuid/uuid.dart';

final userIdProvider = FutureProvider<String>((ref) async {
  return (await UserDataFunctions().getUserDetails()).data?.userID ?? '';
});

class AiInteractionView extends ConsumerStatefulWidget {
  final ValueNotifier<Uint8List?> imageNotifier;
  const AiInteractionView({super.key, required this.imageNotifier});

  @override
  ConsumerState<AiInteractionView> createState() => _AiInteractionViewState();
}

class _AiInteractionViewState extends ConsumerState<AiInteractionView> {
  StreamSubscription<StringBuffer>? aiMessageSub;
  late final InMemoryChatController chatController;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    chatController = InMemoryChatController();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    chatController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return ref
        .watch(userIdProvider)
        .when(
          data: (userId) {
            return Chat(
              currentUserId: userId,

              resolveUser: (String id) async {
                return User(id: id);
              },
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                color: chatController.messages.isEmpty ? null : theme.background,
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
                  final aiTextStyle = TextStyle(color: theme.onSurface, fontSize: 13);
                  final userTextStyle = TextStyle(color: theme.onPrimary, fontSize: 13);
                  if (isSentByMe) {
                    return SelectionArea(
                      child: StreamingTextMarkdown(
                        text: message.text,
                        chunkSize: 4,
                        styleSheet: userTextStyle,
                        typingSpeed: Duration.zero,
                        fadeInDuration: Duration.zero,
                        latexStyle: userTextStyle,
                        latexEnabled: true,
                        animationsEnabled: false,
                      ),
                    );
                  } else {
                    if (message.text.trim().isEmpty) {
                      return LoadingLogo(color: theme.primary, rotate: false);
                    }
                    if (aiMessageSub != null && index == chatController.messages.length - 1) {
                      return StreamingTextMarkdown.claude(
                        text: message.text,

                        styleSheet: aiTextStyle,
                        latexStyle: aiTextStyle,
                        latexEnabled: true,
                        markdownEnabled: true,
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
                chatMessageBuilder:
                    (context, message, index, animation, child, {groupStatus, isRemoved, required isSentByMe}) {
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
                                    top: isFirst ? 12 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSentByMe ? null : theme.surface,
                                    gradient: isSentByMe
                                        ? LinearGradient(
                                            colors: [theme.primary, theme.secondary],
                                            stops: [0.8, 1],
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
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child:
                            Padding(
                                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20),
                                  child: CustomTextfield(
                                    autoDispose: false,
                                    controller: textEditingController,
                                    hint: "How may i assist you?",
                                    hintStyle: TextStyle(color: theme.onBackground.withValues(alpha: 0.6)),
                                    inputTextStyle: TextStyle(fontSize: 16),
                                    inputContentPadding: EdgeInsets.only(left: 12, bottom: 20, top: 20),
                                    backgroundColor: theme.background.lightenColor(ref.isDarkMode ? 0.2 : 0.8),
                                    maxLines: 4,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    alwaysShowSuffixIcon: true,
                                    onTapOutside: () {},
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 12.0),
                                      child: CustomElevatedButton(
                                        onClick: () async {
                                          if (aiMessageSub != null) return;
                                          final text = textEditingController.text;
                                          if (text.trim().isEmpty) return;
                                          textEditingController.clear();

                                          await Result.tryRunAsync(() async {
                                            // Insert user's message
                                            final userMessage = Message.text(
                                              id: Uuid().v4(),
                                              authorId: userId,
                                              text: text,
                                            );
                                            await chatController.insertMessage(userMessage);

                                            // Insert a placeholder for AI response
                                            final aiMessageId = Uuid().v4();
                                            final aiMessage = Message.text(id: aiMessageId, authorId: 'ai', text: '');
                                            chatController.insertMessage(aiMessage);
                                            final image = widget.imageNotifier.value;
                                            LinkedHashSet<Content> set = LinkedHashSet();
                                            for (int i = 0; i < chatController.messages.length; i++) {
                                              final curr = chatController.messages[i];
                                              final data = curr.toJson()['text'];
                                              set.add(Content.text(data ?? ''));
                                            }

                                            final allMessages = [
                                              ...(set.toList()),
                                              Content("User", [
                                                TextPart(text),
                                                if (image != null) InlineDataPart("image/png", image),
                                              ]),
                                            ];
                                            log("set: ${allMessages.first.parts.first.toJson()}");
                                            final stream = AiGenClient.instance.streamChatAnon(allMessages);
                                            final StringBuffer buffer = StringBuffer();
                                            aiMessageSub = stream.listen(
                                              (response) async {
                                                buffer.write(response);
                                                await chatController.updateMessage(
                                                  aiMessage,
                                                  Message.text(
                                                    id: aiMessageId,
                                                    authorId: 'ai',
                                                    text: response.toString(),
                                                  ),
                                                );
                                              },
                                              onDone: () async {
                                                await aiMessageSub?.cancel();
                                                setState(() {
                                                  aiMessageSub = null;
                                                });
                                              },
                                              onError: (e) async {
                                                await aiMessageSub?.cancel();
                                                setState(() {
                                                  aiMessageSub = null;
                                                });
                                              },
                                            );
                                          });
                                          if (context.mounted) FocusScope.of(context).unfocus();
                                        },
                                        shape: CircleBorder(),
                                        contentPadding: EdgeInsets.all(12.0),
                                        backgroundColor: Colors.white.withAlpha(20),
                                        child: Icon(
                                          Iconsax.send_2_copy,
                                          size: 22,
                                          color: context.isDarkMode ? Colors.white : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .scaleXY(begin: 0.8, end: 1.0, alignment: Alignment.bottomCenter)
                                .slideY(begin: -0.1, end: 0)
                                .fadeIn(duration: Durations.medium3),
                      ),
                    ),
                  );
                },
              ),
              chatController: chatController,
            );
          },
          error: (e, st) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [Icon(Icons.error_rounded, size: 64), CustomText("Couldn't verify user")],
            );
          },
          loading: () => LoadingLogo(size: 64, color: theme.primary),
        );
  }
}

String fixMarkdown(String text) {
  return text
      .replaceAll(r'\*\*', '**')
      .replaceAll(RegExp(r'\*\*\s*([^*\n]+?)\s*\*\*'), r'**$1**')
      .replaceAll('***', '**');
}
