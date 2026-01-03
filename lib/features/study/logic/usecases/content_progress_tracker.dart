import 'dart:convert';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ContentProgressTracker {
  Future<ContentTrack?> registerContentAccess(String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return null;

    final ptm = await (await ContentTrackRepo.isar).contentTracks.where().contentIdEqualTo(contentId).findFirst();

    if (ptm == null) {
      return await _createProgressTrackModel(content);
    } else {
      return await _updateProgressTrack(
        ptm.copyWith(
          title: content.title,
          description: content.description,
          lastRead: DateTime.now(),
          pages: ptm.pages.isEmpty ? const ["1"] : ptm.pages,
          metadataJson: jsonEncode(<String, dynamic>{
            ...ptm.metadataJson.decodeJson,
            'previewPath': content.thumbnailPath,
          }),
        ),
      );
    }
  }

  Future<ContentTrack?> _createProgressTrackModel(CourseContent content) async {
    log("Creating progress track model");
    final result = await Result.tryRunAsync<ContentTrack?>(() async {
      final courseId = (await CourseCollectionRepo.getById(content.parentId))?.parentId;
      if (courseId == null) return null;

      final parentId = (await CourseTrackRepo.getByCourseId(courseId))?.courseId;
      if (parentId == null) return null;

      final ContentTrack newPtm = ContentTrack.create(
        contentId: content.contentId,
        parentId: parentId,
        title: content.title,
        description: content.description,
        contentHash: content.contentHash,
        progress: 0.0,
        pages: const ["1"],
        lastRead: DateTime.now(),
        metadataJson: jsonEncode({'previewPath': content.thumbnailPath}),
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
