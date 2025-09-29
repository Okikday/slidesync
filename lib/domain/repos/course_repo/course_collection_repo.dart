import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';

class CourseCollectionRepo {
  static final IsarData<CourseCollection> _isarData = IsarData.instance<CourseCollection>();
  static Future<Isar> get _isar async => await IsarData.isarFuture;

  static IsarData<CourseCollection> get isarData => _isarData;

  static Future<QueryBuilder<CourseCollection, CourseCollection, QFilterCondition>> get filter async =>
      (await _isar).courseCollections.filter();

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<CourseCollection?> getByDbId(int dbId) => _isarData.getById(dbId);

  static Stream<CourseCollection?> watchByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> add(CourseCollection collection) async => await _isarData.store(collection);

  static Future<List<CourseCollection>> getAll() async => _isarData.getAll();

  static Stream<List<CourseCollection>> watchAll() => _isarData.watchAll();

  static Future<Stream<List<CourseCollection>>> watchAllLazily() async => await _isarData.watchAllLazily();

  static Future<CourseCollection?> getById(String collectionId) async {
    return await (await _isar).courseCollections.filter().collectionIdEqualTo(collectionId).findFirst();
  }

  static Stream<CourseCollection?> watchCollectionById(String collectionId) async* {
    yield* (await _isar).courseCollections
        .filter()
        .collectionIdEqualTo(collectionId)
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  static Future<CourseCollection?> deleteCollectionById(String collectionId) async {
    final isar = await _isar;
    final CourseCollection? collection = await getById(collectionId);
    return await isar.writeTxn<CourseCollection?>(() async {
      if (collection != null) {
        final idQuery = (await filter).collectionIdEqualTo(collectionId);
        await idQuery.deleteFirst();
      }
      return collection;
    });
  }



  ////////////////////////////////////////////////////////////////////////////////////


    // Check
  static Future<bool> addCollection(CourseCollection collection) async {
    try {
      if (collection.parentId.isEmpty) return false;
      final Course? course = await CourseRepo.getCourseById(collection.parentId);
      if (course == null) return false;

      final Isar isar = (await _isar);

      await course.collections.load();
      course.collections.add(collection);
      await isar.writeTxn(() async {
        await isar.courseCollections.put(collection);
        await course.collections.save();
        await isar.courses.put(course.copyWith(lastUpdated: DateTime.now()));
      });
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  // Check
  static Future<bool> deleteCollection(CourseCollection collection) async {
    try {
      if (collection.collectionId.isEmpty) return false;

      final Course? course = await CourseRepo.getCourseById(collection.parentId);
      if (course == null) return false;

      final isar = (await _isar);

      await collection.contents.load();
      final contentIds = collection.contents.map((c) => c.id).toList();
      await course.collections.load();
      course.collections.removeWhere((c) => c.id == collection.id);

      await isar.writeTxn(() async {
        await course.collections.save();
        if (contentIds.isNotEmpty) {
          await isar.courseContents.deleteAll(contentIds);
        }

        await isar.courseCollections.delete(collection.id);
        await isar.courses.put(course);
      });

      return true;
    } catch (e, st) {
      log('deleteCollection error: $e\n$st');
      return false;
    }
  }

  
  static Future<String?> addCollectionNoDuplicateTitle(CourseCollection collection) async {
    final isar = (await _isar);
    final CourseCollection? duplicate = await (isar.courseCollections
        .filter()
        .collectionTitleEqualTo(collection.collectionTitle)
        .parentIdEqualTo(collection.parentId)
        .findFirst());
    if (duplicate != null) return "Collection title already exists, try using a different name";
    final bool result = await addCollection(collection);
    if (result) return null;
    return "An error occured while adding collection";
  }
}
