import 'dart:developer';
import 'dart:math' as math;
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/presentation/controlllers/src/course_materials_controller/course_materials_controller.dart';
import 'package:slidesync/features/main/presentation/main/controllers/main_view_controller.dart';
import 'package:slidesync/features/study/presentation/actions/pdf_doc_viewer_actions.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_viewer_app_bar.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_floating_action_menu.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/navigation_controls.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/pdf_scrollbar_overlay.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_overlay_widgets/pdf_tools_menu.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_viewer_widget.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

class PdfDocViewerInnerSection extends ConsumerStatefulWidget {
  final CourseContent content;
  final PdfDocViewerState pdva;
  final PdfDocSearchState pdsa;

  const PdfDocViewerInnerSection({super.key, required this.content, required this.pdva, required this.pdsa});

  @override
  ConsumerState<PdfDocViewerInnerSection> createState() => _PdfDocViewerInnerSectionState();
}

class _PdfDocViewerInnerSectionState extends ConsumerState<PdfDocViewerInnerSection> {


  @override
  Widget build(BuildContext context) {
    // final theme = ref;
    final maxOffset = context.topPadding + kToolbarHeight + 12;

    ref.listen(PdfDocViewerController.scrollOffsetNotifierProvider, (prev, next) async {
      PdfDocViewerActions.calcAppBarTranslation(ref, widget.pdva, maxOffset, prev, next);
    });
    return ValueListenableBuilder(
      valueListenable: widget.pdsa.isSearchingNotifier,
      builder: (context, isSearching, child) {
        return PopScope(
          canPop: !isSearching,
          onPopInvokedWithResult: (didPop, result) async {
            await PdfDocViewerActions.onPopInvoked(ref, widget.pdsa.isSearchingNotifier, widget.content.parentId);
          },
          child: AnnotatedRegion(
            value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
            child: Scaffold(
              floatingActionButton: PdfFloatingActionMenu(pdsa: widget.pdsa, pdva: widget.pdva),

              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: PdfViewerWidget(content: widget.content, pdva: widget.pdva, pdsa: widget.pdsa),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PdfDocViewerAppBar(title: widget.content.title, pdva: widget.pdva, pdsa: widget.pdsa),
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
