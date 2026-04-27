import 'package:flutter/material.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/modify_content_uc.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class ModifyContentsAction {
  Future<void> showDeleteDialog(String contentId) async {
    GlobalNav.withContext(
      (context) => UiUtils.showCustomDialog(
        context,

        child: ConfirmDeletionDialog(
          content: "Are you sure you want to delete this item?",
          onPop: () => GlobalNav.popGlobal(),
          onCancel: () => GlobalNav.popGlobal(),
          onDelete: () async {
            GlobalNav.popGlobal();

            GlobalNav.withContext(
              (context) => UiUtils.showLoadingDialog(context, message: "Removing content", canPop: false),
            );
            final content = await ModuleContentRepo.getByUid(contentId);
            if (content == null) {
              GlobalNav.popGlobal();
              return;
            }
            final outcome = await Result.fromAsyncNullable(() async => await ModifyContentUc().deleteContent(content));

            GlobalNav.popGlobal();

            GlobalNav.withContext((context) {
              UiUtils.showFlushBar(
                context,
                msg: outcome ?? "Deleted content(s)",
                vibe: outcome == null
                    ? FlushbarVibe.success
                    : (outcome.toLowerCase().contains("error") ? FlushbarVibe.error : FlushbarVibe.warning),
              );
            });
          },
        ),
      ),
    );
  }

  Future<String?> onRenameContent(ModuleContent content, {required String newTitle}) async {
    if (newTitle.isEmpty || newTitle == content.title || newTitle.length < 2) return "Try inputting a valid title!";
    if (rootNavigatorKey.currentContext!.mounted) {
      UiUtils.showLoadingDialog(rootNavigatorKey.currentContext!, canPop: false, message: "Renaming content...");
    }
    final Result<String?> renameOutcome = await Result.tryRunAsync(() async {
      return await ModifyContentUc().renameContent(content, newTitle);
    });
    Navigator.pop(rootNavigatorKey.currentContext!);
    GlobalNav.popGlobal();

    if (renameOutcome.isSuccess) {
      return renameOutcome.data;
    } else {
      return "An error occured while renaming content!";
    }
  }
}
