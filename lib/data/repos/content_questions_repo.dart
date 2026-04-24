import 'package:isar_community/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/quiz_question_model/content_questions.dart';

class ContentQuestionsRepo {
  static final IsarData<ContentQuestions> _isarData = IsarData<ContentQuestions>();
  static IsarData<ContentQuestions> get isarData => _isarData;
  static Isar get _isar => _isarData.isarInstance;
  static Isar get isar => _isar;

  static QueryBuilder<ContentQuestions, ContentQuestions, QFilterCondition> get filter =>
      _isar.contentQuestions.filter();

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<ContentQuestions?> getByDbId(int dbId) => _isarData.getById(dbId);

  static Stream<ContentQuestions?> watchByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> add(ContentQuestions question) async => await _isarData.store(question);

  static Future<List<ContentQuestions>> getAll() async => _isarData.getAll();

  static Stream<List<ContentQuestions>> watchAll() => _isarData.watchAll();

  static Future<List<ContentQuestions>> getAllByContentHash(String xxh3Hash) async =>
      await _isar.contentQuestions.where().xxh3HashEqualTo(xxh3Hash).findAll();
  static Future<ContentQuestions?> getByContentHash(String xxh3Hash) async =>
      await _isar.contentQuestions.where().xxh3HashEqualTo(xxh3Hash).findFirst();

  static Future<List<ContentQuestions>> getByContentId(String contentId) async =>
      await _isar.contentQuestions.filter().contentIdEqualTo(contentId).findAll();
}
