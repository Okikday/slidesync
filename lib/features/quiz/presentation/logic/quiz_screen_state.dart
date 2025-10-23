import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:slidesync/data/models/quiz_question_model/quiz_question.dart';

// ===================================================================================================
// STATE
// ===================================================================================================

class QuizScreenState {
  final Ref ref;
  final List<QuizQuestion> questions;
  final bool hasTimer;
  final Duration? timerDuration;

  late final ValueNotifier<int> currentQuestionIndexNotifier;
  late final ValueNotifier<Map<int, List<int>>> selectedAnswersNotifier;
  late final ValueNotifier<Map<int, bool>> showAnswerNotifier;
  late final ValueNotifier<Duration?> remainingTimeNotifier;
  late final ValueNotifier<Map<int, Duration>> questionTimesNotifier;
  late final ValueNotifier<DateTime> currentQuestionStartTimeNotifier;

  Timer? _timer;
  List<ShuffledQuestion> shuffledQuestions = [];

  QuizScreenState({required this.ref, required this.questions, this.hasTimer = false, this.timerDuration}) {
    currentQuestionIndexNotifier = ValueNotifier(0);
    selectedAnswersNotifier = ValueNotifier({});
    showAnswerNotifier = ValueNotifier({});
    remainingTimeNotifier = ValueNotifier(timerDuration);
    questionTimesNotifier = ValueNotifier({});
    currentQuestionStartTimeNotifier = ValueNotifier(DateTime.now());

    // Shuffle all questions for exam mode
    shuffledQuestions = questions.map((q) => q.shuffled()).toList();

    if (hasTimer && timerDuration != null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeNotifier.value != null) {
        final newTime = remainingTimeNotifier.value! - const Duration(seconds: 1);
        if (newTime.isNegative) {
          _timer?.cancel();
          remainingTimeNotifier.value = Duration.zero;
          // Auto-submit quiz when time runs out
        } else {
          remainingTimeNotifier.value = newTime;
        }
      }
    });
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < shuffledQuestions.length) {
      _saveCurrentQuestionTime();
      currentQuestionIndexNotifier.value = index;
      currentQuestionStartTimeNotifier.value = DateTime.now();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndexNotifier.value < shuffledQuestions.length - 1) {
      goToQuestion(currentQuestionIndexNotifier.value + 1);
    }
  }

  void previousQuestion() {
    if (currentQuestionIndexNotifier.value > 0) {
      goToQuestion(currentQuestionIndexNotifier.value - 1);
    }
  }

  void selectOption(int questionIndex, int optionIndex, bool isMultiple) {
    final currentSelections = Map<int, List<int>>.from(selectedAnswersNotifier.value);

    if (isMultiple) {
      final selections = List<int>.from(currentSelections[questionIndex] ?? []);
      if (selections.contains(optionIndex)) {
        selections.remove(optionIndex);
      } else {
        selections.add(optionIndex);
      }
      currentSelections[questionIndex] = selections;
    } else {
      currentSelections[questionIndex] = [optionIndex];
    }

    selectedAnswersNotifier.value = currentSelections;
  }

  void toggleShowAnswer(int questionIndex) {
    final currentShown = Map<int, bool>.from(showAnswerNotifier.value);
    currentShown[questionIndex] = !(currentShown[questionIndex] ?? false);
    showAnswerNotifier.value = currentShown;
  }

  void _saveCurrentQuestionTime() {
    final currentIndex = currentQuestionIndexNotifier.value;
    final startTime = currentQuestionStartTimeNotifier.value;
    final duration = DateTime.now().difference(startTime);

    final times = Map<int, Duration>.from(questionTimesNotifier.value);
    times[currentIndex] = (times[currentIndex] ?? Duration.zero) + duration;
    questionTimesNotifier.value = times;
  }

  Duration getTotalTimeSpent() {
    _saveCurrentQuestionTime();
    return questionTimesNotifier.value.values.fold(Duration.zero, (total, duration) => total + duration);
  }

  void dispose() {
    _saveCurrentQuestionTime();
    _timer?.cancel();
    currentQuestionIndexNotifier.dispose();
    selectedAnswersNotifier.dispose();
    showAnswerNotifier.dispose();
    remainingTimeNotifier.dispose();
    questionTimesNotifier.dispose();
    currentQuestionStartTimeNotifier.dispose();
  }
}
