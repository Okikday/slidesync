import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/main/ui/actions/home/recent_dialog_actions.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';

class RecentDialogSelectionOptions extends ConsumerWidget with RecentDialogActions {
  const RecentDialogSelectionOptions({super.key, required this.contentTrack, required this.divider});
  final ContentTrack contentTrack;
  final Divider divider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        divider,

        BuildPlainActionButton(
          title: contentTrack.type == ModuleContentType.link ? "Open Link" : "Continue reading",
          icon: Icon(HugeIconsSolid.playCircle02, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () => onContinueReading(ref, contentTrack.uid),
        ),

        divider,

        BuildPlainActionButton(
          title: "Open Outside App",
          icon: Icon(HugeIconsSolid.sendToMobile02, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () => onOpenOutsideApp(ref, contentTrack.uid),
        ),
        divider,
        BuildPlainActionButton(
          title: "Add to bookmarks",
          icon: Icon(HugeIconsSolid.bookmark02, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () => onAddToBookmark(ref, contentTrack.uid),
        ),

        divider,

        BuildPlainActionButton(
          title: "Share",
          icon: Icon(HugeIconsSolid.share03, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 15, color: theme.onBackground),
          onTap: () => onShare(context, contentTrack.uid),
        ),

        divider,

        BuildPlainActionButton(
          title: "Go to collection",
          icon: Icon(HugeIconsSolid.cursorMagicSelection03, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () async {
            context.pop();
            final content = await ModuleContentRepo.getByUid(contentTrack.uid);
            if (content == null) return;
            final module = await ModuleRepo.getByUid(content.parentId);
            if (module == null) return;

            GlobalNav.withContext(
              (c) => (context.mounted ? context : c).pushNamed(Routes.moduleContentsView.name, extra: module),
            );
          },
        ),

        divider,

        BuildPlainActionButton(
          title: "Remove from recents",
          icon: Icon(Iconsax.box_remove_copy, size: 24, color: Colors.redAccent),
          textStyle: TextStyle(fontSize: 15, color: theme.onBackground),
          onTap: () => onRemoveFromRecents(context, contentTrack),
        ),
        divider,
      ],
    );
  }
}
