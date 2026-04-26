import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/modify_contents_action.dart';
import 'package:slidesync/features/browse/logic/src/contents/modify_content_uc.dart';
import 'package:slidesync/shared/widgets/bottom_sheets/input_text_bottom_sheet.dart';

class ContentCardContextMenuActions {
  static void onRenameContent(BuildContext context, ModuleContent content) {
    UiUtils.showCustomDialog(
      context,
      child:
          InputTextBottomSheet(
            title: "Rename content",
            hintText: "Input a title different from previous one",
            defaultText: content.title,
            onSubmitted: (String text) async {
              // context.pop();
              await ModifyContentsAction().onRenameContent(content, newTitle: text.trim());
            },
          ).animate().fadeIn().scaleY(
            begin: 0.1,
            end: 1.0,
            curve: CustomCurves.bouncySpring,
            duration: Durations.extralong1,
            alignment: Alignment.bottomCenter,
          ),
    );
  }

  static Future<String?> onDeleteContent(
    BuildContext context,
    ModuleContent content, [
    bool showFlushbar = true,
  ]) async {
    final outcome = (await Result.tryRunAsync(() async => await ModifyContentUc().deleteContent(content))).data;
    if (showFlushbar) {
      if (context.mounted) {
        if (outcome == null) {
          UiUtils.showFlushBar(context, msg: "Successfully removed content!", vibe: FlushbarVibe.success);
        } else if (outcome.toLowerCase().contains("error")) {
          UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.error);
        } else {
          UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.warning);
        }
      }
    }
    return outcome;
  }
}
