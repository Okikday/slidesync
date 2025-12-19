import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/quiz/providers/quiz_screen_state.dart';
import 'package:slidesync/features/quiz/ui/widgets/option_tile.dart';

class OptionsSection extends ConsumerWidget {
  final QuizScreenState state;

  const OptionsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = ref;

    return ValueListenableBuilder<int>(
      valueListenable: state.currentQuestionIndexNotifier,
      builder: (context, currentIndex, _) {
        final question = state.shuffledQuestions[currentIndex];
        final isMultiple = question.correctAnswers.length > 1;

        return ValueListenableBuilder<Map<int, List<int>>>(
          valueListenable: state.selectedAnswersNotifier,
          builder: (context, selectedAnswers, _) {
            final currentSelections = selectedAnswers[currentIndex] ?? [];

            return ValueListenableBuilder<Map<int, bool>>(
              valueListenable: state.showAnswerNotifier,
              builder: (context, showAnswer, _) {
                final isAnswerShown = showAnswer[currentIndex] ?? false;

                return Column(
                  children: List.generate(question.options.length, (index) {
                    final isSelected = currentSelections.contains(index);
                    final isCorrect = question.correctAnswers.contains(index);
                    final showCorrectness = isAnswerShown;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OptionTile(
                        optionLetter: String.fromCharCode(65 + index),
                        optionText: question.options[index],
                        isSelected: isSelected,
                        isCorrect: isCorrect,
                        showCorrectness: showCorrectness,
                        isMultiple: isMultiple,
                        onTap: () => state.selectOption(currentIndex, index, isMultiple),
                      ),
                    );
                  }),
                );
              },
            );
          },
        );
      },
    );
  }
}
