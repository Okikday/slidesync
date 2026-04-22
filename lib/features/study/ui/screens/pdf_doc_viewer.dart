import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/study/ui/actions/pdf_doc_viewer_actions.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_viewer_app_bar.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_floating_action_menu.dart';
import 'package:slidesync/features/study/ui/widgets/pdf_doc_viewer/pdf_viewer_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

class PdfDocViewer extends ConsumerWidget {
  final ModuleContent content;
  const PdfDocViewer({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.watch(PdfDocViewerProvider.state(content.uid).select((s) => s.isInitialized)),
      // ignore: void_checks
      initialData: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
        child: AppScaffold(
          title: "",
          floatingActionButton: PdfFloatingActionMenu(contentId: content.uid),
          body: SizedBox(),
        ),
      ),
      builder: (context, asyncSnapshot) {
        return Consumer(
          builder: (context, ref, child) {
            log("root pdf viewer section rebuild");
            return ValueListenableBuilder(
              valueListenable: ref.watch(
                PdfDocViewerProvider.searchState(content.uid).select((s) => s.isSearchingNotifier),
              ),
              builder: (context, isSearching, _) {
                return PopScope(
                  canPop: !isSearching,
                  onPopInvokedWithResult: (didPop, result) async {
                    await PdfDocViewerActions.onPopInvoked(ref, content.uid, content.parentId);
                  },
                  child: child!,
                );
              },
            );
          },
          child: AnnotatedRegion(
            value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
            child: AppScaffold(
              title: "",
              floatingActionButton: PdfFloatingActionMenu(contentId: content.uid),

              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: PdfViewerWidget(content: content)),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PdfDocViewerAppBar(title: content.title, contentId: content.uid),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
