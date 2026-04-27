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
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
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

  static Future<Module?> getByUid(String collectionId) async {
    return await _isar.modules.filter().uidEqualTo(collectionId).findFirst();
  }

  static Stream<Module?> watchCollectionById(String collectionId) async* {
    yield* _isar.modules.filter().uidEqualTo(collectionId).watch(fireImmediately: true).map((list) => list.firstOrNull);
  }

  // static Future<Module?> deleteCollectionByUid(String collectionId) async {
  //   final Module? collection = await getById(collectionId);
  //   if (collection == null) return collection;
  //   return isar.writeTxn<Module?>(() async {
  //     await (filter).uidEqualTo(collectionId).deleteFirst();
  //     return collection;
  //   });
  // }

  /// For adding a new [Module]
  static Future<bool> _addCollection(Module collection) async {
    try {
      if (collection.parentId.isEmpty) return false;
      final course = await CourseRepo.getCourseByUid(collection.parentId);
      if (course == null) return false;

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
    }
    return false;
  }

  /// Deletes a [Module] or [Collection] and all of it's contents
  static Future<bool> deleteCollection(Module collection) async {
    try {
      if (collection.uid.isEmpty) return false;

      // 1. Verify that it's parent course exists
      final course = await CourseRepo.getCourseByUid(collection.parentId);
      if (course == null) return false;

      // 2. Temporarily remove the module/collection from the course
      await course.modules.load();
      course.modules.removeWhere((c) => c.id == collection.id);

      // 3. Get the list of content uids under it
      await collection.contents.load();
      final contentIds = collection.contents.map((c) => c.uid).toList();

      // 4. Temporarily remove those content tracking from the CourseTrack
      final courseTrack = await CourseTrackRepo.filter.uidEqualTo(collection.parentId).findFirst();
      if (courseTrack != null) {
        await courseTrack.contentTracks.load();
        for (final id in contentIds) {
          courseTrack.contentTracks.removeWhere((c) => c.uid == id);
        }
      }

      // 5. Finish up the deletion of those data from db completely
      await isar.writeTxn(() async {
        if (contentIds.isNotEmpty) {
          if (courseTrack != null) {
            final newProgress = courseTrack.contentTracks.isNotEmpty == true
                ? ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks)
                : 0.0;
            await courseTrack.contentTracks.save();
            await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
          }
          await isar.moduleContents.deleteAllByUid(contentIds);
          await isar.contentTracks.deleteAllByUid(contentIds);
        }
        await course.modules.save();
        await isar.modules.delete(collection.id);
        await isar.courses.put(course);
      });

      return true;
    } catch (e, st) {
      log('Unable to deleteCollection error: $e\n$st');
      return false;
    }
  }

  /// For adding Collection to a Course that doesn't already have another collection with same title
  static Future<String?> addCollectionNoDuplicateTitle(Module collection) async {
    final duplicate = await getByTitleAndParentId(parentId: collection.parentId, title: collection.title);
    if (duplicate != null) return "Collection title already exists, try using a different name";
    final result = await _addCollection(collection);
    if (result) return null;
    return "An error occured while adding collection";
  }

  static Future<Module?> getByTitleAndParentId({required String title, required String parentId}) async =>
      await _isar.modules.filter().titleEqualTo(title).parentIdEqualTo(parentId).findFirst();

  static Future<void> addContentsToAppCollection(
    AppCourseCollections type, {
    required List<ModuleContent> contents,
  }) async {
    if (contents.isEmpty) return;

    final collection = await getByUid(type.name);
    if (collection == null) return;

    await collection.contents.load();
    collection.contents.addAll(contents);

    await isar.writeTxn(() async {
      await isar.moduleContents.putAll(contents);
      await collection.contents.save();
      await isar.modules.put(collection);
    });
  }
}
