import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/progress_track_models/content_track.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/domain/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/domain/repos/course_track_repo/course_track_repo.dart';

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

  static Future<int> add(CourseContent content) async {
    final existingContentTrack = await (await ContentTrackRepo.filter).contentIdEqualTo(content.contentId).findFirst();
    if (existingContentTrack == null) {
      final collection = await CourseCollectionRepo.getById(content.parentId);
      if (collection == null) return -1;
      final parentCourseTrack = await CourseTrackRepo.getByCourseId(collection.parentId);
      if (parentCourseTrack == null) return -1;
      final newContentTrack = ContentTrack.create(
        contentId: content.contentId,
        contentHash: content.contentHash,
        title: content.title,
        description: content.description,
      );
      newContentTrack.courseTrackLink.value = parentCourseTrack;
      await ContentTrackRepo.isarData.store(newContentTrack);
    }
    return await _isarData.store(content);
  }

  static Future<List<CourseContent>> getAll() async => _isarData.getAll();

  static Stream<List<CourseContent>> watchAll() => _isarData.watchAll();

  static Future<Stream<List<CourseContent>>> watchAllLazily() async => await _isarData.watchAllLazily();

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
      final addContentRes = await add(content);
      if (addContentRes == -1) return false;

      await getCollection.contents.load();
      // // Load collections from the course
      await course.collections.load();
      //Add content to the collection
      getCollection.contents.add(content);

      await isar.writeTxn(() async {
        await getCollection.contents.save();
        await isar.courseCollections.put(getCollection);
      });

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
      final parentCourseTrack = contentTrack?.courseTrackLink.value;
      if (parentCourseTrack != null) {
        await parentCourseTrack.contentTracks.load();
        parentCourseTrack.contentTracks.remove(contentTrack);
      }
      await isar.writeTxn(() async {
        getCollection.contents.remove(content);
        await getCollection.contents.save();

        await isar.courseContents.delete(content.id);
        await isar.courseCollections.put(getCollection);
        if (contentTrack != null) {
          final parentCourseTrack = contentTrack.courseTrackLink.value;
          if (parentCourseTrack != null) {
            await parentCourseTrack.contentTracks.save();
          }
          await isar.contentTracks.delete(contentTrack.id);
        }
      });
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  // static Future<bool> deleteAllContents(CourseCollection collection) async {
  //   try {
  //     final isar = await _isar;
  //     await collection.contents.load();

  //     final contentIds = collection.contents.map((c) => c.id).toList();
  //     await isar.writeTxn(() async {
  //       await isar.courseContents.deleteAll(contentIds);
  //       collection.contents.clear();
  //       await collection.contents.save();
  //       await isar.courseCollections.put(collection);
  //     });

  //     return true;
  //   } catch (e) {
  //     log("Error deleting all contents: $e");
  //     return false;
  //   }
  // }

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
