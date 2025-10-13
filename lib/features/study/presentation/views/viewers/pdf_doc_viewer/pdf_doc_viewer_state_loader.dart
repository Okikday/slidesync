import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

class PdfDocViewerStateLoader extends ConsumerWidget {
  final String contentId;
  final Widget Function(PdfDocViewerState pdva, PdfDocSearchState pdsa) child;
  const PdfDocViewerStateLoader({super.key, required this.contentId, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdvaN = ref.watch(PdfDocViewerController.pdfDocViewerStateProvider(contentId));
    return pdvaN.when(
      data: (pdva) {
        final pdsaN = ref.watch(PdfDocSearchController.pdfDocSearchStateProvider(contentId));
        return pdsaN.when(
          data: (pdsa) {
            return child(pdva, pdsa);
          },
          error: (_, _) => Icon(Icons.error),
          loading: () => const Scaffold(
            appBar: AppBarContainer(child: SizedBox()),
            body: SizedBox(),
          ),
        );
      },
      error: (_, _) => Icon(Icons.error),
      loading: () => const Scaffold(
        appBar: AppBarContainer(child: SizedBox()),
        body: SizedBox(),
      ),
    );
  }
}
