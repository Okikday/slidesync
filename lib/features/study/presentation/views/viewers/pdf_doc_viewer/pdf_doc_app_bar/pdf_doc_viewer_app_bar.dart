import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/actions/pdf_doc_viewer_actions.dart';
import 'package:slidesync/features/study/presentation/logic/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_normal_app_bar.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_search_app_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

class PdfDocViewerAppBar extends ConsumerStatefulWidget {
  final String title;
  final String contentId;
  const PdfDocViewerAppBar({super.key, required this.title, required this.contentId});

  @override
  ConsumerState<PdfDocViewerAppBar> createState() => _PdfDocViewerAppBarState();
}

class _PdfDocViewerAppBarState extends ConsumerState<PdfDocViewerAppBar> {
  late final FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docViewP = PdfDocViewerProvider.state(widget.contentId);
    ref.listen(PdfDocViewerState.scrollOffsetProvider, (prev, next) async {
      PdfDocViewerActions.calcAppBarTranslation(ref, widget.contentId, prev, next);
    });
    return Consumer(
      builder: (context, ref, child) {
        final isAppBarVisibleNotifier = ref.watch(docViewP.select((s) => s.isAppBarVisibleNotifier));
        final scrollOffsetNotifier = ref.watch(docViewP.select((s) => s.scrollOffsetNotifier));
        return ValueListenableBuilder(
          valueListenable: isAppBarVisibleNotifier,
          builder: (context, isAppBarVisible, child) {
            return ValueListenableBuilder<double>(
              valueListenable: scrollOffsetNotifier,
              builder: (context, offset, child) {
                log("offset: $offset");
                return Transform.translate(
                  offset: Offset(0, (-offset)),
                  child: AppBarContainer(appBarHeight: isAppBarVisible ? null : 0, child: child!),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PdfDocSearchAppBar(focusNode: focusNode, contentId: widget.contentId),
                  PdfDocNormalAppBar(
                    contentId: widget.contentId,
                    title: widget.title,
                    onSearch: () {
                      focusNode.requestFocus();
                      ref.read(PdfDocViewerProvider.searchState(widget.contentId)).setSearching(true);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
