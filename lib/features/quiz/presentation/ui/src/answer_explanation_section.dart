import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:slidesync/features/quiz/presentation/logic/quiz_screen_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AnswerExplanationSection extends ConsumerWidget {
  final QuizScreenState state;

  const AnswerExplanationSection({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return ValueListenableBuilder<int>(
      valueListenable: state.currentQuestionIndexNotifier,
      builder: (context, currentIndex, _) {
        return ValueListenableBuilder<Map<int, bool>>(
          valueListenable: state.showAnswerNotifier,
          builder: (context, showAnswer, _) {
            final isShown = showAnswer[currentIndex] ?? false;
            if (!isShown) return const SizedBox.shrink();

            final question = state.shuffledQuestions[currentIndex];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.altBackgroundPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Correct Answer: ${question.getCorrectAnswerLetters()}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  if (question.explanation != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Explanation:',
                      style: TextStyle(
                        color: theme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MarkdownWidget(
                      data: question.explanation!,
                      config: MarkdownConfig(
                        configs: [
                          PConfig(
                            textStyle: TextStyle(
                              color: theme.onSurface.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (question.reference != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: theme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            question.reference!,
                            style: TextStyle(
                              color: theme.primary,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
