import 'package:flutter/material.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/modify_content_uc.dart';
import 'package:slidesync/routes/app_router.dart';

class ModifyContentsAction {
  Future<String?> onDeleteContent(String contentId, {int? courseDbId}) async {
    if (rootNavigatorKey.currentContext!.mounted) {
      UiUtils.showLoadingDialog(rootNavigatorKey.currentContext!, message: "Deleting content...");
    }
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return "Couldn't find content";
    final Result<String?> delOutcome = await Result.tryRunAsync(
      () async {
        return await ModifyContentUc().deleteContent(content);
        
      },
    );
    Navigator.pop(rootNavigatorKey.currentContext!);

    if (delOutcome.isSuccess) {
      return delOutcome.data;
    } else {
      return "An error occured while deleting content!";
    }
  }

  Future<String?> onRenameContent(CourseContent content, {required String newTitle}) async {
    if (newTitle.isEmpty || newTitle == content.title || newTitle.length < 2) return "Try inputting a valid title!";
    if (rootNavigatorKey.currentContext!.mounted) {
      UiUtils.showLoadingDialog(rootNavigatorKey.currentContext!, message: "Renaming content...");
    }
    final Result<String?> renameOutcome = await Result.tryRunAsync(() async {
      return await ModifyContentUc().renameContent(content, newTitle);
    });
    Navigator.pop(rootNavigatorKey.currentContext!);

    if (renameOutcome.isSuccess) {
      return renameOutcome.data;
    } else {
      return "An error occured while renaming content!";
    }
  }
}
