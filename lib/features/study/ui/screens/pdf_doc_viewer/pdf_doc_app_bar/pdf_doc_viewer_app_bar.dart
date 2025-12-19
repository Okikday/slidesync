import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/ui/actions/pdf_doc_viewer_actions.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/study/ui/screens/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_normal_app_bar.dart';
import 'package:slidesync/features/study/ui/screens/pdf_doc_viewer/pdf_doc_app_bar/pdf_doc_search_app_bar.dart';
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
                return AppBarTranslateTweenBuilder(
                  isAppBarVisible: isAppBarVisible,
                  child: Transform.translate(
                    offset: Offset(0, (-offset)),
                    child: AppBarContainer(child: child!),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PdfDocSearchAppBar(contentId: widget.contentId),
                  PdfDocNormalAppBar(
                    contentId: widget.contentId,
                    title: widget.title,
                    onSearch: () {
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

class AppBarTranslateTweenBuilder extends ConsumerWidget {
  final bool isAppBarVisible;
  final Widget child;
  const AppBarTranslateTweenBuilder({super.key, required this.isAppBarVisible, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder(
      duration: 350.inMs,
      curve: CustomCurves.decelerate,
      tween: Tween<double>(
        begin: isAppBarVisible ? (context.topPadding + kToolbarHeight + 8.0) : 0.0,
        end: isAppBarVisible ? 0.0 : (context.topPadding + kToolbarHeight + 8.0),
      ),
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, -value), child: child!);
      },
      child: child,
    );
  }
}
