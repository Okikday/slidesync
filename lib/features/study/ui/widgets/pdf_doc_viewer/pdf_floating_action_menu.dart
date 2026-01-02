import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_overlay_widgets/navigation_controls.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_overlay_widgets/pdf_tools_menu.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfFloatingActionMenu extends ConsumerWidget {
  const PdfFloatingActionMenu({super.key, required this.contentId});

  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return ValueListenableBuilder(
      valueListenable: ref.watch(PdfDocViewerProvider.searchState(contentId).select((s) => s.searchTickNotifier)),
      builder: (context, searchTick, child) {
        return Consumer(
          builder: (context, ref, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ref.watch(PdfDocViewerProvider.searchState(contentId).select((s) => s.textSearcher)) != null)
                  DecoratedBox(
                    decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: NavigationControls(contentId: contentId),
                    ),
                  ),
                ValueListenableBuilder(
                  valueListenable: ref.watch(
                    PdfDocViewerProvider.state(contentId).select((s) => s.isAppBarVisibleNotifier),
                  ),
                  builder: (context, isAppBarVisible, child) {
                    final value =
                        ref.watch(PdfDocViewerProvider.searchState(contentId).select((s) => s.textSearcher)) != null;
                    if (!isAppBarVisible || value) return const SizedBox();
                    return PdfToolsMenu(isVisible: true, contentId: contentId);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
