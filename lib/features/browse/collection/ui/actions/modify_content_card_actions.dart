import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_contents_action.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/modify_content_uc.dart';
import 'package:slidesync/shared/widgets/bottom_sheets/input_text_bottom_sheet.dart';

class ModifyContentCardActions {
  static void onRenameContent(BuildContext context, CourseContent content) {
    UiUtils.showCustomDialog(
      context,
      child:
          InputTextBottomSheet(
            title: "Rename content",
            hintText: "Input a title different from previous one",
            defaultText: content.title,
            onSubmitted: (String text) async {
              await ModifyContentsAction().onRenameContent(content, newTitle: text.trim());
              if (context.mounted) UiUtils.hideDialog(context);
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
    CourseContent content, [
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
