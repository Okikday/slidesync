import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_normal_app_bar.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_search_app_bar.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

class PdfDocViewerAppBar extends ConsumerStatefulWidget {
  final String title;
  final String contentId;
  const PdfDocViewerAppBar({super.key, required this.title, required this.contentId});

  @override
  ConsumerState<PdfDocViewerAppBar> createState() => _PdfDocViewerAppBarState();
}

class _PdfDocViewerAppBarState extends ConsumerState<PdfDocViewerAppBar> {
  late final FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docViewP = pdfDocViewerStateProvider(widget.contentId);
    final isAppBarVisible = ref.watch(docViewP.select((s) => s.value?.isAppBarVisible)) ?? true;
    return Consumer(
      builder: (context, ref, child) {
        final offset = ref.watch(docViewP.select((s) => s.value?.scrollOffset)) ?? 0.0;

        return Transform.translate(
          offset: Offset(0, -offset),
          child: AppBarContainer(appBarHeight: isAppBarVisible ? null : 0, child: child!),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          PdfDocSearchAppBar(focusNode: focusNode, contentId: widget.contentId),
          PdfDocNormalAppBar(
            contentId: widget.contentId,
            title: widget.title,
            onSearch: () {
              focusNode.requestFocus();
              ref.read(pdfDocSearchStateProvider(widget.contentId).notifier).setSearching(true);
            },
          ),
        ],
      ),
    );
  }
}
