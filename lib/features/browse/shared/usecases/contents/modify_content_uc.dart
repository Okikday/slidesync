import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';

class ModifyContentUc {
  /// Deletes the content provided from storage and database
  Future<String?> deleteContent(CourseContent content) async {
    final bool dupHashExists = await CourseContentRepo.doesDuplicateHashExists(content.contentHash);
    final fileSize = content.fileSize;
    await CourseContentRepo.deleteContent(content);
    await removeIdFromRecents(content.contentId);
    await ContentTrackRepo.deleteByContentId(content.contentId);
    if (!dupHashExists) {
      await Result.tryRunAsync(() async {
        final prevFileSum = await AppHiveData.instance.getData<int?>(key: HiveDataPathKey.globalFileSizeSum.name);
        if (prevFileSum == null) return;
        await AppHiveData.instance.setData<int>(
          key: HiveDataPathKey.globalFileSizeSum.name,
          value: math.max((prevFileSum - fileSize), 0),
        );
      });
    }

    if (!dupHashExists) {
      await FileUtils.deleteFileAtPath(content.path.filePath);
      final previewPath = content.thumbnailPath;
      await FileUtils.deleteFileAtPath(previewPath);
    }

    return null;
  }

  /// Removes contentId from recents list in Hive storage
  static Future<bool> removeIdFromRecents(String contentId) async {
    final result = (await Result.tryRunAsync(() async {
      final hiveInstance = AppHiveData.instance;
      // Change to be Map instead
      final rawOldRecents = (await hiveInstance.getData(key: HiveDataPathKey.recentContentsIds.name)) as List<String>?;
      if (rawOldRecents == null) {
        return false;
      } else {
        final recents = LinkedHashSet<String>.from(rawOldRecents);
        if (recents.remove(contentId)) {
          await hiveInstance.setData(key: HiveDataPathKey.recentContentsIds.name, value: recents.toList());
          return true;
        }
        return false;
      }
    })).data;
    return result ?? false;
  }

  /// Renames the content provided with the new title
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
