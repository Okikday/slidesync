import 'dart:math' as math;

import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';

class ModifyCollectionUc {
  Future<String?> deleteCollection(CourseCollection collection) async {
    await collection.contents.load();
    int fileSum = 0;
    for (final item in collection.contents) {
      final bool dupHashExists = await CourseContentRepo.doesDuplicateHashExists(item.contentHash);
      if (!dupHashExists) {
        final filePath = item.path.filePath;
        await FileUtils.deleteFileAtPath(filePath);

        final previewPath = item.metadata.thumbnails?.filePath;
        if (previewPath != null && previewPath.isNotEmpty) await FileUtils.deleteFileAtPath(previewPath);
        fileSum += item.fileSize;
      }
    }
    // await CourseCollectionRepo.deleteMultipleContents(collection.contents.toList(), collection);
    // log("Successfully deleted multiple contents");
    final bool deleteOutcome = await CourseCollectionRepo.deleteCollection(collection);
    await Result.tryRunAsync(() async {
      final prevFileSum = await AppHiveData.instance.getData<int?>(key: HiveDataPathKey.globalFileSizeSum.name);
      if (prevFileSum == null) return;
      await AppHiveData.instance.setData<int>(
        key: HiveDataPathKey.globalFileSizeSum.name,
        value: math.max((prevFileSum - fileSum), 0),
      );
    });
    if (!deleteOutcome) return "An error occured while deleting!";
    return null;
  }
}
