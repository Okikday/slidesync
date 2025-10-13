import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';

final _pdfDocSearchStateProvider = AsyncNotifierProvider.autoDispose.family(
  (String contentId) => PdfDocSearchNotifier(contentId),
);
AsyncNotifierProvider<PdfDocSearchNotifier, PdfDocSearchState> pdfDocSearchStateProvider(String contentId) =>
    _pdfDocSearchStateProvider(contentId);

class PdfDocSearchController {}

class PdfDocSearchNotifier extends AsyncNotifier<PdfDocSearchState> {
  final String contentId;
  PdfDocSearchNotifier(this.contentId);
  @override
  Future<PdfDocSearchState> build() async {
    // Get the PDF viewer controller from the viewer state
    final viewerState = await ref.watch(pdfDocViewerStateProvider(contentId).future);

    final focusNode = FocusNode();
    final searchController = TextEditingController();

    // Cleanup on dispose
    ref.onDispose(() {
      focusNode.dispose();
      searchController.dispose();
      final current = state.value;
      if (current?.textSearcher != null) {
        current!.textSearcher!.removeListener(_onSearcherChanged);
        current.textSearcher!.dispose();
      }
      log("Disposed pdf search actions");
    });

    return PdfDocSearchState(
      pdfViewerController: viewerState.pdfViewerController,
      focusNode: focusNode,
      searchController: searchController,
    );
  }

  // ============================================================================
  // PUBLIC UPDATE METHODS
  // ============================================================================

  void setSearching(bool isSearching) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isSearching: isSearching));

      if (isSearching) {
        current.focusNode.requestFocus();
      } else {
        clearSearch();
      }
    }
  }

  void performSearch(String searchText) {
    final current = state.value;
    if (current == null) return;

    final text = searchText.trim();
    if (text.isEmpty) return;

    if (searchText == current.textSearcher?.pattern.toString()) {
      Future.microtask(() async {
        await navigateToInstance(true);
      });
      return;
    }

    final old = current.textSearcher;
    if (old != null) {
      old.removeListener(_onSearcherChanged);
      old.dispose();
    }

    final searcher = PdfTextSearcher(current.pdfViewerController);
    searcher.addListener(_onSearcherChanged);
    searcher.startTextSearch(text, caseInsensitive: true, goToFirstMatch: true, searchImmediately: kIsWeb);

    state = AsyncData(current.copyWith(textSearcher: searcher, isSearchInProgress: searcher.isSearching));

    if (kIsWeb && !searcher.isSearching && !searcher.hasMatches) {
      _showNoResultsMessage();
    }

    _incrementTick();
  }

  void clearSearch() {
    final current = state.value;
    if (current == null) return;

    current.searchController.clear();

    final s = current.textSearcher;
    if (s != null) {
      s.removeListener(_onSearcherChanged);
      s.dispose();
    }

    state = AsyncData(current.copyWith(textSearcher: null, isSearchInProgress: false));

    _incrementTick();
  }

  Future<void> navigateToInstance(bool isNext) async {
    final current = state.value;
    if (current == null) return;

    final s = current.textSearcher;
    if (s == null || !s.hasMatches) return;

    final currentIndex = s.currentIndex ?? 0;
    final total = s.matches.length;

    if (isNext && currentIndex == total - 1 && !s.isSearching) {
      _showSearchFromBeginningDialog();
      return;
    }

    if (isNext) {
      await s.goToNextMatch();
    } else {
      await s.goToPrevMatch();
    }

    _incrementTick();
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _onSearcherChanged() {
    final current = state.value;
    if (current == null) return;

    final s = current.textSearcher;
    if (s == null) return;

    state = AsyncData(current.copyWith(isSearchInProgress: s.isSearching));

    if (!s.isSearching && !s.hasMatches) {
      _showNoResultsMessage();
    }

    _incrementTick();
  }

  void _incrementTick() {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(searchTick: current.searchTick + 1));
    }
  }

  void _showNoResultsMessage() {
    final current = state.value;
    if (current == null) return;

    GlobalNav.withContext(
      (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No results found for "${current.searchController.text}"'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }

  void _showSearchFromBeginningDialog() {
    GlobalNav.withContext(
      (context) => showDialog(
        context: context,
        builder: (context) => AppAlertDialog(
          title: 'Search Result',
          content: 'No more occurrences found. Would you like to continue searching from the beginning?',
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final current = state.value;
                final s = current?.textSearcher;
                if (s == null) return;
                await s.goToMatchOfIndex(0);
                _incrementTick();
              },
              child: const Text('YES'),
            ),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('NO')),
          ],
        ),
      ),
    );
  }
}
