import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/progress_track_models/content_track.dart';
import 'package:slidesync/domain/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/domain/repos/course_track_repo/content_track_repo.dart';

class RecentDialogActions {
  final WidgetRef ref;
  RecentDialogActions._(this.ref);
  static RecentDialogActions of(WidgetRef ref) => RecentDialogActions._(ref);

  Future<void> onRemoveFromRecents(ContentTrack contentTrack) async {
    final context = ref.context;
    // final contentId = contentId;
    if (context.mounted) UiUtils.hideDialog(context);
    final resultRemoveFromRecents = await ContentTrackRepo.add(contentTrack.copyWith(lastRead: null));
    if (context.mounted) {
      if (resultRemoveFromRecents != -1) {
        await UiUtils.showFlushBar(context, msg: "Removed from recent reads!", vibe: FlushbarVibe.none);
      } else {
        await UiUtils.showFlushBar(context, msg: "Unable to remove from recents", vibe: FlushbarVibe.error);
      }
    }
  }

  static Future<bool> removeIdFromRecents(String contentId) async {
    return (await Result.tryRunAsync(() async {
          final hiveInstance = AppHiveData.instance;
          // Change to be Map instead
          final rawOldRecents =
              (await hiveInstance.getData(key: HiveDataPathKey.recentContentsIds.name)) as List<String>?;
          if (rawOldRecents == null) {
            return false;
          } else {
            final recents = LinkedHashSet<String>.from(rawOldRecents);
            if (recents.remove(contentId)) {
              await hiveInstance.setData(key: HiveDataPathKey.recentContentsIds.name, value: recents.toList());
              return true;
            }
            return false;
          }
        })).data ??
        false;
  }

  Future<void> onContinueReading(String contentId) async {
    final context = ref.context;
    final newContent = await CourseContentRepo.getByContentId(contentId);
    if (context.mounted) UiUtils.hideDialog(context);
    if (newContent == null) {
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: "Unable to open material");
      }
      return;
    }
    if (context.mounted) context.pushNamed(Routes.contentGate.name, extra: newContent);
  }
}
