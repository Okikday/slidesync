import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/study/presentation/actions/pdf_doc_viewer_actions.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_floating_action_menu.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_viewer_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfDocViewerInnerSection extends ConsumerStatefulWidget {
  final CourseContent content;

  const PdfDocViewerInnerSection({super.key, required this.content});

  @override
  ConsumerState<PdfDocViewerInnerSection> createState() => _PdfDocViewerInnerSectionState();
}

class _PdfDocViewerInnerSectionState extends ConsumerState<PdfDocViewerInnerSection> {
  @override
  Widget build(BuildContext context) {
    log("doc inner section rebuild");
    // final theme = ref;
    final maxOffset = context.topPadding + kToolbarHeight + 12;

    // ref.listen(PdfDocViewerController.scrollOffsetNotifierProvider, (prev, next) async {
    //   PdfDocViewerActions.calcAppBarTranslation(ref, widget.pdva, maxOffset, prev, next);
    // });

    return Consumer(
      builder: (context, ref, child) {
        final isSearching =
            ref.watch(pdfDocSearchStateProvider(widget.content.contentId).select((s) => s.value?.isSearching)) ?? false;
        return PopScope(
          canPop: !isSearching,
          onPopInvokedWithResult: (didPop, result) async {
            await PdfDocViewerActions.onPopInvoked(ref, widget.content.contentId, widget.content.parentId);
          },
          child: child!,
        );
      },
      child: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
        child: Scaffold(
          floatingActionButton: PdfFloatingActionMenu(contentId: widget.content.contentId),

          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: PdfViewerWidget(content: widget.content)),

              // Positioned(
              //   top: 0,
              //   left: 0,
              //   right: 0,
              //   child: PdfDocViewerAppBar(title: widget.content.title, pdva: widget.pdva, pdsa: widget.pdsa),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
