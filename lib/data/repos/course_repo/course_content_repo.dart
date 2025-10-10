import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class CourseContentRepo {
  static final IsarData<CourseContent> _isarData = IsarData.instance<CourseContent>();
  static Future<Isar> get _isar async => await IsarData.isarFuture;
  static IsarData<CourseContent> get isarData => _isarData;
  static Future<Isar> get isar async => await IsarData.isarFuture;

  // static Future<QueryBuilder<CourseContent, CourseContent, QAfterFilterCondition>> _queryById(
  //   String contentHash,
  // ) async {
  //   return (await _isarData.query<CourseContent>((q) => q.idGreaterThan(0))).filter().contentHashEqualTo(contentHash);
  // }

  static Future<QueryBuilder<CourseContent, CourseContent, QFilterCondition>> get filter async =>
      (await _isar).courseContents.filter();

  static Future<void> deleteByDbId(int dbId) async => await _isarData.deleteById(dbId);

  static Future<CourseContent?> getByDbId(int dbId) => _isarData.getById(dbId);

  static Stream<CourseContent?> watchByDbId(int dbId) => _isarData.watchById(dbId);

  static Future<int> add(CourseContent content) async => await _isarData.store(content);

  static Future<List<CourseContent>> getAll() async => _isarData.getAll();

  static Stream<List<CourseContent>> watchAll() => _isarData.watchAll();

  // static Future<Stream<List<CourseContent>>> watchAllLazily() async => await _isarData.watchAllLazily();

  static Future<CourseContent?> getByContentId(String contentId) async =>
      await (await _isar).courseContents.where().contentIdEqualTo(contentId).findFirst();

  static Future<CourseContent?> getByHash(String contentHash) async {
    return await (await _isar).courseContents.filter().contentHashEqualTo(contentHash).findFirst();
  }

  static Future<bool> doesDuplicateHashExists(String contentHash) async {
    return (await (await _isar).courseContents.filter().contentHashEqualTo(contentHash).limit(2).findAll()).length > 1;
  }

  // static Future<CourseContent?> deleteByHash(String contentHash) async {
  //   final isar = await _isar;
  //   final CourseContent? collection = await getByHash(contentHash);
  //   return await isar.writeTxn<CourseContent?>(() async {
  //     if (collection != null) {
  //       final idQuery = await _queryById(contentHash);
  //       await idQuery.deleteFirst();
  //     }
  //     return collection;
  //   });
  // }

  /// Gets Duplicate Coursecontents, or contents with same hash
  static Future<List<CourseContent>> findAllDuplicatesByHash(String contentHash) async {
    return await (await _isar).courseContents.filter().contentHashEqualTo(contentHash).findAll();
  }

  static Future<CourseContent?> findFirstDuplicateContentByHash(CourseCollection collection, String contentHash) async {
    await collection.contents.load();
    return (collection.contents.where((content) => content.contentHash == contentHash)).firstOrNull;
  }

  // Check
  static Future<bool> addContent(CourseContent content, [CourseCollection? collection]) async {
    if (content.parentId.isEmpty) return false;
    final result = await Result.tryRunAsync<bool>(() async {
      final isar = (await _isar);

      final fetchResult = await _fetchCourseAndCollection(isar, collection, content.parentId);
      final getCollection = fetchResult.$2;
      final course = fetchResult.$1;

      if (getCollection == null || course == null) return false;

      await getCollection.contents.load();

      final contentTrack = ContentTrack.create(
        contentId: content.contentId,
        parentId: course.courseId,
        contentHash: content.contentHash,
        title: content.title,
        description: content.description,
        progress: 0.0,
      );
      final courseTrack = await (await CourseTrackRepo.filter).courseIdEqualTo(contentTrack.parentId).findFirst();
      if (courseTrack == null) {
        log("Couldn't find the parent course Track");
        return false;
      }
      await courseTrack.contentTracks.load();

      // Calculate new course progress before adding the new content track
      final currentTotalProgress = courseTrack.contentTracks.fold<double>(
        0.0,
        (sum, track) => sum + (track.progress ?? 0.0),
      );
      final newContentsLength = courseTrack.contentTracks.length + 1;
      final newCourseProgress = currentTotalProgress / newContentsLength;

      courseTrack.contentTracks.add(contentTrack);
      await isar.writeTxn(() async {
        await isar.courseContents.put(content);
        await isar.contentTracks.put(contentTrack);
        await getCollection.contents.save();
        await courseTrack.contentTracks.save();
        await isar.courseCollections.put(getCollection);
        await isar.courseTracks.put(courseTrack.copyWith(progress: newCourseProgress));
      });
      log("Successfully added content!");
      return true;
    });

    return result.data ?? false;
  }

  // Check
  static Future<bool> deleteContent(CourseContent content, [CourseCollection? collection]) async {
    try {
      final isar = (await _isar);

      final fetchResult = await _fetchCourseAndCollection(isar, collection, content.parentId);
      final getCollection = fetchResult.$2;
      final course = fetchResult.$1;

      if (getCollection == null || course == null) return false;

      await getCollection.contents.load();
      await course.collections.load();
      final contentTrackQuery = (await ContentTrackRepo.filter).contentIdEqualTo(content.contentId);
      final contentTrack = await contentTrackQuery.findFirst();
      CourseTrack? parentCourseTrack = contentTrack == null
          ? null
          : await isar.courseTracks.getByCourseId(contentTrack.parentId);

      double newProgress = 0.0;

      if (contentTrack != null && parentCourseTrack != null) {
        await parentCourseTrack.contentTracks.load();
        parentCourseTrack.contentTracks.remove(contentTrack);

        // Recalculate progress after removing the content track
        final remainingContentsLength = parentCourseTrack.contentTracks.length;
        if (remainingContentsLength > 0) {
          final totalProgress = parentCourseTrack.contentTracks.fold<double>(
            0.0,
            (sum, track) => sum + (track.progress ?? 0.0),
          );
          newProgress = totalProgress / remainingContentsLength;
        }
      }

      await isar.writeTxn(() async {
        getCollection.contents.remove(content);
        await getCollection.contents.save();

        await isar.courseContents.delete(content.id);
        await isar.courseCollections.put(getCollection);
        if (contentTrack != null) await isar.contentTracks.delete(contentTrack.id);
        if (parentCourseTrack != null) {
          await parentCourseTrack.contentTracks.save();
          await isar.courseTracks.put(parentCourseTrack.copyWith(progress: newProgress));
        }
      });
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  static Future<bool> addMultipleContents(String collectionId, List<CourseContent> contents) async {
    if (contents.isEmpty) return false;
    final isar = (await _isar);
    final fetchResult = await _fetchCourseAndCollection(isar, null, collectionId);
    final getCollection = fetchResult.$2;
    final course = fetchResult.$1;

    if (getCollection == null || course == null) return false;

    await getCollection.contents.load();
    final contentTracks = contents
        .map(
          (content) => ContentTrack.create(
            contentId: content.contentId,
            parentId: course.courseId,
            contentHash: content.contentHash,
            title: content.title,
            description: content.description,
            progress: 0.0,
          ),
        )
        .toList();

    final courseTrack = await (await CourseTrackRepo.filter).courseIdEqualTo(course.courseId).findFirst();
    if (courseTrack == null) {
      log("Couldn't find the parent course Track");
      return false;
    }
    await courseTrack.contentTracks.load();

    // Calculate new course progress before adding the new content tracks
    final currentTotalProgress = courseTrack.contentTracks.fold<double>(
      0.0,
      (sum, track) => sum + (track.progress ?? 0.0),
    );
    final newContentsLength = courseTrack.contentTracks.length + contentTracks.length;
    final newCourseProgress = currentTotalProgress / newContentsLength;

    getCollection.contents.addAll(contents);
    courseTrack.contentTracks.addAll(contentTracks);
    await isar.writeTxn(() async {
      await isar.courseContents.putAll(contents);
      await isar.contentTracks.putAll(contentTracks);
      await getCollection.contents.save();
      await courseTrack.contentTracks.save();
      await isar.courseCollections.put(getCollection);
      await isar.courseTracks.put(courseTrack.copyWith(progress: newCourseProgress));
    });

    log("Successfully added all multiple contents");
    return true;
  }

  // AI GENERATED CODE - BEGIN
  static Future<bool> moveContents(List<CourseContent> contents, String targetCollectionId) async {
    if (contents.isEmpty) return false;
    if (targetCollectionId.isEmpty) return false;

    try {
      final isar = await _isar;

      // Fetch target collection and its parent course
      final fetchResult = await _fetchCourseAndCollection(isar, null, targetCollectionId);
      final targetCollection = fetchResult.$2;
      final targetCourse = fetchResult.$1;

      if (targetCollection == null || targetCourse == null) return false;

      await targetCollection.contents.load();

      // Get target course track
      final targetCourseTrack = await (await CourseTrackRepo.filter).courseIdEqualTo(targetCourse.courseId).findFirst();
      if (targetCourseTrack == null) {
        log("Couldn't find the target course track");
        return false;
      }
      await targetCourseTrack.contentTracks.load();

      // Group contents by their source collection to optimize updates
      final Map<int, CourseCollection> sourceCollections = {};
      final Map<String, CourseTrack> sourceCourseTracksMap = {};
      final List<ContentTrack> contentTracksToUpdate = [];

      for (final content in contents) {
        // Skip if content is already in target collection
        if (content.parentId == targetCollectionId) continue;

        // Get source collection
        final sourceCollection = await isar.courseCollections
            .filter()
            .collectionIdEqualTo(content.parentId)
            .findFirst();
        if (sourceCollection == null) continue;

        await sourceCollection.contents.load();
        sourceCollections[sourceCollection.id] = sourceCollection;

        // Get source course for this collection
        final sourceCourse = await CourseRepo.getCourseById(sourceCollection.parentId);
        if (sourceCourse == null) continue;

        // Get or cache source course track
        if (!sourceCourseTracksMap.containsKey(sourceCourse.courseId)) {
          final sourceCourseTrack = await (await CourseTrackRepo.filter)
              .courseIdEqualTo(sourceCourse.courseId)
              .findFirst();
          if (sourceCourseTrack != null) {
            await sourceCourseTrack.contentTracks.load();
            sourceCourseTracksMap[sourceCourse.courseId] = sourceCourseTrack;
          }
        }

        // Find and prepare content track for move
        final contentTrack = await (await ContentTrackRepo.filter).contentIdEqualTo(content.contentId).findFirst();
        if (contentTrack != null) {
          contentTracksToUpdate.add(contentTrack.copyWith(parentId: targetCourse.courseId));
        }
      }

      await isar.writeTxn(() async {
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
          targetCollection.contents.add(content);
        }

        // Update content tracks and remove from source course tracks
        for (final updatedTrack in contentTracksToUpdate) {
          final sourceCourseTrack = sourceCourseTracksMap[updatedTrack.parentId];
          if (sourceCourseTrack != null) {
            sourceCourseTrack.contentTracks.removeWhere((t) => t.contentId == updatedTrack.contentId);
          }

          targetCourseTrack.contentTracks.add(updatedTrack);
          await isar.contentTracks.put(updatedTrack);
        }

        // Recalculate progress for source course tracks
        for (final sourceCourseTrack in sourceCourseTracksMap.values) {
          final remainingLength = sourceCourseTrack.contentTracks.length;
          final newProgress = remainingLength > 0
              ? sourceCourseTrack.contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress ?? 0.0)) /
                    remainingLength
              : 0.0;

          await sourceCourseTrack.contentTracks.save();
          await isar.courseTracks.put(sourceCourseTrack.copyWith(progress: newProgress));
        }

        // Recalculate progress for target course track
        final targetTotalProgress = targetCourseTrack.contentTracks.fold<double>(
          0.0,
          (sum, track) => sum + (track.progress ?? 0.0),
        );
        final targetNewProgress = targetCourseTrack.contentTracks.isNotEmpty
            ? targetTotalProgress / targetCourseTrack.contentTracks.length
            : 0.0;

        // Save all changes
        await isar.courseContents.putAll(contents);
        for (final sourceCollection in sourceCollections.values) {
          await sourceCollection.contents.save();
          await isar.courseCollections.put(sourceCollection);
        }

        await targetCollection.contents.save();
        await targetCourseTrack.contentTracks.save();
        await isar.courseCollections.put(targetCollection);
        await isar.courseTracks.put(targetCourseTrack.copyWith(progress: targetNewProgress));
      });

      log("Successfully moved ${contents.length} contents to collection $targetCollectionId");
      return true;
    } catch (e) {
      log("Error moving contents: $e");
      return false;
    }
  }
  // AI GENERATED CODE - END

  // static Future<bool> deleteAllContentsInCollection(CourseCollection collection) async {
  //   try {
  //     final isar = (await _isar);

  //     // Ensure collection contents are loaded
  //     await collection.contents.load();
  //     final contents = collection.contents.toList();
  //     if (contents.isEmpty) return true; // nothing to do

  //     final contentIds = contents.map((c) => c.id).toList();
  //     final contentIdStrings = contents.map((c) => c.contentId).toList();

  //     // Batch-find related ContentTrack entries (uses contentIdIn if available)
  //     final contentTrackFilter = await ContentTrackRepo.filter;
  //     final List<dynamic> contentTracks = await contentTrackFilter
  //         .anyOf(contentIdStrings, (s, t) => s.contentIdEqualTo(t))
  //         .findAll();

  //     // Map to hold distinct parent CourseTrack instances we must update
  //     final Map<int, dynamic> parentCourseTrackById = {};
  //     final List<int> contentTrackIdsToDelete = [];

  //     for (final ct in contentTracks) {
  //       if (ct == null) continue;
  //       contentTrackIdsToDelete.add(ct.id);
  //       final parentCourseTrack = ct.courseTrackLink.value;
  //       if (parentCourseTrack != null) {
  //         parentCourseTrackById[parentCourseTrack.id] = parentCourseTrack;
  //       }
  //     }

  //     // Load each parent courseTrack's contentTracks once, and remove the tracks belonging to this collection
  //     for (final parent in parentCourseTrackById.values) {
  //       await parent.contentTracks.load();
  //       parent.contentTracks.removeWhere((t) => contentIdStrings.contains(t.contentId));
  //     }

  //     // Single transaction to delete DB rows and persist relationship changes
  //     await isar.writeTxn(() async {
  //       // Delete contentTracks rows
  //       if (contentTrackIdsToDelete.isNotEmpty) {
  //         await isar.contentTracks.deleteAll(contentTrackIdsToDelete);
  //       }

  //       // Delete courseContents rows
  //       await isar.courseContents.deleteAll(contentIds);

  //       // Clear collection contents and persist
  //       collection.contents.clear();
  //       await collection.contents.save();
  //       await isar.courseCollections.put(collection);

  //       // Persist updates to parent course tracks' contentTracks lists
  //       for (final parent in parentCourseTrackById.values) {
  //         await parent.contentTracks.save();
  //       }
  //     });

  //     return true;
  //   } catch (e) {
  //     log("Error deleting all contents in collection: $e");
  //     return false;
  //   }
  // }

  /// Except this ofc
  static Future<(Course? course, CourseCollection? collection)> _fetchCourseAndCollection(
    Isar isar,
    CourseCollection? collection,
    String contentParentId,
  ) async {
    CourseCollection? getCollection = collection != null
        ? (await isar.courseCollections.get(collection.id))
        : (await isar.courseCollections.filter().collectionIdEqualTo(contentParentId).findFirst());
    if (getCollection == null) return (null, null);

    if (getCollection.parentId.isEmpty) return (null, null);
    final Course? course = await CourseRepo.getCourseById(getCollection.parentId);
    if (course == null) return (null, null);
    return (course, getCollection);
  }
}
