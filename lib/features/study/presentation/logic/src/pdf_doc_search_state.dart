import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';

class PdfDocSearchState with ValueNotifierFactoryMixin {
  final String contentId;
  final PdfViewerController pdfViewerController;
  final FocusNode focusNode;
  final TextEditingController searchController;

  PdfTextSearcher? textSearcher;
  late final ValueNotifier<bool> isSearchingNotifier;
  late final ValueNotifier<bool> isSearchInProgressNotifier;
  late final ValueNotifier<int> searchTickNotifier;

  PdfDocSearchState({required this.contentId, required this.pdfViewerController})
    : focusNode = FocusNode(),
      searchController = TextEditingController() {
    isSearchingNotifier = useValueNotifier(false);
    isSearchInProgressNotifier = useValueNotifier(false);
    searchTickNotifier = useValueNotifier(0);
  }

  void dispose() {
    focusNode.dispose();
    searchController.dispose();
    disposeNotifiers();
    if (textSearcher != null) {
      textSearcher!.removeListener(_onSearcherChanged);
      textSearcher!.dispose();
    }
    log("Disposed pdf search actions");
  }

  // ============================================================================
  // PUBLIC UPDATE METHODS
  // ============================================================================

  void setSearching(bool searching) {
    isSearchingNotifier.value = searching;
    if (searching) {
      focusNode.requestFocus();
    } else {
      clearSearch();
    }
  }

  void performSearch(String searchText) {
    final text = searchText.trim();
    if (text.isEmpty) return;

    if (searchText == textSearcher?.pattern.toString()) {
      Future.microtask(() async {
        await navigateToInstance(true);
      });
      return;
    }

    final old = textSearcher;
    if (old != null) {
      old.removeListener(_onSearcherChanged);
      old.dispose();
    }

    final searcher = PdfTextSearcher(pdfViewerController);
    searcher.addListener(_onSearcherChanged);
    searcher.startTextSearch(text, caseInsensitive: true, goToFirstMatch: true, searchImmediately: kIsWeb);

    textSearcher = searcher;
    isSearchInProgressNotifier.value = searcher.isSearching;

    if (kIsWeb && !searcher.isSearching && !searcher.hasMatches) {
      _showNoResultsMessage();
    }

    _incrementTick();
  }

  void clearSearch() {
    searchController.clear();

    if (textSearcher != null) {
      textSearcher!.removeListener(_onSearcherChanged);
      textSearcher!.dispose();
    }

    textSearcher = null;
    isSearchInProgressNotifier.value = false;
    _incrementTick();
  }

  Future<void> navigateToInstance(bool isNext) async {
    if (textSearcher == null || !textSearcher!.hasMatches) return;

    final currentIndex = textSearcher!.currentIndex ?? 0;
    final total = textSearcher!.matches.length;

    if (isNext && currentIndex == total - 1 && !textSearcher!.isSearching) {
      _showSearchFromBeginningDialog();
      return;
    }

    if (isNext) {
      await textSearcher!.goToNextMatch();
    } else {
      await textSearcher!.goToPrevMatch();
    }

    _incrementTick();
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _onSearcherChanged() {
    if (textSearcher == null) return;

    isSearchInProgressNotifier.value = textSearcher!.isSearching;

    if (!textSearcher!.isSearching && !textSearcher!.hasMatches) {
      _showNoResultsMessage();
    }

    _incrementTick();
  }

  void _incrementTick() {
    searchTickNotifier.value++;
  }

  void _showNoResultsMessage() {
    GlobalNav.withContext(
      (context) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No results found for "${searchController.text}"'),
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
                if (textSearcher == null) return;
                await textSearcher!.goToMatchOfIndex(0);
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
