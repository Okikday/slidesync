import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/features/main/ui/actions/home/recent_dialog_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
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
          title: "Continue reading",
          icon: Icon(Iconsax.play_copy, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () => onContinueReading(ref, contentTrack.contentId),
        ),

        divider,

        BuildPlainActionButton(
          title: "Open Outside App",
          icon: Icon(Icons.send_to_mobile_outlined, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () => onOpenOutsideApp(ref, contentTrack.contentId),
        ),

        divider,

        BuildPlainActionButton(
          title: "Share",
          icon: Icon(Icons.share_outlined, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 15, color: theme.onBackground),
          onTap: () => onShare(context, contentTrack.contentId),
        ),

        divider,

        BuildPlainActionButton(
          title: "Go to collection",
          icon: Icon(Iconsax.star, size: 24, color: theme.supportingText),
          textStyle: TextStyle(fontSize: 16, color: theme.onBackground),
          onTap: () async {},
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
