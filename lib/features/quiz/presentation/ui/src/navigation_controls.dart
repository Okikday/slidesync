import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/quiz/presentation/logic/quiz_screen_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class NavigationControls extends ConsumerWidget {
  final QuizScreenState state;

  const NavigationControls({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return ValueListenableBuilder<int>(
      valueListenable: state.currentQuestionIndexNotifier,
      builder: (context, currentIndex, _) {
        final isFirst = currentIndex == 0;
        final isLast = currentIndex == state.shuffledQuestions.length - 1;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isFirst ? null : state.previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: theme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: theme.fontFamily),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLast ? null : state.nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: theme.fontFamily),
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
