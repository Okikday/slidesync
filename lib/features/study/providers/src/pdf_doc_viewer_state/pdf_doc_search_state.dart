import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/base/mixins/use_value_notifier.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfDocSearchState with ValueNotifierFactoryMixin {
  final String contentId;
  final PdfViewerController pdfViewerController;
  final FocusNode focusNode;
  final TextEditingController searchController;

  PdfTextSearchResult? _searchResult;

  /// Exposes the current search result (null when no search is active).
  PdfTextSearchResult? get searchResult => _searchResult;

  // Convenience getters for backward-compatible access from UI widgets
  bool get hasSearchResult => _searchResult?.hasResult == true;
  bool get isSearching => _searchResult != null && !(_searchResult!.isSearchCompleted);
  int get currentMatchIndex => _searchResult?.currentInstanceIndex ?? 0;
  int get totalMatchCount => _searchResult?.totalInstanceCount ?? 0;

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
    _clearSearchResult();
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

    // Clear previous search
    _clearSearchResult();

    final result = pdfViewerController.searchText(
      text,
    );

    _searchResult = result;
    isSearchInProgressNotifier.value = !result.isSearchCompleted;

    // Listen for search progress updates
    result.addListener(_onSearchResultChanged);

    if (result.isSearchCompleted && !result.hasResult) {
      _showNoResultsMessage();
    }

    _incrementTick();
  }

  void clearSearch() {
    searchController.clear();
    _clearSearchResult();
    isSearchInProgressNotifier.value = false;
    _incrementTick();
  }

  Future<void> navigateToInstance(bool isNext) async {
    final result = _searchResult;
    if (result == null || !result.hasResult) return;

    final isAtEnd = result.currentInstanceIndex == result.totalInstanceCount;

    if (isNext && isAtEnd && result.isSearchCompleted) {
      _showSearchFromBeginningDialog();
      return;
    }

    if (isNext) {
      result.nextInstance();
    } else {
      result.previousInstance();
    }

    _incrementTick();
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _clearSearchResult() {
    if (_searchResult != null) {
      _searchResult!.removeListener(_onSearchResultChanged);
      _searchResult!.clear();
      _searchResult = null;
    }
  }

  void _onSearchResultChanged() {
    final result = _searchResult;
    if (result == null) return;

    isSearchInProgressNotifier.value = !result.isSearchCompleted;

    if (result.isSearchCompleted && !result.hasResult) {
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
          onCancel: () {
            context.pop();
          },
          onConfirm: () async {
            Navigator.of(context).pop();
            final result = _searchResult;
            if (result == null) return;
            result.nextInstance();
            _incrementTick();
          },
        ),
      ),
    );
  }
}
