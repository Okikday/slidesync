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
        await isar.courses.put(course.copyWith(lastModified: DateTime.now()));
      });
      await isar.writeTxn(() async {
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
      log('[deleteCollection] start collection=${collection.uid} parent=${collection.parentId}');
      if (collection.uid.isEmpty) return false;

      // 1. Verify that it's parent course exists
      final course = await CourseRepo.getCourseByUid(collection.parentId);
      log('[deleteCollection] loaded course=${course?.uid}');
      if (course == null) return false;

      // 2. Temporarily remove the module/collection from the course
      await course.modules.load();
      log('[deleteCollection] loaded course.modules count=${course.modules.length}');
      course.modules.removeWhere((c) => c.id == collection.id);

      // 3. Get the list of content uids under it
      await collection.contents.load();
      final contentIds = collection.contents.map((c) => c.uid).toList();
      log('[deleteCollection] loaded collection.contents count=${contentIds.length}');

      // 4. Temporarily remove those content tracking from the CourseTrack
      final courseTrack = await CourseTrackRepo.filter.uidEqualTo(collection.parentId).findFirst();
      log('[deleteCollection] loaded courseTrack=${courseTrack?.uid}');
      if (courseTrack != null) {
        await courseTrack.contentTracks.load();
        log('[deleteCollection] loaded courseTrack.contentTracks count=${courseTrack.contentTracks.length}');
        for (final id in contentIds) {
          courseTrack.contentTracks.removeWhere((c) => c.uid == id);
        }
      }

      // 5. Finish up the deletion of those data from db completely
      log('[deleteCollection] entering writeTxn');
      await isar.writeTxn(() async {
        log('[deleteCollection] writeTxn begin');
        if (contentIds.isNotEmpty) {
          log('[deleteCollection] deleting contents ids=${contentIds.length}');
          await isar.moduleContents.deleteAllByUid(contentIds);
          await isar.contentTracks.deleteAllByUid(contentIds);
        }
        log('[deleteCollection] deleting module dbId=${collection.id}');
        await isar.modules.delete(collection.id);
        final freshCourse = await CourseRepo.getCourseByUid(collection.parentId);
        if (freshCourse != null) {
          await isar.courses.put(freshCourse.copyWith(lastModified: DateTime.now()));
        }
        log('[deleteCollection] writeTxn end');
      });

      log('[deleteCollection] refreshing course links');
      final freshCourse = await CourseRepo.getCourseByUid(collection.parentId);
      if (freshCourse != null) {
        await freshCourse.modules.load();
        freshCourse.modules.removeWhere((c) => c.id == collection.id);
        await isar.writeTxn(() async {
          await freshCourse.modules.save();
        });
        log('[deleteCollection] fresh course saved');
      }

      if (courseTrack != null && contentIds.isNotEmpty) {
        log('[deleteCollection] refreshing courseTrack links');
        final freshCourseTrack = await CourseTrackRepo.getByUid(collection.parentId);
        if (freshCourseTrack != null) {
          await freshCourseTrack.contentTracks.load();
          freshCourseTrack.contentTracks.removeWhere((c) => contentIds.contains(c.uid));

          final newProgress = freshCourseTrack.contentTracks.isNotEmpty == true
              ? ContentTrackRepo.computeProgressForMultiple(freshCourseTrack.contentTracks)
              : 0.0;
          await isar.writeTxn(() async {
            await freshCourseTrack.contentTracks.save();
            await isar.courseTracks.put(freshCourseTrack.copyWith(progress: newProgress));
          });
          log('[deleteCollection] fresh courseTrack saved progress=$newProgress');
        }
      }

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

    final course = await CourseRepo.getCourseByUid(courseId);
    if (course == null) return [];

    await course.modules.load();

    final existingTitles = course.modules.map((module) => module.title.toLowerCase()).toSet();
    final uniqueCollections = <Module>[];

    for (final collection in collections) {
      if (collection.title.trim().isEmpty) continue;

      collection.parentId = courseId;
      final normalizedTitle = collection.title.toLowerCase();
      if (existingTitles.contains(normalizedTitle)) continue;

      existingTitles.add(normalizedTitle);
      uniqueCollections.add(collection);
    }

    if (uniqueCollections.isEmpty) return [];

    await isar.writeTxn(() async {
      await isar.modules.putAll(uniqueCollections);
      course.modules.addAll(uniqueCollections);
      await isar.courses.put(course.copyWith(lastModified: DateTime.now()));
    });

    await isar.writeTxn(() async {
      await course.modules.save();
    });

    return uniqueCollections;
  }

  static Future<List<Module>> moveModules(List<Module> modules, String targetCourseId) async {
    if (modules.isEmpty || targetCourseId.trim().isEmpty) return [];

    final targetCourse = await CourseRepo.getCourseByUid(targetCourseId);
    if (targetCourse == null) return [];

    final targetCourseTrack = await CourseTrackRepo.getByUid(targetCourseId);
    if (targetCourseTrack == null) return [];

    await targetCourse.modules.load();
    await targetCourseTrack.contentTracks.load();

    // Resolve stored modules and group by source course
    final resolvedModules = <Module>[];
    final modulesBySource = <String, List<Module>>{};
    for (final m in modules) {
      if (m.uid.trim().isEmpty) continue;
      final stored = await getByUid(m.uid) ?? m;
      if (stored.parentId == targetCourseId) continue; // already in target
      resolvedModules.add(stored);
      modulesBySource.putIfAbsent(stored.parentId, () => []).add(stored);
    }

    if (resolvedModules.isEmpty) return [];

    // Prepare course and track maps
    final sourceCourses = <String, Course>{};
    final sourceCourseTracks = <String, CourseTrack>{};
    final contentTracksToPersist = <String, ContentTrack>{};

    // Load source courses and courseTracks
    for (final sourceId in modulesBySource.keys) {
      final c = await CourseRepo.getCourseByUid(sourceId);
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

    // Update module parentIds and collect contentTracks changes
    for (final module in resolvedModules) {
      // remove from source course (if loaded)
      final source = sourceCourses[module.parentId];
      source?.modules.removeWhere((mi) => mi.uid == module.uid);

      // ensure not duplicated in target
      targetCourse.modules.removeWhere((mi) => mi.uid == module.uid);

      // reparent module
      final oldParent = module.parentId;
      module.parentId = targetCourseId;
      targetCourse.modules.add(module);

      await module.contents.load();
      for (final content in module.contents) {
        final ct = await ContentTrackRepo.getByContentId(content.uid);
        if (ct == null) continue;

        // remove from source course track
        final sourceTrack = sourceCourseTracks[oldParent];
        sourceTrack?.contentTracks.removeWhere((t) => t.uid == ct.uid);

        // remove any existing in target and add to target track
        targetCourseTrack.contentTracks.removeWhere((t) => t.uid == ct.uid);
        ct.courseId = targetCourseId;
        targetCourseTrack.contentTracks.add(ct);
        contentTracksToPersist[ct.uid] = ct;
      }
    }

    final now = DateTime.now();

    await isar.writeTxn(() async {
      // persist modules and content tracks
      await isar.modules.putAll(resolvedModules);
      if (contentTracksToPersist.isNotEmpty) {
        await isar.contentTracks.putAll(contentTracksToPersist.values.toList());
      }

      // save source courses and update timestamps
      for (final src in sourceCourses.values) {
        await isar.courses.put(src.copyWith(lastModified: now));
      }

      // save target course and update timestamp
      await isar.courses.put(targetCourse.copyWith(lastModified: now));

      // recompute and persist progress for affected courseTracks
      for (final entry in sourceCourseTracks.entries) {
        final track = entry.value;
        final newProgress = track.contentTracks.isNotEmpty
            ? ContentTrackRepo.computeProgressForMultiple(track.contentTracks)
            : 0.0;
        await track.contentTracks.save();
        await isar.courseTracks.put(track.copyWith(progress: newProgress));
      }

      final targetProgress = targetCourseTrack.contentTracks.isNotEmpty
          ? ContentTrackRepo.computeProgressForMultiple(targetCourseTrack.contentTracks)
          : 0.0;
      await isar.courseTracks.put(targetCourseTrack.copyWith(progress: targetProgress));
    });

    await isar.writeTxn(() async {
      for (final src in sourceCourses.values) {
        await src.modules.save();
      }
      await targetCourse.modules.save();
      for (final sourceCourseTrack in sourceCourseTracks.values) {
        await sourceCourseTrack.contentTracks.save();
      }
      await targetCourseTrack.contentTracks.save();
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
    });

    await isar.writeTxn(() async {
      await collection.contents.save();
    });
  }
}
