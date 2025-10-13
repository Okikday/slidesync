import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/navigation_controls.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/pdf_tools_menu.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class PdfFloatingActionMenu extends ConsumerWidget {
  const PdfFloatingActionMenu({super.key, required this.pdsa, required this.pdva});

  final PdfDocSearchState pdsa;
  final PdfDocViewerState pdva;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: pdsa.searchTickNotifier,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pdsa.textSearcher != null)
              DecoratedBox(
                decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: NavigationControls(
                    textSearcher: pdsa.textSearcher,
                    onNavigateToInstance: pdsa.navigateToInstance,
                  ),
                ),
              ),
            ValueListenableBuilder(
              valueListenable: pdva.isAppBarVisibleNotifier,
              builder: (context, value, child) {
                if (!value || pdsa.textSearcher != null) return const SizedBox();
                return PdfToolsMenu(isVisible: true);
              },
            ),
          ],
        );
      },
    );
  }
}
