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
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:window_manager/window_manager.dart';

mixin HomeTabActions {
  /// Action taken when the notification button is clicked. Toggles focus mode and shows a flush bar indicating the new state.
  void onClickFocusButton(WidgetRef ref) {
    MainProvider.state.act(ref).isFocusMode.expand(ref, (r, v) {
      late bool prev;
      v.act(ref).update((cb) {
        prev = cb;
        return !cb;
      });
      if (DeviceUtils.isDesktop()) {
        if (prev) {
          windowManager.setFullScreen(false).then((_) => windowManager.maximize(vertically: true));
        } else {
          windowManager.maximize(vertically: true).then((_) => windowManager.setFullScreen(true));
        }
      }
      if (r.context.mounted) {
        UiUtils.showFlushBar(r.context, msg: "Focus mode ${prev ? "disabled" : "enabled"}");
      }
    });
  }

  /// ===================================================================================
  /// HOME BODY ACTIONS
  /// ===================================================================================

  /// When the reading button on the [HomeDashboard] is clicked
  void onReadingButtonTapped(WidgetRef ref, {required ContentTrack data}) async {
    final content = await ModuleContentRepo.getByContentId(data.uid);
    if (content == null) {
      if (ref.context.mounted) {
        UiUtils.showFlushBar(ref.context, msg: "Unable to open material");
      }
      return;
    }
    if (data.progress == 1.0) {
      ContentTrack? nextContentTrack = await ContentTrackRepo.filter
          .courseIdEqualTo(content.parentId)
          .progressLessThan(1.0)
          .findFirst();
      nextContentTrack ??= await (ContentTrackRepo.filter).progressLessThan(1.0).findFirst();
      if (nextContentTrack == null) return;
      final nextContent = await ModuleContentRepo.getByContentId(nextContentTrack.uid);
      if (nextContent == null) return;
      if (ref.context.mounted) ContentViewGateActions.redirectToViewer(ref, nextContent);
    } else {
      if (ref.context.mounted) ContentViewGateActions.redirectToViewer(ref, content);
    }
  }

  /// When the reading button on the [HomeDashboard] is clicked but there is no recent content
  void onEmptyReadingButtonTapped() async {
    final anyCourse = await (CourseRepo.filter).modulesIsNotEmpty().findFirst();
    if (anyCourse == null) {
      final anotherCourse = await (CourseRepo.filter).uidIsNotEmpty().findFirst();
      if (anotherCourse != null) {
        GlobalNav.withContext((context) => context.pushNamed(Routes.courseDetails.name, extra: anotherCourse.uid));
        await Future.delayed(1.inSeconds);
      }
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(
          context,
          msg: anotherCourse == null ? "Try creating a new course from Library." : "Add a new collection",
          flushbarPosition: FlushbarPosition.TOP,
          duration: 2.inSeconds,
        ),
      );
      return;
    } else {
      await anyCourse.modules.load();
      final toCollection = anyCourse.modules.first;
      GlobalNav.withContext((context) => context.pushNamed(Routes.courseMaterials.name, extra: toCollection));
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
