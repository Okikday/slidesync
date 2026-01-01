import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

mixin class RecentDialogActions {
  //==============================================================================
  // Option actions
  //==============================================================================

  /// Removes content from recents by setting its lastRead to null and progress to 0.0
  Future<void> onRemoveFromRecents(BuildContext context, ContentTrack contentTrack) async {
    // final contentId = contentId;
    if (context.mounted) UiUtils.hideDialog(context);
    final resultRemoveFromRecents = await ContentTrackRepo.add(contentTrack.copyWith(lastRead: null, progress: 0.0));
    if (context.mounted) {
      if (resultRemoveFromRecents != -1) {
        await UiUtils.showFlushBar(context, msg: "Removed from recent reads!", vibe: FlushbarVibe.none);
      } else {
        await UiUtils.showFlushBar(context, msg: "Unable to remove from recents", vibe: FlushbarVibe.error);
      }
    }
  }

  /// Opens content viewer for the contentId provided
  Future<void> onContinueReading(WidgetRef ref, String contentId) async {
    final context = ref.context;
    final newContent = await CourseContentRepo.getByContentId(contentId);
    if (context.mounted) UiUtils.hideDialog(context);
    if (newContent == null) {
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: "Unable to open material");
      }
      return;
    }
    if (context.mounted) ContentViewGateActions.redirectToViewer(ref, newContent);
  }

  /// Adds content to bookmarks collection
  void onAddToBookmark(String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) {
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Couldn't add content..."));
      return;
    }
    await CourseCollectionRepo.addContentsToAppCollection(AppCourseCollections.bookmarks, contents: [content]);
    GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Added content to bookmarks"));
  }

  /// Opens content viewer for the contentId provided, with openOutsideApp flag set to true
  void onOpenOutsideApp(WidgetRef ref, String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return;
    if (ref.context.mounted) UiUtils.hideDialog(ref.context);
    ContentViewGateActions.redirectToViewer(ref, content, openOutsideApp: true);
  }

  /// Shares the content file for the contentId provided
  void onShare(BuildContext context, String contentId) async {
    await ShareContentActions.shareFileContent(context, contentId);
  }

  /// Navigates to the collection page of the contentId provided
  void onGoToCollection(BuildContext context, String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return;
    final collection = await CourseCollectionRepo.getById(content.parentId);
    if (collection == null) return;
    GlobalNav.withContext((c) {
      (context.mounted ? context : c).pushReplacementNamed(Routes.courseMaterials.name, extra: collection);
    });
  }
}
