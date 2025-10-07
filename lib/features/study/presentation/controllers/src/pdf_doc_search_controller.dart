import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';

final _pdfDocSearchStateProvider = FutureProvider.autoDispose.family<PdfDocSearchState, String>((ref, contentId) async {
  final pdfViewerController = (await ref.watch(
    PdfDocViewerController.pdfDocViewerStateProvider(contentId).future,
  )).pdfViewerController;
  final pdss = PdfDocSearchState(pdfViewerController: pdfViewerController);
  ref.onDispose(pdss.dispose);
  return pdss;
});

class PdfDocSearchController {
  static FutureProvider<PdfDocSearchState> pdfDocSearchStateProvider(String contentId) =>
      _pdfDocSearchStateProvider(contentId);
}
