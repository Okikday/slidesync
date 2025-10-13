import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfDocSearchState {
  final PdfViewerController pdfViewerController;
  final FocusNode focusNode;
  final TextEditingController searchController;
  final bool isSearchInProgress;
  final bool isSearching;
  final int searchTick;
  final PdfTextSearcher? textSearcher;

  const PdfDocSearchState({
    required this.pdfViewerController,
    required this.focusNode,
    required this.searchController,
    this.isSearchInProgress = false,
    this.isSearching = false,
    this.searchTick = 0,
    this.textSearcher,
  });

  PdfDocSearchState copyWith({
    PdfViewerController? pdfViewerController,
    FocusNode? focusNode,
    TextEditingController? searchController,
    bool? isSearchInProgress,
    bool? isSearching,
    int? searchTick,
    PdfTextSearcher? textSearcher,
  }) {
    return PdfDocSearchState(
      pdfViewerController: pdfViewerController ?? this.pdfViewerController,
      focusNode: focusNode ?? this.focusNode,
      searchController: searchController ?? this.searchController,
      isSearchInProgress: isSearchInProgress ?? this.isSearchInProgress,
      isSearching: isSearching ?? this.isSearching,
      searchTick: searchTick ?? this.searchTick,
      textSearcher: textSearcher ?? this.textSearcher,
    );
  }
}
