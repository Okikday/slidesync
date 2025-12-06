import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/browse/shared/usecases/types/add_content_result.dart';
import 'package:slidesync/features/browse/collection/ui/widgets/add_contents/loading_overlay.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/add_contents_uc.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';

class AddContentsActions {
  // Shared method for the common flow
  static Future<void> _executeAddContentFlow({
    required CourseCollection collection,
    required Future<List<AddContentResult>> Function(ValueNotifier<String>) addContentOperation,
    String initialMessage = "Loading...",
    bool permissionIssue = false,
  }) async {
    ValueNotifier<String> valueNotifier = ValueNotifier(initialMessage);
    final entry = OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) => LoadingOverlay(
          message: value,
          onCancel: (ref) {
            GlobalNav.withContext(
              (c) => UiUtils.showFlushBar(context, msg: "Can't cancel operation Please keep app open"),
            );
          },
        ),
      ),
    );

    GlobalNav.overlay?.insert(entry);

    // Execute the specific add content operation
    final result = await addContentOperation(valueNotifier);

    entry.remove();
    valueNotifier.dispose();

    log("result: $result");
    final hasDuplicate = result.firstWhereOrNull((a) => a.hasDuplicate)?.hasDuplicate ?? false;

    // Show result feedback
    if (result.isNotEmpty) {
      await GlobalNav.withContextAsync(
        (context) async => await UiUtils.showFlushBar(
          rootNavigatorKey.currentContext!,
          msg: hasDuplicate
              ? "Sucessfully added course contents. Duplicates were not added!"
              : "Successfully added course contents!",
          vibe: FlushbarVibe.success,
          duration: hasDuplicate ? 2.inSeconds : 1500.inMs,
        ),
      );
    } else if (result.isEmpty) {
      if (permissionIssue) {
        GlobalNav.withContext(
          (context) => UiUtils.showCustomDialog(
            context,
            child:
                AppAlertDialog(
                  title: "Error selecting folder",
                  content:
                      "No folder selected or access denied.\n\nPlease try selecting individual files instead - you can still pick multiple files at once!.\n\nWould you like to select instead?",
                  onCancel: null,
                  onConfirm: () {
                    onClickToAddContent(context, collection: collection, type: CourseContentType.unknown);
                  },
                  onPop: () => context.pop(),
                ).animate().scaleXY(
                  alignment: Alignment.bottomCenter,
                  curve: CustomCurves.defaultIosSpring,
                  duration: Durations.extralong1,
                  begin: 0.8,
                  end: 1,
                ),
          ),
        );
        return;
      }
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "No folder was selected or access denied!.",
        flushbarPosition: FlushbarPosition.TOP,
        duration: 4.inSeconds,
        vibe: FlushbarVibe.none,
      );
    } else {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "An error occured while adding contents",
        vibe: FlushbarVibe.error,
      );
    }
  }

  static void onClickToAddContent(
    BuildContext context, {
    required CourseCollection collection,
    required CourseContentType type,
    bool selectByFolder = false,
  }) async {
    await _executeAddContentFlow(
      collection: collection,
      initialMessage: "Loading...",
      permissionIssue: selectByFolder,
      addContentOperation: (valueNotifier) => AddContentsUc.addToCollection(
        collection: collection,
        type: type,
        valueNotifier: valueNotifier,
        selectByFolder: selectByFolder,
      ),
    );
  }

  static void onClickToAddContentNoRef({required CourseCollection collection, required List<String> filePaths}) async {
    await _executeAddContentFlow(
      collection: collection,
      initialMessage: "Offloading contents",
      addContentOperation: (valueNotifier) => AddContentsUc.addToCollectionNoRef(
        collection: collection,
        valueNotifier: valueNotifier,
        filePaths: filePaths,
      ),
    );
  }
}
