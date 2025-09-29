import 'dart:developer';

import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/domain/models/course_model/sub/course_collection.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/domain/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage_all/manage_contents/usecases/create_contents_uc/create_content_preview_image.dart';

class ModifyCollectionUc {
  Future<String?> deleteCollection(CourseCollection collection) async {
    await collection.contents.load();
    for (final item in collection.contents) {
      final bool dupHashExists = await CourseContentRepo.doesDuplicateHashExists(item.contentHash);
      if (!dupHashExists) {
        final filePath = item.path.filePath;
        await FileUtils.deleteFileAtPath(filePath);
        await FileUtils.deleteFileAtPath(CreateContentPreviewImage.genPreviewImagePath(filePath: filePath));
      }
    }
    // await CourseCollectionRepo.deleteMultipleContents(collection.contents.toList(), collection);
    // log("Successfully deleted multiple contents");
    final bool deleteOutcome = await CourseCollectionRepo.deleteCollection(collection);
    if (!deleteOutcome) return "An error occured while deleting!";
    return null;
  }
}
