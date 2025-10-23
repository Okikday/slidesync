// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

class QuizQuestion {
  final String question; // Question text in markdown format
  final List<String> options; // List of answer options
  final List<int> correctAnswers; // Indices of correct answers (0-based)
  final String? explanation; // Optional explanation
  final String? reference; // Optional reference URL for verified information

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswers,
    this.explanation,
    this.reference,
  });

  /// Creates a shuffled version of this question with options randomized
  /// and correct answer indices updated accordingly
  ShuffledQuestion shuffled() {
    final random = Random();
    
    // Create pairs of (index, option) to track original positions
    final indexedOptions = List.generate(
      options.length,
      (index) => MapEntry(index, options[index]),
    );
    
    // Shuffle the options
    indexedOptions.shuffle(random);
    
    // Extract shuffled options
    final shuffledOptions = indexedOptions.map((e) => e.value).toList();
    
    // Create mapping from old index to new index
    final indexMap = <int, int>{};
    for (var i = 0; i < indexedOptions.length; i++) {
      indexMap[indexedOptions[i].key] = i;
    }
    
    // Map correct answers to their new positions
    final shuffledCorrectAnswers = correctAnswers
        .map((oldIndex) => indexMap[oldIndex] ?? oldIndex)
        .toList()
      ..sort();
    
    return ShuffledQuestion(
      question: question,
      options: shuffledOptions,
      correctAnswers: shuffledCorrectAnswers,
      explanation: explanation,
      reference: reference,
      originalQuestion: this,
    );
  }

  /// Check if this is a multiple-answer question
  bool get isMultipleAnswer => correctAnswers.length > 1;

  /// Check if this is a single-answer question
  bool get isSingleAnswer => correctAnswers.length == 1;

  /// Get correct answer(s) as letter(s) (A, B, C, etc.)
  String getCorrectAnswerLetters() {
    return correctAnswers
        .map((index) => String.fromCharCode(65 + index))
        .join(', ');
  }

  /// Get the correct option text(s)
  List<String> getCorrectOptionTexts() {
    return correctAnswers.map((index) => options[index]).toList();
  }

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    List<int>? correctAnswers,
    String? explanation,
    String? reference,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'question': question,
      'options': options,
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'reference': reference,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List<String>),
      correctAnswers: List<int>.from(map['correctAnswers'] as List<int>),
      explanation: map['explanation'] != null ? map['explanation'] as String : null,
      reference: map['reference'] != null ? map['reference'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizQuestion.fromJson(String source) => QuizQuestion.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ShuffledQuestion {
  final String question;
  final List<String> options;
  final List<int> correctAnswers;
  final String? explanation;
  final String? reference;
  final QuizQuestion originalQuestion;

  ShuffledQuestion({
    required this.question,
    required this.options,
    required this.correctAnswers,
    required this.explanation,
    required this.reference,
    required this.originalQuestion,
  });

  /// Get correct answer(s) as letter(s) (A, B, C, etc.)
  String getCorrectAnswerLetters() {
    return correctAnswers
        .map((index) => String.fromCharCode(65 + index))
        .join(', ');
  }

  /// Get the correct option text(s)
  List<String> getCorrectOptionTexts() {
    return correctAnswers.map((index) => options[index]).toList();
  }

  /// Check if a given answer is correct
  bool isCorrect(List<int> selectedIndices) {
    final sortedSelected = List<int>.from(selectedIndices)..sort();
    final sortedCorrect = List<int>.from(correctAnswers)..sort();
    
    if (sortedSelected.length != sortedCorrect.length) return false;
    
    for (var i = 0; i < sortedSelected.length; i++) {
      if (sortedSelected[i] != sortedCorrect[i]) return false;
    }
    
    return true;
  }

  /// Check if a single answer is correct (for single-choice questions)
  bool isCorrectSingle(int selectedIndex) {
    return correctAnswers.length == 1 && correctAnswers[0] == selectedIndex;
  }
}

/// Parser for extracting questions from Gemini's formatted output
class QuestionParser {
  static final _questionRegex = RegExp(
    r'---QUESTION_START---\s*\*\*Q:\*\*\s*(.+?)\s*\*\*OPTIONS:\*\*\s*(.+?)\s*\*\*ANSWER:\*\*\s*(.+?)\s*\*\*EXPLANATION:\*\*\s*(.+?)(?:\s*\*\*REFERENCE:\*\*\s*(.+?))?\s*---QUESTION_END---',
    multiLine: true,
    dotAll: true,
  );

  static final _optionRegex = RegExp(
    r'^-\s*[A-E]\)\s*(.+)$',
    multiLine: true,
  );

  /// Parse questions from Gemini's formatted output
  static List<QuizQuestion> parse(String input) {
    final questions = <QuizQuestion>[];

    for (final match in _questionRegex.allMatches(input)) {
      final questionText = match.group(1)?.trim() ?? '';
      final optionsText = match.group(2)?.trim() ?? '';
      final answerText = match.group(3)?.trim() ?? '';
      final explanationText = match.group(4)?.trim() ?? '';
      final referenceText = match.group(5)?.trim();

      // Extract options
      final options = _optionRegex
          .allMatches(optionsText)
          .map((m) => m.group(1)?.trim() ?? '')
          .toList();

      // Parse answer(s) - can be "A" or "A,C" for multiple answers
      final correctAnswers = answerText
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => s.codeUnitAt(0) - 65) // Convert letter to 0-based index
          .toList()
        ..sort();

      // Clean explanation and reference (remove if empty or just whitespace)
      final explanation = explanationText.isNotEmpty ? explanationText : null;
      final reference = referenceText?.isNotEmpty == true 
          ? referenceText!.replaceFirst('Verified:', '').trim() 
          : null;

      questions.add(QuizQuestion(
        question: questionText,
        options: options,
        correctAnswers: correctAnswers,
        explanation: explanation,
        reference: reference,
      ));
    }

    return questions;
  }
}