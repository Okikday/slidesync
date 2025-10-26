import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/manage/domain/usecases/types/add_content_result.dart';
import 'package:slidesync/features/manage/presentation/contents/ui/add_contents/loading_overlay.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/add_contents_uc.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class AddContentsActions {
  // Shared method for the common flow
  static Future<void> _executeAddContentFlow({
    required CourseCollection collection,
    required Future<List<AddContentResult>> Function(ValueNotifier<String>) addContentOperation,
    String initialMessage = "Loading...",
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

    // Show result feedback
    if (result.isNotEmpty) {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "Successfully added course contents!",
        vibe: FlushbarVibe.success,
      );
    } else if (result.isEmpty) {
      await UiUtils.showFlushBar(
        rootNavigatorKey.currentContext!,
        msg: "An error was encountered while adding contents!",
        flushbarPosition: FlushbarPosition.TOP,
        vibe: FlushbarVibe.warning,
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
  }) async {
    await _executeAddContentFlow(
      collection: collection,
      initialMessage: "Loading...",
      addContentOperation: (valueNotifier) =>
          AddContentsUc.addToCollection(collection: collection, type: type, valueNotifier: valueNotifier),
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
