import 'dart:collection';
import 'dart:math' as math;

import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';

class ModifyContentUc {
  /// Deletes the content provided from storage and database
  Future<String?> deleteContent(ModuleContent content) async {
    final dupHashExists = await ModuleContentRepo.doesDuplicateHashExists(content.xxh3Hash);
    final fileSize = content.fileSizeInBytes;
    await ModuleContentRepo.deleteContent(content);
    await removeIdFromRecents(content.uid);
    if (!dupHashExists) {
      final path = content.path.local;
      if (path != null) await FileUtils.deleteFileAtPath(path);
      await FileUtils.deleteFileAtPath(content.metadata?.thumbnail?.local ?? '');
    }
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
  Future<String?> renameContent(ModuleContent content, String newTitle) async {
    return (await Result.tryRunAsync(() async {
      ModuleContent? stContent = await ModuleContentRepo.getByDbId(content.id);
      if (stContent == null) {
        stContent = await ModuleContentRepo.getByUid(content.uid);
        if (stContent == null) return;
      }

      await ModuleContentRepo.add(stContent.copyWith(xxh3Hash: content.xxh3Hash, title: newTitle));
      try {
        final contentTrack = await ContentTrackRepo.getByContentId(content.uid);
        final updated = contentTrack?.copyWith(title: newTitle);
        if (updated != null) await ContentTrackRepo.add(updated);
      } catch (e) {
        //ignore
      }

      return null;
    })).data;
  }
}
