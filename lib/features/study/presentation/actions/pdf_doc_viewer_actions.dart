import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:slidesync/features/browse/presentation/logic/course_materials_provider.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/logic/pdf_doc_viewer_provider.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class PdfDocViewerActions {
  static Future<void> onPopInvoked(WidgetRef ref, String contentId, String parentId) async {
    log("did pop");
    final searchStateProvider = PdfDocViewerProvider.searchState(contentId);
    final isSearching = await ref.read(searchStateProvider.future.select((s) async => (await s).isSearching));
    if (isSearching) ref.read(searchStateProvider).value?.setSearching(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    (await ref.read(CourseMaterialsProvider.contentPaginationProvider(parentId).future)).restartIsolate();
  }

  static void calcAppBarTranslation(
    WidgetRef ref,
    String contentId,
    double maxOffset,
    double? prev,
    double next,
  ) async {
    final docStateProvider = PdfDocViewerProvider.state(contentId);
    void updateScrollOffset(double value) => ref.read(docStateProvider).value?.updateScrollOffset(value);
    if (prev == null) {
      updateScrollOffset(next);
    } else {
      final formerValue = (await ref.read(docStateProvider.future.select((s) async => (await s).scrollOffsetNotifier))).value;
      if (prev < next) {
        // Scroll up
        final scrollDifference = next - prev;
        final newValue = (formerValue + scrollDifference).clamp(0.0, maxOffset);
        updateScrollOffset(newValue);
        if (newValue == 0) ref.read(docStateProvider).value?.setToolsMenuVisible(false);
      } else {
        // Scroll down
        final scrollDifference = prev - next;
        final double newValue = (formerValue - scrollDifference).clamp(0.0, maxOffset);

        updateScrollOffset(newValue);
        if (newValue == 0) ref.read(docStateProvider).value?.setToolsMenuVisible(false);
      }
    }
  }
}
