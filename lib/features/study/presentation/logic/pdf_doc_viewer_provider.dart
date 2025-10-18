import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

import '../../../../shared/global/notifiers/toggle_notifier.dart';

class PdfDocViewerProvider {
  static final state = FutureProvider.family.autoDispose<PdfDocViewerState, String>((ref, arg) async {
    final pdvs = PdfDocViewerState(ref, arg);
    await pdvs.initialize();
    ref.onDispose(pdvs.dispose);
    return pdvs;
  });

  static final searchState = FutureProvider.family.autoDispose<PdfDocSearchState, String>((ref, arg) async {
    final controller = await ref.read(state(arg).selectAsync((s) => s.controller));
    final pdss = PdfDocSearchState(contentId: arg, pdfViewerController: controller);
    await pdss.initialize();
    ref.onDispose(pdss.dispose);
    return pdss;
  });

  static final ispdfViewerInDarkMode = AsyncNotifierProvider.autoDispose<ToggleNotifier, bool>(
    () => ToggleNotifier(HiveDataPathKey.ispdfViewerInDarkMode.name),
  );

 
}
