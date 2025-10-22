import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/quiz/presentation/logic/quiz_screen_provider.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/answer_explanation_section.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/navigation_controls.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/options_section.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/question_navigator.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/question_section.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/show_answer_button.dart';
import 'package:slidesync/features/quiz/presentation/ui/src/timer_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class QuizScreen extends ConsumerWidget {
  final QuizScreenConfig config;

  const QuizScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(QuizScreenProvider.state(config));
    final theme = ref;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text(
          'Quiz',
          style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
        ),
        actions: [if (config.hasTimer) TimerWidget(state: state)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuestionSection(state: state),
                  const SizedBox(height: 24),
                  OptionsSection(state: state),
                  const SizedBox(height: 24),
                  ShowAnswerButton(state: state),
                  const SizedBox(height: 16),
                  AnswerExplanationSection(state: state),
                ],
              ),
            ),
          ),
          NavigationControls(state: state),
          QuestionNavigator(state: state),
        ],
      ),
    );
  }
}
