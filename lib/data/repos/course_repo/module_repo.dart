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
  static Future<bool> _addCollection(Module module) async {
    try {
      if (module.parentId.isEmpty) return false;

      final course = await CourseRepo.getByUid(module.parentId);
      if (course == null) return false;

      await course.modules.load();
      course.modules.add(module);
      await isar.writeTxn(() async {
        await isar.modules.put(module);
        await isar.courses.put(course.copyWith(lastModified: DateTime.now()));
        await course.modules.save();
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

      final module = await ModuleRepo.getByDbId(collection.id);
      if (module == null) return false;

      final course = await CourseRepo.getByUid(module.parentId);
      if (course == null) return false;

      await module.contents.load();
      final contentUidSet = module.contents.map((c) => c.uid).toSet();

      await course.modules.load();
      course.modules.removeWhere((c) => c.id == module.id);

      final courseTrack = await CourseTrackRepo.filter.uidEqualTo(module.parentId).findFirst();
      if (courseTrack != null) {
        await courseTrack.contentTracks.load();
        courseTrack.contentTracks.removeWhere((c) => contentUidSet.contains(c.uid));
      }

      final newProgress = courseTrack != null && courseTrack.contentTracks.isNotEmpty
          ? ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks)
          : 0.0;

      await isar.writeTxn(() async {
        if (contentUidSet.isNotEmpty) {
          await isar.moduleContents.deleteAllByUid(contentUidSet.toList());
          await isar.contentTracks.deleteAllByUid(contentUidSet.toList());
        }
        await isar.modules.delete(module.id);
        await isar.courses.put(course.copyWith(lastModified: DateTime.now()));
        await course.modules.save();
        if (courseTrack != null) {
          await courseTrack.contentTracks.save();
          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
        }
      });

      log('[deleteCollection] success');
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

  static Future<List<Module>> addMultipleCollections(String courseId, List<Module> collections) async {
    if (courseId.isEmpty || collections.isEmpty) return [];

    final course = await CourseRepo.getByUid(courseId);
    if (course == null) return [];

    await course.modules.load();

    final existingTitles = course.modules.map((m) => m.title.toLowerCase()).toSet();

    final uniqueCollections = <Module>[];
    for (final collection in collections) {
      if (collection.title.trim().isEmpty) continue;
      final normalized = collection.title.toLowerCase();
      if (!existingTitles.add(normalized)) continue;
      collection.parentId = courseId;
      uniqueCollections.add(collection);
    }

    if (uniqueCollections.isEmpty) return [];

    course.modules.addAll(uniqueCollections);

    await isar.writeTxn(() async {
      await isar.modules.putAll(uniqueCollections);
      await isar.courses.put(course.copyWith(lastModified: DateTime.now()));
      await course.modules.save();
    });

    return uniqueCollections;
  }

  static Future<List<Module>> moveModules(List<Module> modules, String targetCourseId) async {
    if (modules.isEmpty || targetCourseId.trim().isEmpty) return [];

    final targetCourse = await CourseRepo.getByUid(targetCourseId);
    if (targetCourse == null) return [];

    final targetCourseTrack = await CourseTrackRepo.getByUid(targetCourseId);
    if (targetCourseTrack == null) return [];

    await targetCourse.modules.load();
    await targetCourseTrack.contentTracks.load();

    // --- ALL READS & PREP ---

    // Resolve stored modules, skip already-in-target, group by source
    final resolvedModules = <Module>[];
    final modulesBySource = <String, List<Module>>{};
    for (final m in modules) {
      if (m.uid.trim().isEmpty) continue;
      final stored = await getByUid(m.uid) ?? m;
      if (stored.parentId == targetCourseId) continue;
      resolvedModules.add(stored);
      modulesBySource.putIfAbsent(stored.parentId, () => []).add(stored);
    }

    if (resolvedModules.isEmpty) return [];

    // Load source courses and tracks
    final sourceCourses = <String, Course>{};
    final sourceCourseTracks = <String, CourseTrack>{};
    for (final sourceId in modulesBySource.keys) {
      final c = await CourseRepo.getByUid(sourceId);
      if (c != null) {
        await c.modules.load();
        sourceCourses[sourceId] = c;
      }
      final ct = await CourseTrackRepo.getByUid(sourceId);
      if (ct != null) {
        await ct.contentTracks.load();
        sourceCourseTracks[sourceId] = ct;
      }
    }

    // Build sets for O(1) lookups
    final targetModuleUidSet = targetCourse.modules.map((m) => m.uid).toSet();
    final targetContentUidSet = targetCourseTrack.contentTracks.map((t) => t.uid).toSet();
    final contentTracksToPersist = <String, ContentTrack>{};

    // Mutate in memory
    for (final module in resolvedModules) {
      final oldParentId = module.parentId;

      sourceCourses[oldParentId]?.modules.removeWhere((m) => m.uid == module.uid);

      if (targetModuleUidSet.add(module.uid)) {
        module.parentId = targetCourseId;
        targetCourse.modules.add(module);
      }

      await module.contents.load();
      for (final content in module.contents) {
        final ct = await ContentTrackRepo.getByContentId(content.uid);
        if (ct == null) continue;

        sourceCourseTracks[oldParentId]?.contentTracks.removeWhere((t) => t.uid == ct.uid);

        if (targetContentUidSet.add(ct.uid)) {
          ct.courseId = targetCourseId;
          targetCourseTrack.contentTracks.add(ct);
        }

        contentTracksToPersist[ct.uid] = ct;
      }
    }

    final now = DateTime.now();

    // --- ONE SINGLE writeTxn ---
    await isar.writeTxn(() async {
      await isar.modules.putAll(resolvedModules);

      if (contentTracksToPersist.isNotEmpty) {
        await isar.contentTracks.putAll(contentTracksToPersist.values.toList());
      }

      for (final src in sourceCourses.values) {
        await isar.courses.put(src.copyWith(lastModified: now));
        await src.modules.save();
      }

      await isar.courses.put(targetCourse.copyWith(lastModified: now));
      await targetCourse.modules.save();

      for (final track in sourceCourseTracks.values) {
        final progress = track.contentTracks.isNotEmpty
            ? ContentTrackRepo.computeProgressForMultiple(track.contentTracks)
            : 0.0;
        await track.contentTracks.save();
        await isar.courseTracks.put(track.copyWith(progress: progress));
      }

      final targetProgress = targetCourseTrack.contentTracks.isNotEmpty
          ? ContentTrackRepo.computeProgressForMultiple(targetCourseTrack.contentTracks)
          : 0.0;
      await targetCourseTrack.contentTracks.save();
      await isar.courseTracks.put(targetCourseTrack.copyWith(progress: targetProgress));
    });

    return resolvedModules;
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
      await isar.modules.put(collection);
      await collection.contents.save();
    });
  }
}
