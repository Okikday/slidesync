import 'dart:convert';

import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/main/presentation/home/actions/recent_dialog_actions.dart';

class ModifyContentUc {
  Future<String?> deleteContent(CourseContent content) async {
    final bool dupHashExists = await CourseContentRepo.doesDuplicateHashExists(content.contentHash);
    await CourseContentRepo.deleteContent(content);
    await RecentDialogActions.removeIdFromRecents(content.contentId);
    await ContentTrackRepo.deleteByContentId(content.contentId);

    if (!dupHashExists) {
      await FileUtils.deleteFileAtPath(content.path.filePath);
      final previewPath = jsonDecode(content.metadataJson)['previewPath'];
      if (previewPath is String) await FileUtils.deleteFileAtPath(previewPath);
    }

    return null;
  }

  Future<String?> renameContent(CourseContent content, String newTitle) async {
    return (await Result.tryRunAsync(() async {
      CourseContent? stContent = await CourseContentRepo.getByDbId(content.id);
      if (stContent == null) {
        stContent = await CourseContentRepo.getByContentId(content.contentId);
        if (stContent == null) return;
      }

      await CourseContentRepo.add(stContent.copyWith(contentHash: content.contentHash, title: newTitle));
      return null;
    })).data;
  }
}
