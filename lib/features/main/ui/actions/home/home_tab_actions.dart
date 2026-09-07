// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/app/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:window_manager/window_manager.dart';

mixin HomeTabActions {
  /// Action taken when the notification button is clicked. Toggles focus mode and shows a flush bar indicating the new state.
  void onClickFocusButton(WidgetRef ref) {
    bool prev = false;
    MainPod.me.act(ref).isFocusMode.act(ref).updateIfNotEqual((cb) {
      prev = cb;
      return !cb;
    });
    if (DeviceUtils.isDesktopSize(ref.context)) {
      windowManager.setFullScreen(!prev);
      windowManager.maximize(vertically: true);
    }
    UiUtils.showFlushBar(
      ref.context,
      msg: "${prev ? "Disabled" : "Enabled"} Focus mode",
    );
  }

  /// ===================================================================================
  /// HOME BODY ACTIONS
  /// ===================================================================================

  /// When the reading button on the [HomeDashboard] is clicked
  void onReadingButtonTapped(
    WidgetRef ref, {
    required ContentTrack data,
  }) async {
    final content = await ModuleContentRepo.getByUid(data.uid);
    if (content == null) {
      UiUtils.showFlushBar(ref.context, msg: "Unable to open material");
      return;
    }
    if (data.progress >= 1.0) {
      ContentTrack? nextContentTrack =
          await ContentTrackRepo.filter
              .courseIdEqualTo(content.parentId)
              .progressLessThan(1.0)
              .findFirst() ??
          await ContentTrackRepo.filter.progressLessThan(1.0).findFirst();
      if (nextContentTrack == null) return;
      final nextContent = await ModuleContentRepo.getByUid(
        nextContentTrack.uid,
      );
      if (nextContent == null) return;
      ContentViewGateActions.redirectToViewer(ref, nextContent);
    } else {
      ContentViewGateActions.redirectToViewer(ref, content);
    }
  }

  /// When the reading button on the [HomeDashboard] is clicked but there is no recent content
  void onEmptyReadingButtonTapped() async {
    final firstFind = await (CourseRepo.filter).modulesIsNotEmpty().findFirst();
    if (firstFind == null) {
      final secondFind = await (CourseRepo.filter).uidIsNotEmpty().findFirst();
      if (secondFind != null) {
        GlobalNav.withContext(
          (context) => context.pushNamed(
            Routes.courseDetails.name,
            extra: secondFind.uid,
          ),
        );
        await Future.delayed(1.inSeconds);
      }
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(
          context,
          msg: secondFind == null
              ? "Try creating a new course from Library."
              : "Add a new collection",
          flushbarPosition: FlushbarPosition.TOP,
          duration: 2.inSeconds,
        ),
      );
      return;
    } else {
      await firstFind.modules.load();
      final toCollection = firstFind.modules.first;
      GlobalNav.withContext(
        (context) => context.pushNamed(
          Routes.moduleContentsView.name,
          extra: toCollection,
        ),
      );
      if (toCollection.contents.isEmpty) {
        await 1.inSeconds.delay();
        log("collection is empty");
        GlobalNav.withContext(
          (context) => UiUtils.showFlushBar(
            context,
            msg: "Add some materials to read...",
            flushbarPosition: FlushbarPosition.TOP,
            duration: 2.inSeconds,
          ),
        );
      }
    }
  }
}
