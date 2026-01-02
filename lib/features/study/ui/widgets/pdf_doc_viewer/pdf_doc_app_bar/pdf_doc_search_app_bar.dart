import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfDocSearchAppBar extends ConsumerStatefulWidget {
  const PdfDocSearchAppBar({super.key, required this.contentId});
  final String contentId;

  @override
  ConsumerState<PdfDocSearchAppBar> createState() => _PdfDocSearchAppBarState();
}

class _PdfDocSearchAppBarState extends ConsumerState<PdfDocSearchAppBar> {
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;

    final pdsaP = PdfDocViewerProvider.searchState(widget.contentId);

    return ValueListenableBuilder(
      valueListenable: ref.watch(
        PdfDocViewerProvider.searchState(widget.contentId).select((s) => s.isSearchingNotifier),
      ),
      builder: (context, isSearching, child) {
        return Visibility(
          maintainState: true,
          maintainAnimation: true,
          visible: isSearching,
          child: Consumer(
            child: AppBackButton(
              onPressed: () {
                final pdsa = ref.read(pdsaP);
                focusNode.unfocus();
                pdsa.setSearching(false);
              },
            ),
            builder: (context, ref, child) {
              final pdsa = ref.watch(pdsaP);
              return Row(
                children: [
                  child!,
                  ConstantSizing.rowSpacing(4),
                  Expanded(
                    child: CustomTextfield(
                      autoDispose: false,
                      controller: pdsa.searchController,
                      focusNode: focusNode,
                      hint: "Search in document...",
                      textInputAction: pdsa.textSearcher == null ? TextInputAction.search : TextInputAction.next,
                      onTapOutside: () {},
                      onSubmitted: ref.read(pdsaP).performSearch,
                      onchanged: (text) {
                        if (text.isEmpty) ref.read(pdsaP).clearSearch();
                      },
                      suffixIcon: Builder(
                        builder: (context) {
                          final controller = ref.watch(pdsaP).searchController;
                          if (controller.text.isEmpty) return const SizedBox.shrink();
                          return InkWell(
                            customBorder: CircleBorder(),
                            onTap: ref.read(pdsaP).clearSearch,
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
                  ValueListenableBuilder(
                    valueListenable: ref.watch(pdsaP).isSearchInProgressNotifier,
                    builder: (context, isInProgress, child) {
                      if (!isInProgress) return const SizedBox.shrink();
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
      },
    );
  }
}
