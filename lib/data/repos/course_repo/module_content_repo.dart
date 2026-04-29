import 'dart:developer';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';
import 'package:uuid/uuid.dart';

class ModuleContentRepo {
  static final IsarData<ModuleContent> _isarData = IsarData<ModuleContent>();
  static IsarData<ModuleContent> get isarData => _isarData;
  static Isar get _isar => _isarData.isarInstance;
  static Isar get isar => _isar;

  static QueryBuilder<ModuleContent, ModuleContent, QFilterCondition> get filter => _isar.moduleContents.filter();

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<ModuleContent?> getByDbId(int dbId) => _isarData.getById(dbId);

  static Stream<ModuleContent?> watchByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> add(ModuleContent content) async => await _isarData.store(content);

  static Future<List<ModuleContent>> getAll() async => _isarData.getAll();

  static Stream<List<ModuleContent>> watchAll() => _isarData.watchAll();

  // static Future<Stream<List<CourseContent>>> watchAllLazily() async => await _isarData.watchAllLazily();

  static Future<ModuleContent?> getByUid(String contentId) async =>
      await _isar.moduleContents.where().uidEqualTo(contentId).findFirst();

  static Future<ModuleContent?> getByHash(String xxh3Hash) async {
    return await _isar.moduleContents.filter().xxh3HashEqualTo(xxh3Hash).findFirst();
  }

  static Future<bool> doesDuplicateHashExists(String xxh3Hash) async =>
      (await _isar.moduleContents.filter().xxh3HashEqualTo(xxh3Hash).limit(2).findAll()).length > 1;

  static Future<Map<String, bool>> doesMultipleDuplicateHashExist(Iterable<String> xxh3Hashes) async {
    final matches = await _isar.moduleContents
        .filter()
        .anyOf(xxh3Hashes, (q, String h) => q.xxh3HashEqualTo(h))
        .xxh3HashProperty()
        .findAll();

    final counts = <String, int>{};
    for (final hash in matches) {
      counts[hash] = (counts[hash] ?? 0) + 1;
    }

    return counts.map((k, v) => MapEntry(k, v > 1));
  }

  // static Future<CourseContent?> deleteByHash(String xxh3Hash) async {
  //   final isar = await _isar;
  //   final CourseContent? collection = await getByHash(xxh3Hash);
  //   return await isar.writeTxn<CourseContent?>(() async {
  //     if (collection != null) {
  //       final idQuery = await _queryById(xxh3Hash);
  //       await idQuery.deleteFirst();
  //     }
  //     return collection;
  //   });
  // }

  /// Gets Duplicate Coursecontents, or contents with same hash
  static Future<List<ModuleContent>> findAllDuplicatesByHash(String xxh3Hash) async {
    return await _isar.moduleContents.filter().xxh3HashEqualTo(xxh3Hash).findAll();
  }

  static Future<ModuleContent?> findFirstDuplicateContentByHash(Module collection, String xxh3Hash) async {
    await collection.contents.load();
    return (collection.contents.where((content) => content.xxh3Hash == xxh3Hash)).firstOrNull;
  }

  // Check
  static Future<bool> deleteContent(ModuleContent content, [Module? collection]) async {
    try {
      // 1. Make sure the Module is valid
      final module = collection ?? await ModuleRepo.getByUid(content.parentId);
      if (module == null) return false;

      // 2. Make sure the [Course] is valid
      final course = await _getCollectionParent(module);
      if (course == null) return false; // Should probably delete the [Module] since it's an orphan

      // ... Load the Iterable collections and contents data in the respective classes
      await module.contents.load();
      await course.modules.load();

      // 3. Get the [contentTrack] and it's parent [courseTrack] for the content
      final contentTrack = await ContentTrackRepo.filter.uidEqualTo(content.uid).findFirst();
      final courseTrack = contentTrack == null ? null : await isar.courseTracks.getByUid(contentTrack.courseId);

      double? newProgress;

      if (courseTrack != null) {
        // ... Load the Iterable contentTracks in the courseTrack and remove the one for the content we're deleting
        await courseTrack.contentTracks.load();
        courseTrack.contentTracks.remove(contentTrack);

        // 4. Recalculate progress after removing the content track
        if (courseTrack.contentTracks.isNotEmpty) {
          newProgress = ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks);
        }
      }

      module.contents.remove(content);

      await isar.writeTxn(() async {
        await isar.moduleContents.delete(content.id);

        await isar.modules.put(module);

        if (courseTrack != null && contentTrack != null) {
          await isar.contentTracks.delete(contentTrack.id);

          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
        }
      });

      await isar.writeTxn(() async {
        await module.contents.save();
        if (courseTrack != null && contentTrack != null) {
          await courseTrack.contentTracks.save();
        }
      });
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  static Future<bool> addContent(String moduleId, ModuleContent content) => addMultipleContents(moduleId, [content]);

  static Future<bool> addMultipleContents(String collectionId, List<ModuleContent> contents) async {
    if (contents.isEmpty) return false;

    final module = await ModuleRepo.getByUid(collectionId);
    if (module == null) return false;
    final course = await _getCollectionParent(module);
    if (course == null) return false;

    final courseTrack = await CourseTrackRepo.getByUid(course.uid);
    if (courseTrack == null) {
      log("Couldn't find the parent course Track");
      return false;
    }

    await module.contents.load();
    await courseTrack.contentTracks.load();

    final contentTracks = contents
        .map(
          (content) => ContentTrack.create(
            uid: content.uid,
            courseId: course.uid,
            title: content.title,
            type: content.type,
            description: content.description,
            progress: 0.0,
            thumbnail: content.metadata?.thumbnail,
          ),
        )
        .toList();

    module.contents.addAll(contents);
    courseTrack.contentTracks.addAll(contentTracks);

    final newProgress = courseTrack.contentTracks.isNotEmpty
        ? ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks)
        : 0.0;

    await isar.writeTxn(() async {
      await isar.moduleContents.putAll(contents);
      await isar.contentTracks.putAll(contentTracks);

      await isar.modules.put(module);
      await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
    });

    await isar.writeTxn(() async {
      await module.contents.save();
      await courseTrack.contentTracks.save();
    });

    log("Successfully added multiple contents");
    return true;
  }

  static ModuleContent _cloneContentForCollection(ModuleContent content, String collectionId) {
    return ModuleContent.create(
      contentId: const Uuid().v4(),
      xxh3Hash: content.xxh3Hash,
      title: content.title,
      description: content.description,
      path: content.path.copyWith(),
      type: content.type,
      parentId: collectionId,
      fileSizeInBytes: content.fileSizeInBytes,
      metadata: content.metadata?.copyWith(thumbnail: content.metadata?.thumbnail?.copyWith()),
      createdAt: content.createdAt,
      lastModified: content.lastModified,
    );
  }

  static Future<bool> copyModuleContents(String collectionId, List<ModuleContent> contents) async {
    if (collectionId.isEmpty || contents.isEmpty) return false;

    if (await ModuleRepo.getByUid(collectionId) == null) return false;

    log('[copyModuleContents] start collection=$collectionId count=${contents.length}');

    final Map<String, ModuleContent> inputByUid = {
      for (final content in contents)
        if (content.uid.isNotEmpty) content.uid: content,
    };
    if (inputByUid.isEmpty) return false;

    final List<ModuleContent> contentsToCopy = [];
    for (final entry in inputByUid.entries) {
      final sourceContent = await getByUid(entry.key) ?? entry.value;
      contentsToCopy.add(_cloneContentForCollection(sourceContent, collectionId));
    }

    log('[copyModuleContents] cloned count=${contentsToCopy.length}');

    return addMultipleContents(collectionId, contentsToCopy);
  }

  static Future<bool> deleteMultipleContents(String collectionId, List<ModuleContent> contents) async {
    if (collectionId.isEmpty || contents.isEmpty) return false;

    log('[deleteMultipleContents] start collection=$collectionId count=${contents.length}');

    final targetCollection = await ModuleRepo.getByUid(collectionId);
    if (targetCollection == null) return false;

    try {
      await targetCollection.contents.load();

      // Deduplicate early so each uid is processed at most once.
      final Map<String, ModuleContent> inputByUid = {
        for (final content in contents)
          if (content.uid.isNotEmpty) content.uid: content,
      };
      if (inputByUid.isEmpty) return false;

      final Map<String, ModuleContent> resolvedByUid = {};
      for (final uid in inputByUid.keys) {
        final dbContent = await getByUid(uid);
        resolvedByUid[uid] = dbContent ?? inputByUid[uid]!;
      }

      final List<ModuleContent> sameParentContents = [];
      final Map<String, List<ModuleContent>> otherContentsByParent = {};
      for (final content in resolvedByUid.values) {
        if (content.parentId == collectionId) {
          sameParentContents.add(content);
        } else {
          otherContentsByParent.putIfAbsent(content.parentId, () => []).add(content);
        }
      }

      final Map<String, Module> moduleByUid = {collectionId: targetCollection};
      for (final parentId in otherContentsByParent.keys) {
        final sourceCollection = await ModuleRepo.getByUid(parentId);
        if (sourceCollection == null) continue;
        await sourceCollection.contents.load();
        moduleByUid[parentId] = sourceCollection;
      }

      final Set<String> toDeleteUids = resolvedByUid.keys.toSet();
      final Set<String> affectedCourseIds = moduleByUid.values
          .map((m) => m.parentId)
          .where((id) => id.isNotEmpty)
          .toSet();
      final Map<String, CourseTrack> affectedCourseTracks = {};
      for (final courseId in affectedCourseIds) {
        final courseTrack = await CourseTrackRepo.getByUid(courseId);
        if (courseTrack == null) continue;
        await courseTrack.contentTracks.load();
        affectedCourseTracks[courseId] = courseTrack;
      }

      if (sameParentContents.isNotEmpty) {
        targetCollection.contents.removeWhere((c) => toDeleteUids.contains(c.uid));
      }
      for (final entry in otherContentsByParent.entries) {
        final sourceCollection = moduleByUid[entry.key];
        if (sourceCollection == null) continue;
        final parentUids = entry.value.map((c) => c.uid).toSet();
        sourceCollection.contents.removeWhere((c) => parentUids.contains(c.uid));
      }

      for (final courseTrack in affectedCourseTracks.values) {
        courseTrack.contentTracks.removeWhere((t) => toDeleteUids.contains(t.uid));
      }

      await isar.writeTxn(() async {
        log('[deleteMultipleContents] writeTxn begin deleteCount=${toDeleteUids.length}');
        await isar.moduleContents.deleteAllByUid(toDeleteUids.toList());
        await isar.contentTracks.deleteAllByUid(toDeleteUids.toList());

        for (final module in moduleByUid.values) {
          await isar.modules.put(module);
        }

        for (final courseTrack in affectedCourseTracks.values) {
          final newProgress = courseTrack.contentTracks.isNotEmpty
              ? ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks)
              : 0.0;
          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
        }
        log('[deleteMultipleContents] writeTxn end');
      });

      await isar.writeTxn(() async {
        for (final module in moduleByUid.values) {
          await module.contents.save();
        }
        for (final courseTrack in affectedCourseTracks.values) {
          await courseTrack.contentTracks.save();
        }
      });

      log("Successfully deleted ${toDeleteUids.length} contents from collection $collectionId and related collections");
      return true;
    } catch (e, st) {
      log("Error deleting multiple contents: $e\n$st");
      return false;
    }
  }

  // AI GENERATED CODE - BEGIN
  static Future<bool> moveContents(List<ModuleContent> contents, String targetCollectionId) async {
    if (contents.isEmpty || targetCollectionId.isEmpty) return false;

    log('[moveContents] start targetCollection=$targetCollectionId count=${contents.length}');

    final targetCollection = await ModuleRepo.getByUid(targetCollectionId);
    if (targetCollection == null) return false;
    final targetCourse = await _getCollectionParent(targetCollection);
    if (targetCourse == null) return false;

    try {
      await targetCollection.contents.load();
      log('[moveContents] targetCollection loaded');

      final targetCourseTrack = await CourseTrackRepo.getByUid(targetCourse.uid);
      if (targetCourseTrack == null) {
        log("Couldn't find the target course track");
        return false;
      }
      await targetCourseTrack.contentTracks.load();
      log('[moveContents] targetCourseTrack loaded count=${targetCourseTrack.contentTracks.length}');

      // Deduplicate requested move list by uid and resolve latest db entities.
      final Map<String, ModuleContent> inputByUid = {
        for (final content in contents)
          if (content.uid.isNotEmpty) content.uid: content,
      };
      if (inputByUid.isEmpty) return false;

      final Map<String, ModuleContent> resolvedByUid = {};
      for (final uid in inputByUid.keys) {
        final dbContent = await getByUid(uid);
        resolvedByUid[uid] = dbContent ?? inputByUid[uid]!;
      }

      final Map<String, Module> sourceCollectionsByUid = {};
      final Map<String, CourseTrack> sourceCourseTracksByUid = {};
      final List<ModuleContent> contentsToPersist = [];
      final List<ContentTrack> tracksToPersist = [];

      for (final content in resolvedByUid.values) {
        // Skip no-op moves.
        if (content.parentId == targetCollectionId) continue;

        final sourceCollection =
            sourceCollectionsByUid[content.parentId] ?? await ModuleRepo.getByUid(content.parentId);
        if (sourceCollection == null) continue;
        if (!sourceCollectionsByUid.containsKey(sourceCollection.uid)) {
          await sourceCollection.contents.load();
          sourceCollectionsByUid[sourceCollection.uid] = sourceCollection;
        }

        final sourceCourseTrack =
            sourceCourseTracksByUid[sourceCollection.parentId] ??
            await CourseTrackRepo.getByUid(sourceCollection.parentId);
        if (sourceCourseTrack != null && !sourceCourseTracksByUid.containsKey(sourceCourseTrack.uid)) {
          await sourceCourseTrack.contentTracks.load();
          sourceCourseTracksByUid[sourceCourseTrack.uid] = sourceCourseTrack;
        }

        // Remove from source module links.
        sourceCollection.contents.removeWhere((c) => c.uid == content.uid);

        // Move to target module.
        content.parentId = targetCollectionId;
        targetCollection.contents.removeWhere((c) => c.uid == content.uid);
        targetCollection.contents.add(content);
        contentsToPersist.add(content);

        // Move linked reading progress to target course track when present.
        final contentTrack = await ContentTrackRepo.getByContentId(content.uid);
        if (contentTrack != null) {
          final sourceTrack = sourceCourseTracksByUid[contentTrack.courseId];
          sourceTrack?.contentTracks.removeWhere((t) => t.uid == content.uid);

          contentTrack.courseId = targetCourse.uid;
          targetCourseTrack.contentTracks.removeWhere((t) => t.uid == content.uid);
          targetCourseTrack.contentTracks.add(contentTrack);
          tracksToPersist.add(contentTrack);
        }
      }

      if (contentsToPersist.isEmpty) return false;

      log('[moveContents] persisting count=${contentsToPersist.length}');

      await isar.writeTxn(() async {
        log('[moveContents] writeTxn begin');
        await isar.moduleContents.putAll(contentsToPersist);
        if (tracksToPersist.isNotEmpty) {
          await isar.contentTracks.putAll(tracksToPersist);
        }

        for (final sourceCollection in sourceCollectionsByUid.values) {
          await isar.modules.put(sourceCollection);
        }

        await isar.modules.put(targetCollection);

        for (final sourceCourseTrack in sourceCourseTracksByUid.values) {
          final newProgress = sourceCourseTrack.contentTracks.isNotEmpty
              ? ContentTrackRepo.computeProgressForMultiple(sourceCourseTrack.contentTracks)
              : 0.0;
          await isar.courseTracks.put(sourceCourseTrack.copyWith(progress: newProgress));
        }

        final targetProgress = targetCourseTrack.contentTracks.isNotEmpty
            ? ContentTrackRepo.computeProgressForMultiple(targetCourseTrack.contentTracks)
            : 0.0;
        await isar.courseTracks.put(targetCourseTrack.copyWith(progress: targetProgress));
        log('[moveContents] writeTxn end');
      });

      await isar.writeTxn(() async {
        for (final sourceCollection in sourceCollectionsByUid.values) {
          await sourceCollection.contents.save();
        }
        await targetCollection.contents.save();
        for (final sourceCourseTrack in sourceCourseTracksByUid.values) {
          await sourceCourseTrack.contentTracks.save();
        }
        await targetCourseTrack.contentTracks.save();
      });

      log("Successfully moved ${contentsToPersist.length} contents to collection $targetCollectionId");
      return true;
    } catch (e, st) {
      log("Error moving contents: $e\n$st");
      return false;
    }
  }

  static Future<Course?> _getCollectionParent(Module collection) async =>
      (collection.parentId.isEmpty || collection.uid.isEmpty) ? null : CourseRepo.getCourseByUid(collection.parentId);
}
