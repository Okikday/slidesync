import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:slidesync/features/quiz/providers/quiz_screen_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class QuestionSection extends ConsumerWidget {
  final QuizScreenState state;

  const QuestionSection({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return ValueListenableBuilder<int>(
      valueListenable: state.currentQuestionIndexNotifier,
      builder: (context, currentIndex, _) {
        final question = state.shuffledQuestions[currentIndex];

        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Question ${currentIndex + 1}/${state.shuffledQuestions.length}',
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (question.correctAnswers.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Multiple Answers',
                        style: TextStyle(
                          color: theme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: MarkdownWidget(
                  data: question.question,
                  config: MarkdownConfig(
                    configs: [
                      PConfig(
                        textStyle: TextStyle(color: theme.onSurface, fontSize: 16, fontFamily: theme.fontFamily),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
