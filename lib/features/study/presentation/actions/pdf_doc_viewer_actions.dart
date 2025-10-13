import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:slidesync/features/browse/presentation/controlllers/src/course_materials_controller/course_materials_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class PdfDocViewerActions {
  static Future<void> onPopInvoked(WidgetRef ref, ValueNotifier<bool> isSearchingNotifier, String parentId) async {
    log("did pop");
    if (isSearchingNotifier.value) isSearchingNotifier.value = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    (await ref.read(CourseMaterialsController.contentPaginationProvider(parentId).future)).restartIsolate();
  }

  static void calcAppBarTranslation(
    WidgetRef ref,
    PdfDocViewerState pdva,
    double maxOffset,
    double? prev,
    double next,
  ) async {
    if (prev == null) {
      pdva.scrollOffsetNotifier.value = next;
    } else {
      final formerValue = pdva.scrollOffsetNotifier.value;
      if (prev < next) {
        // Scroll up
        final scrollDifference = next - prev;
        final newValue = (formerValue + scrollDifference).clamp(0.0, maxOffset);
        pdva.scrollOffsetNotifier.value = newValue;
        if (newValue == 0) pdva.isToolsMenuVisible.value = false;
      } else {
        // Scroll down
        final scrollDifference = prev - next;
        final double newValue = (formerValue - scrollDifference).clamp(0.0, maxOffset);

        pdva.scrollOffsetNotifier.value = newValue;
        if (newValue == 0) pdva.isToolsMenuVisible.value = false;
      }
    }
  }
}
