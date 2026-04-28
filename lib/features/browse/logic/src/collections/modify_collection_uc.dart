import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/store_contents.dart';

class ModifyCollectionUc {
  Future<String?> deleteCollection(Module collection) async {
    await collection.contents.load();
    final contents = collection.contents.toList();
    final contentMaps = {for (final c in contents) c.xxh3Hash: c};
    int fileSizeSum = 0;
    final allWhereDuplicateHashExists = await ModuleContentRepo.doesMultipleDuplicateHashExist(contentMaps.keys);
    final allWithoutDuplicateHash = allWhereDuplicateHashExists.entries.where((e) => e.value == false);

    // Delete the files without duplicates content that might rely on the file
    await FileUtils.deleteMultipleFiles(
      allWithoutDuplicateHash.map((e) {
        final content = contentMaps[e.key];
        fileSizeSum += content?.fileSizeInBytes ?? 0;
        return File(content?.path.local ?? '');
      }).toList(),
    );

    // Then delete their previews
    await FileUtils.deleteMultipleFiles(
      allWithoutDuplicateHash
          .where((e) {
            final thumbnailPath = contentMaps[e.key]?.metadata?.thumbnail;
            return thumbnailPath != null && thumbnailPath.containsLocalPath;
          })
          .map((m) => File(contentMaps[m.key]!.metadata!.thumbnail!.local!)),
    );

    final bool deleteOutcome = await ModuleRepo.deleteCollection(collection);
    await Result.tryRunAsync(() async => await aggregateFileSizeToStorage(-fileSizeSum));
    if (!deleteOutcome) return "An error occured while deleting!";
    return null;
  }
}
