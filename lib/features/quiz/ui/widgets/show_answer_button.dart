import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/quiz/providers/quiz_screen_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ShowAnswerButton extends ConsumerWidget {
  final QuizScreenState state;

  const ShowAnswerButton({super.key, required this.state});

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

            return ElevatedButton(
              onPressed: () => state.toggleShowAnswer(currentIndex),
              style: ElevatedButton.styleFrom(
                backgroundColor: isShown ? theme.secondary : theme.primary,
                foregroundColor: isShown ? theme.onSecondary : theme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isShown ? 'Hide Answer' : 'Show Answer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: theme.fontFamily),
              ),
            );
          },
        );
      },
    );
  }
}
