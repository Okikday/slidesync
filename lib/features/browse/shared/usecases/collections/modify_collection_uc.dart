import 'dart:math' as math;

import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';

class ModifyCollectionUc {
  Future<String?> deleteCollection(Module collection) async {
    await collection.contents.load();
    int fileSum = 0;
    for (final item in collection.contents) {
      final bool dupHashExists = await ModuleContentRepo.doesDuplicateHashExists(item.xxh3Hash);
      if (!dupHashExists) {
        final filePath = item.path.local;
        if (filePath != null) await FileUtils.deleteFileAtPath(filePath);

        final previewPath = item.metadata.thumbnail?.local;
        if (previewPath != null && previewPath.isNotEmpty) await FileUtils.deleteFileAtPath(previewPath);
        fileSum += item.fileSizeInBytes;
      }
    }
    // await CourseCollectionRepo.deleteMultipleContents(collection.contents.toList(), collection);
    // log("Successfully deleted multiple contents");
    final bool deleteOutcome = await ModuleRepo.deleteCollection(collection);
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
