import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slidesync/features/browse/presentation/logic/course_materials_provider.dart';
import 'package:slidesync/features/study/presentation/logic/pdf_doc_viewer_provider.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfDocViewerActions {
  static Future<void> onPopInvoked(WidgetRef ref, String contentId, String parentId) async {
    log("did pop");
    final searchStateProvider = PdfDocViewerProvider.searchState(contentId);
    final isSearching = ref.read(searchStateProvider.select((s) => s.isSearchingNotifier)).value;
    if (isSearching) ref.read(searchStateProvider).setSearching(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    (await ref.read(CourseMaterialsProvider.contentPaginationProvider(parentId).future)).restartIsolate();
  }

  static void calcAppBarTranslation(
    WidgetRef ref,
    String contentId,
    // double maxOffset,
    double? prev,
    double next,
  ) async {
    // log("prev: $prev, next: $next");
    final maxOffset = ref.context.topPadding + kToolbarHeight + 12;
    // log("maxOffset: $maxOffset");
    final docStateProvider = PdfDocViewerProvider.state(contentId);
    void updateScrollOffset(double value) => ref.read(docStateProvider).updateScrollOffset(value);

    if (prev == null) {
      updateScrollOffset(0);
    } else {
      final formerValue = (ref.read(docStateProvider.select((s) => s.scrollOffsetNotifier))).value;
      if (prev < next) {
        // Scroll up
        final scrollDifference = next - prev;
        final diff = (formerValue + scrollDifference);
        final newValue = diff.clamp(0.0, maxOffset);
        // log("diff: $diff");
        if (diff > maxOffset && prev == 0.0) {
          updateScrollOffset(0);
        } else {
          updateScrollOffset(newValue);
        }
        // if (newValue == 0) ref.read(docStateProvider).setToolsMenuVisible(false);
      } else {
        // Scroll down
        final scrollDifference = prev - next;
        final diff = (formerValue - scrollDifference);

        final double newValue = diff.clamp(0.0, maxOffset);

        if (diff > maxOffset) {
          updateScrollOffset(0);
        } else {
          updateScrollOffset(newValue);
        }
        // if (newValue == 0) ref.read(docStateProvider).setToolsMenuVisible(false);
      }
    }
  }
}
