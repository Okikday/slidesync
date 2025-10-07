import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';

import '../../../../../shared/global/notifiers/toggle_notifier.dart';

final AsyncNotifierProvider<ToggleNotifier, bool> _ispdfViewerInDarkModeNotifier =
    AsyncNotifierProvider.autoDispose<ToggleNotifier, bool>(
      () => ToggleNotifier(HiveDataPathKey.ispdfViewerInDarkMode.name),
    );

final _pdfDocViewerStateProvider = FutureProvider.autoDispose.family<PdfDocViewerState, String>((ref, contentId) async{
  final pdvs = PdfDocViewerState(contentId);
  await pdvs.initialize();
  ref.onDispose(pdvs.dispose);
  return pdvs;
});

class PdfDocViewerController {
  static AsyncNotifierProvider<ToggleNotifier, bool> get ispdfViewerInDarkMode => _ispdfViewerInDarkModeNotifier;
  static FutureProvider<PdfDocViewerState> pdfDocViewerStateProvider(String contentId) =>
      _pdfDocViewerStateProvider(contentId);
}
