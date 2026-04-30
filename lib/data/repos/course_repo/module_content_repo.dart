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

  static Future<ModuleContent?> getByUid(String contentId) async => await _isar.moduleContents.getByUid(contentId);
  static Future<List<ModuleContent?>> getAllByUids(List<String> contentIds) async =>
      await _isar.moduleContents.getAllByUid(contentIds);

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

  static Future<bool> deleteContent(ModuleContent content, [Module? collection]) async {
    try {
      final module = collection ?? await ModuleRepo.getByUid(content.parentId);
      if (module == null) return false;

      final course = await _getCollectionParent(module);
      if (course == null) return false;

      await module.contents.load();
      module.contents.remove(content);

      final contentTrack = await ContentTrackRepo.filter.uidEqualTo(content.uid).findFirst();
      final courseTrack = contentTrack == null ? null : await isar.courseTracks.getByUid(contentTrack.courseId);

      double? newProgress;
      if (courseTrack != null) {
        await courseTrack.contentTracks.load();
        courseTrack.contentTracks.remove(contentTrack);
        if (courseTrack.contentTracks.isNotEmpty) {
          newProgress = ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks);
        }
      }

      await isar.writeTxn(() async {
        await isar.moduleContents.delete(content.id);
        await isar.modules.put(module);
        await module.contents.save();
        if (courseTrack != null && contentTrack != null) {
          await isar.contentTracks.delete(contentTrack.id);
          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
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

    final newProgress = ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks);

    await isar.writeTxn(() async {
      await isar.moduleContents.putAll(contents);
      await isar.contentTracks.putAll(contentTracks);
      await isar.modules.put(module);
      await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
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
        await isar.moduleContents.deleteAllByUid(toDeleteUids.toList());
        await isar.contentTracks.deleteAllByUid(toDeleteUids.toList());

        for (final module in moduleByUid.values) {
          await isar.modules.put(module);
          await module.contents.save();
        }

        for (final courseTrack in affectedCourseTracks.values) {
          final newProgress = courseTrack.contentTracks.isNotEmpty
              ? ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks)
              : 0.0;
          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
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

  static Future<bool> moveContents(List<ModuleContent> contents, String targetCollectionId) async {
    if (contents.isEmpty || targetCollectionId.isEmpty) return false;

    final targetCollection = await ModuleRepo.getByUid(targetCollectionId);
    if (targetCollection == null) return false;

    final targetCourse = await _getCollectionParent(targetCollection);
    if (targetCourse == null) return false;

    final targetCourseTrack = await CourseTrackRepo.getByUid(targetCourse.uid);
    if (targetCourseTrack == null) {
      log("Couldn't find the target course track");
      return false;
    }

    try {
      await targetCollection.contents.load();
      await targetCourseTrack.contentTracks.load();

      // Deduplicate by uid
      final inputByUid = <String, ModuleContent>{
        for (final c in contents)
          if (c.uid.isNotEmpty) c.uid: c,
      };
      if (inputByUid.isEmpty) return false;

      // Resolve latest db entities
      final resolvedByUid = <String, ModuleContent>{};
      for (final uid in inputByUid.keys) {
        resolvedByUid[uid] = await getByUid(uid) ?? inputByUid[uid]!;
      }

      // Load source collections and course tracks
      final sourceCollectionsByUid = <String, Module>{};
      final sourceCourseTracksByUid = <String, CourseTrack>{};

      for (final content in resolvedByUid.values) {
        if (content.parentId == targetCollectionId) continue; // skip no-ops

        if (!sourceCollectionsByUid.containsKey(content.parentId)) {
          final src = await ModuleRepo.getByUid(content.parentId);
          if (src != null) {
            await src.contents.load();
            sourceCollectionsByUid[src.uid] = src;
          }
        }

        final src = sourceCollectionsByUid[content.parentId];
        if (src != null && !sourceCourseTracksByUid.containsKey(src.parentId)) {
          final srcTrack = await CourseTrackRepo.getByUid(src.parentId);
          if (srcTrack != null) {
            await srcTrack.contentTracks.load();
            sourceCourseTracksByUid[srcTrack.uid] = srcTrack;
          }
        }
      }

      // Sets for O(1) dedup on target
      final targetContentUidSet = targetCollection.contents.map((c) => c.uid).toSet();
      final targetTrackUidSet = targetCourseTrack.contentTracks.map((t) => t.uid).toSet();

      final contentsToPersist = <ModuleContent>[];
      final tracksToPersist = <ContentTrack>[];

      for (final content in resolvedByUid.values) {
        if (content.parentId == targetCollectionId) continue;

        final sourceCollection = sourceCollectionsByUid[content.parentId];
        if (sourceCollection == null) continue;

        // Remove from source
        sourceCollection.contents.removeWhere((c) => c.uid == content.uid);

        // Add to target (deduped)
        content.parentId = targetCollectionId;
        if (targetContentUidSet.add(content.uid)) {
          targetCollection.contents.add(content);
          contentsToPersist.add(content);
        }

        // Move content track
        final contentTrack = await ContentTrackRepo.getByContentId(content.uid);
        if (contentTrack != null) {
          sourceCourseTracksByUid[contentTrack.courseId]?.contentTracks.removeWhere((t) => t.uid == contentTrack.uid);

          contentTrack.courseId = targetCourse.uid;
          if (targetTrackUidSet.add(contentTrack.uid)) {
            targetCourseTrack.contentTracks.add(contentTrack);
            tracksToPersist.add(contentTrack);
          }
        }
      }

      if (contentsToPersist.isEmpty) return false;

      log('[moveContents] persisting count=${contentsToPersist.length}');

      await isar.writeTxn(() async {
        await isar.moduleContents.putAll(contentsToPersist);

        if (tracksToPersist.isNotEmpty) {
          await isar.contentTracks.putAll(tracksToPersist);
        }

        for (final src in sourceCollectionsByUid.values) {
          await isar.modules.put(src);
          await src.contents.save();
        }

        await isar.modules.put(targetCollection);
        await targetCollection.contents.save();

        for (final srcTrack in sourceCourseTracksByUid.values) {
          final newProgress = srcTrack.contentTracks.isNotEmpty
              ? ContentTrackRepo.computeProgressForMultiple(srcTrack.contentTracks)
              : 0.0;
          await isar.courseTracks.put(srcTrack.copyWith(progress: newProgress));
          await srcTrack.contentTracks.save();
        }

        final targetProgress = targetCourseTrack.contentTracks.isNotEmpty
            ? ContentTrackRepo.computeProgressForMultiple(targetCourseTrack.contentTracks)
            : 0.0;
        await isar.courseTracks.put(targetCourseTrack.copyWith(progress: targetProgress));
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
      (collection.parentId.isEmpty || collection.uid.isEmpty) ? null : CourseRepo.getByUid(collection.parentId);
}
