import 'dart:developer';

import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class ProgressTracker {
  static Future<ContentTrack?> registerContentAccess(String contentId, {List<String> addPages = const []}) async {
    final tracker = ProgressTracker();
    return tracker._registerContentAccess(contentId, addPages: addPages);
  }

  static Future<ContentTrack?> getLastTrack(String contentId, {List<String> defaultPages = const []}) async {
    final tracker = ProgressTracker();
    return tracker._getLastTrack(contentId, defaultPages: defaultPages);
  }

  static Future<ContentTrack?> saveTrack(ContentTrack ptm) async {
    final tracker = ProgressTracker();
    return tracker._updateProgressTrack(ptm);
  }

  static Future<void> updateCourseTrackProgress(String contentId) async {
    final tracker = ProgressTracker();
    await tracker._updateCourseTrackProgress(contentId);
  }

  Future<ContentTrack?> _registerContentAccess(String contentId, {List<String> addPages = const []}) async {
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return null;

    final ptm = await ContentTrackRepo.getByContentId(contentId);

    if (ptm == null) {
      return await _createProgressTrackModel(content, defaultPages: addPages);
    } else {
      final effectivePages = addPages.isNotEmpty ? addPages : (ptm.pages.isEmpty ? const ["1"] : ptm.pages);
      return await _updateProgressTrack(
        ptm.copyWith(
          title: content.title,
          description: content.description,
          lastRead: DateTime.now(),
          pages: effectivePages,
          thumbnail: content.metadata?.thumbnail ?? ptm.thumbnail,
        ),
      );
    }
  }

  Future<ContentTrack?> _getLastTrack(String contentId, {List<String> defaultPages = const []}) async {
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return null;

    final ptm = await ContentTrackRepo.getByContentId(contentId);

    if (ptm == null) {
      return await _createProgressTrackModel(content, defaultPages: defaultPages);
    }

    return await _updateProgressTrack(
      ptm.copyWith(
        title: content.title,
        description: content.description,
        lastRead: DateTime.now(),
        pages: ptm.pages.isEmpty ? (defaultPages.isNotEmpty ? defaultPages : const ["1"]) : ptm.pages,
        thumbnail: content.metadata?.thumbnail ?? ptm.thumbnail,
      ),
    );
  }

  Future<ContentTrack?> _createProgressTrackModel(ModuleContent content, {List<String> defaultPages = const []}) async {
    log("Creating progress track model");
    final result = await Result.tryRunAsync<ContentTrack?>(() async {
      final courseId = (await ModuleRepo.getByUid(content.parentId))?.parentId;
      if (courseId == null) return null;

      final parentId = (await CourseTrackRepo.getByUid(courseId))?.uid;
      if (parentId == null) return null;

      final ContentTrack newPtm = ContentTrack.create(
        uid: content.uid,
        courseId: parentId,
        title: content.title,
        type: content.type,
        description: content.description,
        progress: 0.0,
        pages: defaultPages.isNotEmpty ? defaultPages : const ["1"],
        thumbnail: content.metadata?.thumbnail,
      );

      return await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(newPtm));
    });
    return result.data;
  }

  Future<ContentTrack> _updateProgressTrack(ContentTrack ptm) async {
    log("Updating progress track model");
    return await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(ptm)) ?? ptm;
  }

  Future<void> _updateCourseTrackProgress(String contentId) async {
    final ptm = await ContentTrackRepo.getByContentId(contentId);
    if (ptm == null) return;

    final courseTrack = await CourseTrackRepo.getByUid(ptm.courseId);
    if (courseTrack == null) return;

    await courseTrack.contentTracks.load();
    final contentsLength = courseTrack.contentTracks.length;
    if (contentsLength == 0) return;

    final totalProgress = courseTrack.contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress));

    final newProgress = totalProgress / contentsLength;
    await CourseTrackRepo.isarData.store(courseTrack.copyWith(progress: newProgress));
  }
}
