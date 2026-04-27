import 'dart:developer';

import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class ContentProgressTracker {
  Future<ContentTrack?> registerContentAccess(String contentId) async {
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return null;

    final ptm = await (ContentTrackRepo.isar).contentTracks.where().uidEqualTo(contentId).findFirst();

    if (ptm == null) {
      return await _createProgressTrackModel(content);
    } else {
      return await _updateProgressTrack(
        ptm.copyWith(
          title: content.title,
          description: content.description,
          lastRead: DateTime.now(),
          pages: ptm.pages.isEmpty ? const ["1"] : ptm.pages,
          thumbnail: content.metadata?.thumbnail ?? ptm.thumbnail,
        ),
      );
    }
  }

  Future<ContentTrack?> _createProgressTrackModel(ModuleContent content) async {
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
        pages: const ["1"],
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
}
