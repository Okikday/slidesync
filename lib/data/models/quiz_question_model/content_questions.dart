import 'dart:convert';
import 'package:isar/isar.dart';

part 'content_questions.g.dart';

@collection
class ContentQuestions {
  Id id = Isar.autoIncrement;

  @Index()
  late String contentHash;

  @Index(unique: true)
  late String contentId;

  @Index(caseSensitive: false)
  late String title;

  /// Holds the json of QuizQuestion
  List<String> questions = [];

  late String metadataJson;

  ContentQuestions();

  factory ContentQuestions.create({
    required String contentHash,
    required String contentId,
    required String title,
    List<String>? questions,
    String metadataJson = '{}',
  }) {
    final content = ContentQuestions()
      ..contentHash = contentHash
      ..contentId = contentId
      ..title = title
      ..questions = questions ?? []
      ..metadataJson = metadataJson;
    return content;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contentHash': contentHash,
      'contentId': contentId,
      'title': title,
      'questions': questions,
      'metadataJson': metadataJson,
    };
  }

  factory ContentQuestions.fromMap(Map<String, dynamic> map) {
    return ContentQuestions()
      ..id = map['id'] ?? Isar.autoIncrement
      ..contentHash = map['contentHash'] ?? ''
      ..contentId = map['contentId'] ?? ''
      ..title = map['title'] ?? ''
      ..questions = List<String>.from(map['questions'] ?? [])
      ..metadataJson = map['metadataJson'] ?? '{}';
  }

  String toJson() => jsonEncode(toMap());

  factory ContentQuestions.fromJson(String source) => ContentQuestions.fromMap(jsonDecode(source));

  @override
  bool operator ==(covariant ContentQuestions other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.contentHash == contentHash &&
        other.contentId == contentId &&
        other.title == title &&
        _listEquals(other.questions, questions) &&
        other.metadataJson == metadataJson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        contentHash.hashCode ^
        contentId.hashCode ^
        title.hashCode ^
        questions.hashCode ^
        metadataJson.hashCode;
  }

  @override
  String toString() {
    return 'ContentQuestions(id: $id, contentHash: $contentHash, contentId: $contentId, title: $title, questions: ${questions.length} items, metadataJson: $metadataJson)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

extension ContentQuestionsExtension on ContentQuestions {
  ContentQuestions copyWith({
    String? contentHash,
    String? contentId,
    String? title,
    List<String>? questions,
    String? metadataJson,
  }) {
    return this
      ..contentHash = contentHash ?? this.contentHash
      ..contentId = contentId ?? this.contentId
      ..title = title ?? this.title
      ..questions = questions ?? this.questions
      ..metadataJson = metadataJson ?? this.metadataJson;
  }

  Map<String, dynamic> get metadata {
    try {
      return Map<String, dynamic>.from(jsonDecode(metadataJson));
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}
