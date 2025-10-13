import 'dart:async';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/navigation_button.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class NavigationControls extends ConsumerWidget {
  const NavigationControls({super.key, required this.contentId});

  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final s = ref.watch(pdfDocSearchStateProvider(contentId).select((s) => s.value?.textSearcher));
    final hasMatches = s?.hasMatches == true;
    final inProgress = s?.isSearching == true;

    final resultText = hasMatches
        ? "${(s!.currentIndex ?? 0) + 1} of ${s.matches.length}${inProgress ? '..' : ''}"
        : "0 of 0";

    final canNavigate = hasMatches;

    Future<void> onNavigateToInstance(bool isNext) async =>
        await ref.read(pdfDocSearchStateProvider(contentId).notifier).navigateToInstance(isNext);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (resultText != "0 of 0")
          CustomText(
            resultText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: canNavigate ? theme.onBackground : theme.onBackground.withValues(alpha: 0.5),
            ),
          ),
        ConstantSizing.rowSpacing(4),
        NavigationButton(
          onPressed: canNavigate ? () => onNavigateToInstance(false) : null,
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: "Previous result",
          iconColor: theme.onBackground,
          canNavigate: canNavigate,
        ),
        NavigationButton(
          onPressed: canNavigate ? () => onNavigateToInstance(true) : null,
          icon: Icons.arrow_forward_ios_rounded,
          tooltip: "Next result",
          iconColor: theme.onBackground,
          canNavigate: canNavigate,
        ),
      ],
    );
  }
}
