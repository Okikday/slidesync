import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/content_viewer/presentation/controllers/doc_viewer_controllers/pdf_doc_search_controller.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

import 'package:pdfrx/pdfrx.dart';

class PdfDocSearchAppBar extends ConsumerStatefulWidget {
  const PdfDocSearchAppBar({super.key, required this.pdfViewerController, required this.pdsa});

  final PdfViewerController pdfViewerController;
  final PdfDocSearchController pdsa;

  @override
  ConsumerState<PdfDocSearchAppBar> createState() => _PdfDocSearchAppBarState();
}

class _PdfDocSearchAppBarState extends ConsumerState<PdfDocSearchAppBar> {
  @override
  Widget build(BuildContext context) {
    final AppTheme theme = ref.theme;
    final pdsa = widget.pdsa;

    return ValueListenableBuilder(
      valueListenable: pdsa.isSearchingNotifier,
      builder: (context, isSearching, _) {
        return Visibility(
          maintainState: true,
          maintainAnimation: true,
          visible: isSearching,
          child: Row(
            children: [
              AppBackButton(
                onPressed: () {
                  pdsa.focusNode.unfocus();
                  pdsa.isSearchingNotifier.value = false;
                },
              ),
              ConstantSizing.rowSpacing(4),
              Expanded(child: _SearchField(pdsa: pdsa)),
              ConstantSizing.rowSpacing(8),
              ValueListenableBuilder(
                valueListenable: pdsa.isSearchInProgressNotifier,
                builder: (context, isInProgress, _) {
                  if (!isInProgress) return const SizedBox.shrink();
                  return SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField({required this.pdsa});

  final PdfDocSearchController pdsa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(10.0),
      child: CustomTextfield(
        autoDispose: false,
        controller: pdsa.searchController,
        focusNode: pdsa.focusNode,
        hint: "Search in document...",
        textInputAction: pdsa.textSearcher == null ? TextInputAction.search : TextInputAction.next,
        onTapOutside: () {},
        onSubmitted: pdsa.performSearch,
        onchanged: (text) {
          if (text.isEmpty) pdsa.clearSearch();
        },
        suffixIcon: ValueListenableBuilder(
          valueListenable: pdsa.searchController,
          builder: (context, controller, _) {
            if (controller.text.isEmpty) return const SizedBox.shrink();
            return InkWell(
              customBorder: CircleBorder(),
              onTap: pdsa.clearSearch,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: theme.supportingText.withAlpha(20),
                child: Icon(Icons.cancel_rounded),
              ),
            );
          },
        ),
        alwaysShowSuffixIcon: true,
        inputContentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
        inputTextStyle: TextStyle(fontSize: 15, color: theme.onBackground),
        cursorColor: theme.primaryColor,
        selectionHandleColor: theme.primaryColor,
        backgroundColor: Colors.transparent,
        border: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
      ),
    );
  }
}
