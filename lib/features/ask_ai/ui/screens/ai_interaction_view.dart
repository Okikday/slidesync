import 'dart:collection';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:slidesync/features/ask_ai/providers/ask_ai_screen_provider.dart';
import 'package:slidesync/features/ask_ai/ui/widgets/ai_chat_textfield.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

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
                CustomText(
                  "AI Study",
                  style: TextStyle(color: theme.onBackground, fontWeight: FontWeight.bold),
                ),
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
          final userTextStyle = TextStyle(color: theme.onPrimary, fontSize: 12.5, fontWeight: FontWeight.bold);

          if (isSentByMe) {
            return TextSelectionTheme(
              data: TextSelectionThemeData(
                cursorColor: Colors.blue.withAlpha(100),
                selectionColor: Colors.blue.withAlpha(100),
                selectionHandleColor: theme.secondary,
              ),
              child: SelectionArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: CustomText(message.text, style: userTextStyle),
                ),
              ),
            );
          }

          final isLastMessage = index == chatController.messages.length - 1;

          if (message.text.trim().isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LoadingLogo(color: theme.primary, rotate: false),
            );
          }

          final isStreaming = isLastMessage && state.isProcessingNotifier.value;

          return buildAiMessageContent(
            text: message.text,
            isSentByMe: isSentByMe,
            primaryColor: theme.primary,
            onSurfaceColor: theme.onSurface,
            onPrimaryColor: theme.onPrimary,
            isStreaming: isStreaming,
          );
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
                        bottom: isLast ? 72 : (isSamePrevUser || isSameNextUser ? 4 : 12),
                        right: 12,
                        left: isSentByMe ? 48 : 12,
                        top: isFirst ? 20 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isSentByMe ? theme.primary : theme.surface,
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
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20),
              child: const AiChatTextfield(),
            ),
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

// Add to pubspec.yaml:
// markdown_widget: ^2.3.2+6

Widget buildAiMessageContent({
  required String text,
  required bool isSentByMe,
  required Color primaryColor,
  required Color onSurfaceColor,
  required Color onPrimaryColor,
  required bool isStreaming,
}) {
  if (isSentByMe) {
    // User messages - simple text
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SelectionArea(
        child: CustomText(
          text,
          style: TextStyle(color: onPrimaryColor, fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // AI messages - markdown with streaming support
  if (text.trim().isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
    );
  }

  return SelectionArea(
    child: MarkdownWidget(
      data: text,
      shrinkWrap: true,
      selectable: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      config: _buildMarkdownConfig(
        onSurfaceColor: onSurfaceColor,
        primaryColor: primaryColor,
        isStreaming: isStreaming,
      ),
      markdownGenerator: latexMarkdownGenerator(),
    ),
  );
}

MarkdownConfig _buildMarkdownConfig({
  required Color onSurfaceColor,
  required Color primaryColor,
  required bool isStreaming,
}) {
  final textStyle = TextStyle(color: onSurfaceColor, fontSize: 13, fontWeight: FontWeight.w500, height: 1.5);

  return MarkdownConfig(
    configs: [
      // Paragraph config
      PConfig(textStyle: textStyle),

      // Heading configs
      H1Config(style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
      H2Config(style: textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
      H3Config(style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
      H4Config(style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
      H5Config(style: textStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
      H6Config(style: textStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),

      // Code block config
      PreConfig(
        textStyle: textStyle.copyWith(fontFamily: 'monospace', fontSize: 12),
        decoration: BoxDecoration(color: onSurfaceColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Inline code config
      CodeConfig(
        style: textStyle.copyWith(
          fontFamily: 'monospace',
          fontSize: 12,
          backgroundColor: onSurfaceColor.withValues(alpha: 0.1),
        ),
      ),

      // Blockquote config
      BlockquoteConfig(
        // blockStyle: textStyle.copyWith(
        //   fontStyle: FontStyle.italic,
        // ),
        sideColor: primaryColor,
        textColor: onSurfaceColor.withValues(alpha: 0.8),
      ),

      // Link config
      LinkConfig(
        style: textStyle.copyWith(color: primaryColor, decoration: TextDecoration.underline),
      ),

      // // List configs
      // UlConfig(
      //   marker: '•',
      //   textStyle: textStyle,
      // ),
      // Config(
      //   textStyle: textStyle,
      // ),

      // Table config
      TableConfig(
        bodyStyle: textStyle,
        headerStyle: textStyle.copyWith(fontWeight: FontWeight.bold),
        border: TableBorder.all(color: onSurfaceColor.withValues(alpha: 0.2), width: 1),
      ),

      // Horizontal rule config
      HrConfig(
        color: onSurfaceColor.withValues(alpha: 0.2),
        height: 1,
        // margin: const EdgeInsets.symmetric(vertical: 12),
      ),

      // // Strong (bold) text
      // StrongConfig(
      //   style: textStyle.copyWith(fontWeight: FontWeight.bold),
      // ),

      // // Emphasis (italic) text
      // EmConfig(
      //   style: textStyle.copyWith(fontStyle: FontStyle.italic),
      // ),

      // // Deleted (strikethrough) text
      // DelConfig(
      //   style: textStyle.copyWith(
      //     decoration: TextDecoration.lineThrough,
      //   ),
      // ),
    ],
  );
}

// Example usage in your textMessageBuilder:
Widget textMessageBuilder(BuildContext context, message, int index, bool isSentByMe, WidgetRef ref, bool isStreaming) {
  final theme = ref.theme; // Your theme provider

  return buildAiMessageContent(
    text: message.text,
    isSentByMe: isSentByMe,
    primaryColor: theme.primary,
    onSurfaceColor: theme.onSurface,
    onPrimaryColor: theme.onPrimary,
    isStreaming: isStreaming,
  );
}

class InlineLatexSyntax extends m.InlineSyntax {
  InlineLatexSyntax() : super(r'\$([^\$\n]+?)\$');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final latex = match.group(1)!;
    parser.addNode(m.Element.text('latex-inline', latex));
    return true;
  }
}

/// Custom syntax to detect block LaTeX: $$...$$
class BlockLatexSyntax extends m.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\$\$\s*$');

  @override
  m.Node? parse(m.BlockParser parser) {
    parser.advance();
    final lines = <String>[];

    while (!parser.isDone) {
      final line = parser.current;
      if (line.content == r'$$') {
        parser.advance();
        break;
      }
      lines.add(line.content);
      parser.advance();
    }

    final latex = lines.join('\n');
    return m.Element('latex-block', [m.Text(latex)]);
  }
}

/// Widget builder for inline LaTeX
class InlineLatexNode extends SpanNode {
  final String latex;
  @override
  final TextStyle? style;

  InlineLatexNode(this.latex, {this.style});

  @override
  InlineSpan build() {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Math.tex(
        latex,
        textStyle: style,
        mathStyle: MathStyle.text,
        onErrorFallback: (error) {
          // Fallback to showing the raw LaTeX if parsing fails
          return Text('\$$latex\$', style: style?.copyWith(color: Colors.red));
        },
      ),
    );
  }
}

/// Widget builder for block LaTeX
class BlockLatexNode extends ElementNode {
  final String latex;
  final MarkdownConfig config;

  BlockLatexNode(this.latex, this.config);
}

/// Generator for inline LaTeX nodes
SpanNodeGeneratorWithTag inlineLatexGenerator = SpanNodeGeneratorWithTag(
  tag: 'latex-inline',
  generator: (e, config, visitor) {
    final latex = e.textContent;
    return InlineLatexNode(latex, style: config.p.textStyle);
  },
);

/// Generator for block LaTeX nodes
SpanNodeGeneratorWithTag blockLatexGenerator = SpanNodeGeneratorWithTag(
  tag: 'latex-block',
  generator: (e, config, visitor) {
    final latex = e.textContent;
    return BlockLatexNode(latex, config);
  },
);

/// Helper function to create a MarkdownGenerator with LaTeX support
MarkdownGenerator latexMarkdownGenerator() {
  return MarkdownGenerator(
    generators: [inlineLatexGenerator, blockLatexGenerator],
    inlineSyntaxList: [InlineLatexSyntax()],
    blockSyntaxList: [BlockLatexSyntax()],
  );
}

// String preprocessLatex(String markdown) {
//   final latexMap = <String, String>{};
//   int counter = 0;

//   // Replace inline LaTeX with placeholders
//   final processed = markdown.replaceAllMapped(RegExp(r'\$([^\$\n]+?)\$'), (match) {
//     final placeholder = '___LATEX_INLINE_${counter}___';
//     latexMap[placeholder] = match.group(1)!;
//     counter++;
//     return placeholder;
//   });

//   return processed;
// }
