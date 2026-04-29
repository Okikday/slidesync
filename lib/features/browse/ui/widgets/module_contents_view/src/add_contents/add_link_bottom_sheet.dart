import 'dart:async';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/add_link_actions.dart';
import 'package:slidesync/features/browse/logic/src/contents/retrieve_content_uc.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/bottom_sheets/input_text_bottom_sheet.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class AddLinkBottomSheet extends ConsumerStatefulWidget {
  final Module collection;
  const AddLinkBottomSheet({super.key, required this.collection});

  @override
  ConsumerState<AddLinkBottomSheet> createState() => _AddLinkBottomSheetState();
}

class _AddLinkBottomSheetState extends ConsumerState<AddLinkBottomSheet> {
  final linkInputController = TextEditingController();
  final linkDetailsNotifier = ValueNotifier<PreviewLinkDetails?>(null);
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
    linkInputController.addListener(_fetchDetailsOnInput);
  }

  void _fetchDetailsOnInput() {
    if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final link = linkInputController.text;
      if (link.length >= 4 && link.length <= 256) {
        final details = await RetriveContentUc.getLinkPreviewData(link);
        if (mounted) linkDetailsNotifier.value = details;
      }
    });
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    linkInputController.removeListener(_fetchDetailsOnInput);
    linkInputController.dispose();
    linkDetailsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InputTextBottomSheet(
          title: "Add link",
          hintText: "https.youtube.com/learn",
          textEditingController: linkInputController,
          onSubmitted: (String text) async {
            if (text.isEmpty || text.length < 4 || text.length > 256) {
              UiUtils.showFlushBar(
                context,
                msg: text.length < 4
                    ? "Link too short!"
                    : text.length > 256
                    ? "Link too long!"
                    : "Try inputting a valid link!",
              );
              return;
            }
            context.pop();

            await AddLinkActions.onAddLinkContent(
              text,
              parentId: widget.collection.uid,
              details: linkDetailsNotifier.value,
            ).then(
              (result) => GlobalNav.withContext(
                (c) => UiUtils.showFlushBar(
                  context.mounted ? context : c,
                  msg: result ? "Successfully added link" : "Unable to add link to collection",
                  vibe: result ? FlushbarVibe.success : FlushbarVibe.error,
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 24,
          bottom: context.bottomPadding + 120,
          child: Container(
            width: 100,
            height: 100,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: ref.onBackground.withValues(alpha: 0.2))],
            ),
            child: ValueListenableBuilder(
              valueListenable: linkDetailsNotifier,
              builder: (context, linkDetails, child) {
                if (linkDetails == null || linkDetails.previewUrl == null) return const SizedBox();
                return BuildImagePathWidget(
                  fileDetails: FilePath(url: linkDetails.previewUrl),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                );
              },
            ),
          ).animate(onComplete: (controller) => controller.repeat()).shimmer(duration: Durations.extralong4),
        ),
        Positioned(
          right: 12,
          bottom: context.bottomPadding + 120,
          child: CustomElevatedButton(
            label: "Paste from Clipboard",
            backgroundColor: ref.altBackgroundPrimary,
            textColor: ref.primaryColor,
            onClick: () => AddLinkActions.pasteFromClipboard(linkInputController),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(
      begin: .4,
      end: 0,
      duration: Duration(milliseconds: 200),
      curve: CustomCurves.decelerate,
    );
  }
}
