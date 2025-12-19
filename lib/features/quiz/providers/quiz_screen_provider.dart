import 'package:slidesync/data/models/quiz_question_model/quiz_question.dart';
import 'package:slidesync/features/quiz/providers/quiz_screen_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class QuizScreenProvider {
  static final state = Provider.autoDispose.family<QuizScreenState, QuizScreenConfig>((ref, config) {
    final state = QuizScreenState(
      ref: ref,
      questions: config.questions,
      hasTimer: config.hasTimer,
      timerDuration: config.timerDuration,
    );
    ref.onDispose(state.dispose);
    return state;
  });
}

class QuizScreenConfig {
  final List<QuizQuestion> questions;
  final bool hasTimer;
  final Duration? timerDuration;

  const QuizScreenConfig({required this.questions, this.hasTimer = false, this.timerDuration});
}
