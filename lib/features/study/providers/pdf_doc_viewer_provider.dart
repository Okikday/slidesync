import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

import '../../../shared/global/notifiers/toggle_notifier.dart';

class PdfDocViewerProvider {
  static final state = Provider.family.autoDispose<PdfDocViewerState, String>((ref, arg) {
    final pdvs = PdfDocViewerState(ref, arg);
    pdvs.updateScrollOffset(0.0);
    ref.onDispose(pdvs.dispose);
    return pdvs;
  });

  static final searchState = Provider.family.autoDispose<PdfDocSearchState, String>((ref, arg) {
    final controller = ref.read(state(arg).select((s) => s.controller));
    final pdss = PdfDocSearchState(contentId: arg, pdfViewerController: controller);
    ref.onDispose(pdss.dispose);
    return pdss;
  });

  static final ispdfViewerInDarkMode = AsyncNotifierProvider.autoDispose<ToggleNotifier, bool>(
    () => ToggleNotifier(HiveDataPathKey.ispdfViewerInDarkMode.name),
  );
}
