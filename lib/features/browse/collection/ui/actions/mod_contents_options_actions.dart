import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/browse/collection/providers/src/mod_contents_state.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_content_card_actions.dart';
import 'package:slidesync/features/browse/collection/ui/widgets/modify_contents/move_to_collection_bottom_sheet.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';

class ModContentsOptionsActions {
  static void onMove(BuildContext context, ModContentsNotifier n) async {
    final contents = n.selectedContents.toList();
    n.clearContents();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => MoveOrStoreContentBottomSheet.move(contents: contents)));
  }

  static void onShare(BuildContext context, ModContentsNotifier n) async {
    final contents = n.selectedContents.toList();
    n.clearContents();
    await ShareContentActions.shareContents(context, contents.map((e) => e.uid).toList());
  }

  static void onSelectAll(BuildContext context, ModContentsNotifier n) async {
    if (n.selectedContents.isEmpty) return;
    final anyContent = n.selectedContents.firstWhereOrNull((c) => c.parentId.isNotEmpty);
    if (anyContent == null) return;
    final collection = await CourseCollectionRepo.getById(anyContent.parentId);
    if (collection == null) return;
    await collection.contents.load();
    n.selectAllContent(collection.contents.toList());
  }

  static void delete(BuildContext context, ModContentsNotifier n) {
    UiUtils.showCustomDialog(
      context,
      child: ConfirmDeletionDialog(
        content:
            "Are you sure you want to delete ${n.selectedContents.length == 1 ? "this item" : "${n.selectedContents.length} item(s)"}?",
        onPop: () {
          if (context.mounted) {
            UiUtils.hideDialog(context);
          } else {
            rootNavigatorKey.currentContext?.pop();
          }
        },
        onCancel: () {
          rootNavigatorKey.currentContext?.pop();
        },
        onDelete: () async {
          if (context.mounted) {
            UiUtils.hideDialog(context);
          } else {
            rootNavigatorKey.currentContext?.pop();
          }
          UiUtils.showLoadingDialog(context, message: "Removing contents", canPop: false);

          final String? outcome = (await Result.tryRunAsync(() async {
            String? outcome;
            for (final e in n.selectedContents) {
              outcome = await ModifyContentCardActions.onDeleteContent(context, e, false);
            }
            return outcome;
          })).data;
          n.clearContents();
          rootNavigatorKey.currentContext?.pop();
          if (context.mounted) {
            if (outcome == null) {
              UiUtils.showFlushBar(context, msg: "Successfully removed contents!", vibe: FlushbarVibe.success);
            } else if (outcome.toLowerCase().contains("error")) {
              UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.error);
            } else {
              UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.warning);
            }
          }
        },
      ),
    );
  }
}
