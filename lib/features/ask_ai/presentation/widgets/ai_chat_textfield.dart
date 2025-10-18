import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AiChatTextfield extends ConsumerWidget {
  const AiChatTextfield({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return CustomTextfield(
      autoDispose: false,
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
          onClick: () async {
            // if (aiMessageSub != null) return;
            // final text = textEditingController.text;
            // if (text.trim().isEmpty) return;
            // textEditingController.clear();

            // await Result.tryRunAsync(() async {
            //   // Insert user's message
            //   final userMessage = Message.text(id: Uuid().v4(), authorId: userId, text: text);
            //   await chatController.insertMessage(userMessage);

            //   // Insert a placeholder for AI response
            //   final aiMessageId = Uuid().v4();
            //   final aiMessage = Message.text(id: aiMessageId, authorId: 'ai', text: '');
            //   chatController.insertMessage(aiMessage);
            //   final image = widget.imageNotifier.value;
            //   LinkedHashSet<Content> set = LinkedHashSet();
            //   for (int i = 0; i < chatController.messages.length; i++) {
            //     final curr = chatController.messages[i];
            //     final data = curr.toJson()['text'];
            //     set.add(Content.text(data ?? ''));
            //   }

            //   final allMessages = [
            //     ...(set.toList()),
            //     Content("User", [TextPart(text), if (image != null) InlineDataPart("image/png", image)]),
            //   ];
            //   log("set: ${allMessages.first.parts.first.toJson()}");
            //   final stream = AiGenClient.instance.streamChatAnon(allMessages);
            //   final StringBuffer buffer = StringBuffer();
            //   aiMessageSub = stream.listen(
            //     (response) async {
            //       buffer.write(response);
            //       await chatController.updateMessage(
            //         aiMessage,
            //         Message.text(id: aiMessageId, authorId: 'ai', text: response.toString()),
            //       );
            //     },
            //     onDone: () async {
            //       await aiMessageSub?.cancel();
            //       setState(() {
            //         aiMessageSub = null;
            //       });
            //     },
            //     onError: (e) async {
            //       await aiMessageSub?.cancel();
            //       setState(() {
            //         aiMessageSub = null;
            //       });
            //     },
            //   );
            // });
            // if (context.mounted) FocusScope.of(context).unfocus();
          },
          shape: CircleBorder(),
          contentPadding: EdgeInsets.all(12.0),
          backgroundColor: Colors.white.withAlpha(20),
          child: Icon(Iconsax.send_2_copy, size: 22, color: context.isDarkMode ? Colors.white : Colors.white),
        ),
      ),
    );
  }
}
