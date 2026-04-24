import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/constants.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class ModuleRepo {
  static final IsarData<Module> _isarData = IsarData<Module>();
  static IsarData<Module> get isarData => _isarData;
  static Isar get _isar => _isarData.isarInstance;
  static Isar get isar => _isar;

  static QueryBuilder<Module, Module, QFilterCondition> get filter => _isar.modules.filter();

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<Module?> getByDbId(int dbId) => _isarData.getById(dbId);

  static Stream<Module?> watchByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> add(Module collection) async => await _isarData.store(collection);

  static Future<List<Module>> getAll() async => _isarData.getAll();

  static Stream<List<Module>> watchAll() => _isarData.watchAll();

  Future<Stream<void>> watchForChangesById(String collectionId, {bool fireImmediately = true}) async =>
      _isar.modules.filter().uidEqualTo(collectionId).watchLazy();

  // static Future<Stream<List<CourseCollection>>> watchAllLazily() async => await _isarData.watchAllLazily();

  static Future<Module?> getById(String collectionId) async {
    return await _isar.modules.filter().uidEqualTo(collectionId).findFirst();
  }

  static Stream<Module?> watchCollectionById(String collectionId) async* {
    yield* _isar.modules.filter().uidEqualTo(collectionId).watch(fireImmediately: true).map((list) => list.firstOrNull);
  }

  static Future<Module?> deleteCollectionById(String collectionId) async {
    final Module? collection = await getById(collectionId);
    return await isar.writeTxn<Module?>(() async {
      if (collection != null) {
        final idQuery = (filter).uidEqualTo(collectionId);
        await idQuery.deleteFirst();
      }
      return collection;
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////

  // Check
  static Future<bool> addCollection(Module collection) async {
    try {
      if (collection.parentId.isEmpty) return false;
      final Course? course = await CourseRepo.getCourseByUid(collection.parentId);
      if (course == null) return false;

      final Isar isar = _isar;

      await course.modules.load();
      course.modules.add(collection);
      await isar.writeTxn(() async {
        await isar.modules.put(collection);
        await course.modules.save();
        await isar.courses.put(course.copyWith(lastModified: DateTime.now()));
      });
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  // Check
  static Future<bool> deleteCollection(Module collection) async {
    try {
      if (collection.uid.isEmpty) return false;

      final Course? course = await CourseRepo.getCourseByUid(collection.parentId);
      if (course == null) return false;

      final isar = _isar;

      await collection.contents.load();
      final contentIds = collection.contents.map((c) => c.uid).toList();
      await course.modules.load();
      course.modules.removeWhere((c) => c.id == collection.id);
      final courseTrack = await (CourseTrackRepo.filter).uidEqualTo(collection.parentId).findFirst();

      if (courseTrack != null) {
        for (final id in contentIds) {
          courseTrack.contentTracks.removeWhere((c) => c.uid == id);
        }
      }
      // final contentTrackQuery = (await ContentTrackRepo.filter).uidEqualTo(collection.parentId);
      // final contentTrack = await contentTrackQuery.findFirst();
      // final parentCourseTrack = contentTrack?.courseTrackLink.value;
      // if (parentCourseTrack != null) {
      //   await parentCourseTrack.contentTracks.load();
      //   parentCourseTrack.contentTracks.remove(contentTrack);
      // }
      await isar.writeTxn(() async {
        await course.modules.save();
        if (contentIds.isNotEmpty) {
          await isar.moduleContents.deleteAllByUid(contentIds);
          if (courseTrack != null) {
            await courseTrack.contentTracks.save();
            isar.contentTracks.deleteAllByUid(contentIds);
          }
        }

        await isar.modules.delete(collection.id);
        await isar.courses.put(course);
      });

      return true;
    } catch (e, st) {
      log('deleteCollection error: $e\n$st');
      return false;
    }
  }

  static Future<String?> addCollectionNoDuplicateTitle(Module collection) async {
    final isar = _isar;
    final duplicate = await (isar.modules
        .filter()
        .titleEqualTo(collection.title)
        .parentIdEqualTo(collection.parentId)
        .findFirst());
    if (duplicate != null) return "Collection title already exists, try using a different name";
    final bool result = await addCollection(collection);
    if (result) return null;
    return "An error occured while adding collection";
  }

  static Future<Module?> getByTitleAndParentId({required String title, required String parentId}) async {
    return await _isar.modules.filter().titleEqualTo(title).parentIdEqualTo(parentId).findFirst();
  }

  static Future<void> addContentToAppCollection(AppCourseCollections type, {required ModuleContent content}) async {
    final collection = await getById(type.name);
    if (collection == null) return;
    collection.contents.load();
    collection.contents.add(content);

    final isar = _isar;
    await isar.writeTxn(() async {
      await collection.contents.save();
      await isar.modules.put(collection);
    });
  }

  static Future<void> addContentsToAppCollection(
    AppCourseCollections type, {
    required List<ModuleContent> contents,
  }) async {
    if (contents.isEmpty) return;

    final collection = await getById(type.name);
    if (collection == null) return;

    await collection.contents.load();
    collection.contents.addAll(contents);

    await isar.writeTxn(() async {
      await collection.contents.save();
      await isar.modules.put(collection);
    });
  }
}
