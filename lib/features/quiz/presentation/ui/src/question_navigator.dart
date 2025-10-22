import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/quiz/presentation/logic/quiz_screen_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class QuestionNavigator extends ConsumerWidget {
  final QuizScreenState state;

  const QuestionNavigator({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Container(
      height: 60,
      color: theme.altBackgroundPrimary,
      child: ValueListenableBuilder<int>(
        valueListenable: state.currentQuestionIndexNotifier,
        builder: (context, currentIndex, _) {
          return ValueListenableBuilder<Map<int, List<int>>>(
            valueListenable: state.selectedAnswersNotifier,
            builder: (context, selectedAnswers, _) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: state.shuffledQuestions.length,
                itemBuilder: (context, index) {
                  final isAnswered = selectedAnswers.containsKey(index) && selectedAnswers[index]!.isNotEmpty;
                  final isCurrent = index == currentIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => state.goToQuestion(index),
                      child: Container(
                        width: 44,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? theme.primary
                              : isAnswered
                              ? theme.secondary.withValues(alpha: 0.2)
                              : theme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent ? theme.primary : theme.onSurface.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? theme.onPrimary : theme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
