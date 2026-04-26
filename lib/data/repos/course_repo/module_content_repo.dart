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

  static Future<ModuleContent?> getByContentId(String contentId) async =>
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

        await module.contents.save();
        await isar.modules.put(module);

        if (courseTrack != null && contentTrack != null) {
          await isar.contentTracks.delete(contentTrack.id);

          await courseTrack.contentTracks.save();
          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
        }
      });
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

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
            description: content.description,
            progress: 0.0,
            thumbnail: content.path.copyWith(),
          ),
        )
        .toList();

    // Calculate new course progress before adding the new content tracks
    //(Progress should still remain the same since the new content tracks aren't really adding anything. Just accuracy update)
    final newProgress = ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks);

    module.contents.addAll(contents);
    courseTrack.contentTracks.addAll(contentTracks);
    await isar.writeTxn(() async {
      await isar.moduleContents.putAll(contents);
      await isar.contentTracks.putAll(contentTracks);
      await module.contents.save();
      await courseTrack.contentTracks.save();

      await isar.modules.put(module);
      await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
    });

    log("Successfully added multiple contents");
    return true;
  }

  static Future<bool> deleteMultipleContents(String collectionId, List<ModuleContent> contents) async {
    if (collectionId.isEmpty || contents.isEmpty) return false;

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
        final dbContent = await getByContentId(uid);
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
          await module.contents.save();
          await isar.modules.put(module);
        }

        for (final courseTrack in affectedCourseTracks.values) {
          final newProgress = courseTrack.contentTracks.isNotEmpty
              ? ContentTrackRepo.computeProgressForMultiple(courseTrack.contentTracks)
              : 0.0;
          await courseTrack.contentTracks.save();
          await isar.courseTracks.put(courseTrack.copyWith(progress: newProgress));
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

    final collection = await ModuleRepo.getByUid(targetCollectionId);
    if (collection == null) return false;
    final course = await _getCollectionParent(collection);
    if (course == null) return false;

    try {
      await collection.contents.load();

      // Get target course track
      final targetCourseTrack = await (CourseTrackRepo.filter).uidEqualTo(course.uid).findFirst();
      if (targetCourseTrack == null) {
        log("Couldn't find the target course track");
        return false;
      }
      await targetCourseTrack.contentTracks.load();

      // Group contents by their source collection to optimize updates
      final Map<int, Module> sourceCollections = {};
      final Map<String, CourseTrack> sourceCourseTracksMap = {};
      final List<ContentTrack> contentTracksToUpdate = [];

      for (final content in contents) {
        // Skip if content is already in target collection
        if (content.parentId == targetCollectionId) continue;

        // Get source collection
        final sourceCollection = await isar.modules.filter().uidEqualTo(content.parentId).findFirst();
        if (sourceCollection == null) continue;

        await sourceCollection.contents.load();
        sourceCollections[sourceCollection.id] = sourceCollection;

        // Get source course for this collection
        final sourceCourse = await CourseRepo.getCourseByUid(sourceCollection.parentId);
        if (sourceCourse == null) continue;

        // Get or cache source course track
        if (!sourceCourseTracksMap.containsKey(sourceCourse.uid)) {
          final sourceCourseTrack = await (CourseTrackRepo.filter).uidEqualTo(sourceCourse.uid).findFirst();
          if (sourceCourseTrack != null) {
            await sourceCourseTrack.contentTracks.load();
            sourceCourseTracksMap[sourceCourse.uid] = sourceCourseTrack;
          }
        }

        // Find and prepare content track for move
        final contentTrack = await (ContentTrackRepo.filter).uidEqualTo(content.uid).findFirst();
        if (contentTrack != null) {
          contentTracksToUpdate.add(contentTrack.copyWith(uid: course.uid));
        }
      }
      for (final content in contents) {
        if (content.parentId == targetCollectionId) continue;

        // Remove from source collection
        final sourceCollection = sourceCollections.values.firstWhere(
          (col) => col.contents.any((c) => c.id == content.id),
        );
        sourceCollection.contents.remove(content);

        // Update content's parentId
        content.parentId = targetCollectionId;

        // Add to target collection
        collection.contents.add(content);
      }
      for (final updatedTrack in contentTracksToUpdate) {
        final sourceCourseTrack = sourceCourseTracksMap[updatedTrack.courseId];
        if (sourceCourseTrack != null) {
          sourceCourseTrack.contentTracks.removeWhere((t) => t.uid == updatedTrack.uid);
        }

        targetCourseTrack.contentTracks.add(updatedTrack);
      }

      // Recalculate progress for target course track
      final targetTotalProgress = targetCourseTrack.contentTracks.fold<double>(
        0.0,
        (sum, track) => sum + (track.progress),
      );
      final targetNewProgress = targetCourseTrack.contentTracks.isNotEmpty
          ? targetTotalProgress / targetCourseTrack.contentTracks.length
          : 0.0;
      await isar.writeTxn(() async {
        // Update content tracks and remove from source course tracks
        for (final updatedTrack in contentTracksToUpdate) {
          await isar.contentTracks.put(updatedTrack);
        }

        // Recalculate progress for source course tracks
        for (final sourceCourseTrack in sourceCourseTracksMap.values) {
          final remainingLength = sourceCourseTrack.contentTracks.length;
          final newProgress = remainingLength > 0
              ? sourceCourseTrack.contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress)) /
                    remainingLength
              : 0.0;

          await sourceCourseTrack.contentTracks.save();
          await isar.courseTracks.put(sourceCourseTrack.copyWith(progress: newProgress));
        }

        // Save all changes
        await isar.moduleContents.putAll(contents);
        for (final sourceCollection in sourceCollections.values) {
          await sourceCollection.contents.save();
          await isar.modules.put(sourceCollection);
        }

        await collection.contents.save();
        await targetCourseTrack.contentTracks.save();
        await isar.modules.put(collection);
        await isar.courseTracks.put(targetCourseTrack.copyWith(progress: targetNewProgress));
      });

      log("Successfully moved ${contents.length} contents to collection $targetCollectionId");
      return true;
    } catch (e) {
      log("Error moving contents: $e");
      return false;
    }
  }

  static Future<Course?> _getCollectionParent(Module collection) async =>
      (collection.parentId.isEmpty || collection.uid.isEmpty) ? null : CourseRepo.getCourseByUid(collection.parentId);
}
