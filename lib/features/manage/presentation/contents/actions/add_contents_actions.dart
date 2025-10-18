import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/manage/domain/usecases/types/add_content_result.dart';
import 'package:slidesync/features/manage/presentation/contents/views/add_contents/adding_content_overlay.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/add_contents_uc.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';



class AddContentsActions {


  static void onClickToAddContent(
    BuildContext context, {
    required CourseCollection collection,
    required CourseContentType type,
  }) async {
    // final sMap = await AppHiveData.instance.getData(key: HiveDataPathKey.contentsAddingProgressList.name);
    // if (sMap != null) {
    //   final selectedContentPathsOnStorage = Map<String, dynamic>.from(sMap);

    //   if (selectedContentPathsOnStorage.isNotEmpty) {
    //     bool canContinue = false;
    //     await GlobalNav.withContextAsync(
    //       (context) async => await UiUtils.showCustomDialog(
    //         context,
    //         child: AppAlertDialog(
    //           title: "Pending operation",
    //           content:
    //               "Some of the contents you were adding didn’t finish processing last time. Would you like to pick up from where you left?\n\nIt's not advisable to...",
    //           onCancel: () async {
    //             canContinue = false;
    //             context.pop();
    //             await AppHiveData.instance.deleteData(key: HiveDataPathKey.contentsAddingProgressList.name);
    //           },
    //           onConfirm: () async {
    //             canContinue = true;
    //             context.pop();
    //           },
    //           onPop: () async {
    //             canContinue = false;
    //             context.pop();
    //             await AppHiveData.instance.deleteData(key: HiveDataPathKey.contentsAddingProgressList.name);
    //           },
    //         ),
    //       ),
    //     );

    //     if (canContinue) {
    //       await AddContentsUc.resumeFromLastAddToCollection(selectedContentPathsOnStorage, collection);
    //       await GlobalNav.withContextAsync(
    //         (context) async => await UiUtils.showFlushBar(
    //           context,
    //           msg: "You'll be referred to add contents soon, watch out...",
    //           duration: Duration(seconds: 3),
    //         ),
    //       );
    //     }
    //   }
    // }

    ValueNotifier<String> valueNotifier = ValueNotifier("Loading...");
    final entry = OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) => LoadingOverlay(message: value),
      ),
    );
    GlobalNav.overlay?.insert(entry);
    final result = await AddContentsUc.addToCollection(
      collection: collection,
      type: type,
      valueNotifier: valueNotifier,
    );

    entry.remove();
    valueNotifier.dispose();
    log("result: $result");
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

  static void onClickToAddContentNoRef({required CourseCollection collection, required List<String> filePaths}) async {
    ValueNotifier<String> valueNotifier = ValueNotifier("Offloading contents");
    final entry = OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) => LoadingOverlay(message: value),
      ),
    );
    GlobalNav.overlay?.insert(entry);
    final List<AddContentResult> result = await AddContentsUc.addToCollectionNoRef(
      collection: collection,
      valueNotifier: valueNotifier,
      filePaths: filePaths,
    );

    entry.remove();
    valueNotifier.dispose();

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
}
