import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_normal_app_bar.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_search_app_bar.dart';

class PdfDocViewerAppBar extends StatefulWidget {
  final String title;
  final PdfDocViewerState pdva;
  final PdfDocSearchState pdsa;
  const PdfDocViewerAppBar({super.key, required this.title, required this.pdva, required this.pdsa});

  @override
  State<PdfDocViewerAppBar> createState() => _PdfDocViewerAppBarState();
}

class _PdfDocViewerAppBarState extends State<PdfDocViewerAppBar> {
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
    return Stack(
      alignment: Alignment.center,
      children: [
        PdfDocSearchAppBar(
          pdfViewerController: widget.pdva.pdfViewerController,
          pdsa: widget.pdsa,
          focusNode: focusNode,
        ),
        PdfDocNormalAppBar(
          title: widget.title,
          onSearch: () {
            focusNode.requestFocus();
            widget.pdsa.isSearchingNotifier.value = true;
          },
          pdva: widget.pdva,
          pdsa: widget.pdsa,
        ),
      ],
    );
  }
}
