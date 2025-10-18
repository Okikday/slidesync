import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/navigation_controls.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/pdf_tools_menu.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfFloatingActionMenu extends ConsumerWidget {
  const PdfFloatingActionMenu({super.key, required this.contentId});

  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Consumer(
      builder: (context, ref, child) {
        ref.watch(pdfDocSearchStateProvider(contentId).select((s) => s.value?.searchTick));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ref.watch(pdfDocSearchStateProvider(contentId).select((s) => s.value?.textSearcher)) != null)
              DecoratedBox(
                decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: NavigationControls(contentId: contentId),
                ),
              ),
            Consumer(
              builder: (context, ref, child) {
                final value = ref.watch(pdfDocViewerStateProvider(contentId).select((s) => s.value?.isAppBarVisible));
                if (value == null ||
                    !value ||
                    ref.watch(pdfDocSearchStateProvider(contentId).select((s) => s.value?.textSearcher)) != null) {
                  return const SizedBox();
                }
                return PdfToolsMenu(isVisible: true);
              },
            ),
          ],
        );
      },
    );
  }
}
