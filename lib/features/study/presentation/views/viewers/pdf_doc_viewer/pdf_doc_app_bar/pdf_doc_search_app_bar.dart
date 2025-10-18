import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/presentation/logic/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_search_state.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfDocSearchAppBar extends ConsumerStatefulWidget {
  const PdfDocSearchAppBar({super.key, required this.contentId, required this.focusNode});
  final String contentId;
  final FocusNode focusNode;

  @override
  ConsumerState<PdfDocSearchAppBar> createState() => _PdfDocSearchAppBarState();
}

class _PdfDocSearchAppBarState extends ConsumerState<PdfDocSearchAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;

    final pdsaP = PdfDocViewerProvider.searchState(widget.contentId);
    final isSearching =
        ref.watch(PdfDocViewerProvider.searchState(widget.contentId).select((s) => s.value?.isSearching)) ?? false;

    return Visibility(
      maintainState: true,
      maintainAnimation: true,
      visible: isSearching,
      child: Consumer(
        child: AppBackButton(
          onPressed: () {
            final pdsa = ref.read(pdsaP).value;
            widget.focusNode.unfocus();
            pdsa?.setSearching(false);
          },
        ),
        builder: (context, ref, child) {
          final pdsa = ref.watch(pdsaP).value;
          return Row(
            children: [
              child!,
              ConstantSizing.rowSpacing(4),
              Expanded(
                child: CustomTextfield(
                  autoDispose: false,
                  controller: pdsa?.searchController,
                  focusNode: widget.focusNode,
                  hint: "Search in document...",
                  textInputAction: pdsa?.textSearcher == null ? TextInputAction.search : TextInputAction.next,
                  onTapOutside: () {},
                  onSubmitted: ref.read(pdsaP).value?.performSearch,
                  onchanged: (text) {
                    if (text.isEmpty) ref.read(pdsaP).value?.clearSearch();
                  },
                  suffixIcon: Builder(
                    builder: (context) {
                      final controller = ref.watch(pdsaP).value?.searchController;
                      if (controller == null || controller.text.isEmpty) return const SizedBox.shrink();
                      return InkWell(
                        customBorder: CircleBorder(),
                        onTap: ref.read(pdsaP).value?.clearSearch,
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
              ),
              ConstantSizing.rowSpacing(8),
              Builder(
                builder: (context) {
                  final isInProgress = ref.watch(pdsaP).value?.isSearchInProgress;
                  if (isInProgress == null || !isInProgress) return const SizedBox.shrink();
                  return SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
