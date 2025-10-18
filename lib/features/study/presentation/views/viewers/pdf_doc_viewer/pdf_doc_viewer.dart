import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/study/presentation/actions/pdf_doc_viewer_actions.dart';
import 'package:slidesync/features/study/presentation/logic/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_viewer_app_bar.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_floating_action_menu.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_viewer_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfDocViewer extends ConsumerWidget {
  final CourseContent content;
  const PdfDocViewer({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // log("doc inner section rebuild");
    // final theme = ref;
    final maxOffset = context.topPadding + kToolbarHeight + 12;

    ref.listen(PdfDocViewerState.scrollOffsetProvider, (prev, next) async {
      PdfDocViewerActions.calcAppBarTranslation(ref, content.contentId, maxOffset, prev, next);
    });

    return Consumer(
      builder: (context, ref, child) {
        final isSearching =
            ref.watch(PdfDocViewerProvider.searchState(content.contentId).select((s) => s.value?.isSearching)) ?? false;
        return PopScope(
          canPop: !isSearching,
          onPopInvokedWithResult: (didPop, result) async {
            await PdfDocViewerActions.onPopInvoked(ref, content.contentId, content.parentId);
          },
          child: child!,
        );
      },
      child: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
        child: Scaffold(
          floatingActionButton: PdfFloatingActionMenu(contentId: content.contentId),

          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: PdfViewerWidget(content: content)),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PdfDocViewerAppBar(title: content.title, contentId: content.contentId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
