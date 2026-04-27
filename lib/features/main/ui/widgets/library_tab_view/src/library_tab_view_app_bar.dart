import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mira_widgets/mira_widgets.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/library_tab_view_filter_button.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/library_tab_view_header_text.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/library_tab_view_layout_button.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/library_tab_view_search_button.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

final double libraryAppBarMaxHeight = DeviceUtils.isDesktop() ? 160 : 220;
const double libraryAppBarMinHeight = kToolbarHeight;

class LibraryTabViewAppBar extends ConsumerWidget {
  const LibraryTabViewAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return SliverAppBar(
      pinned: true,
      collapsedHeight: libraryAppBarMinHeight,
      expandedHeight: libraryAppBarMaxHeight,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      // backgroundColor: theme.background.withAlpha(200),
      systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(ref.background, ref.isDarkMode),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        titlePadding: EdgeInsets.all(0),
        background: _bgDecoration(ref),
        title: Stack(
          children: [
            SoftEdgeBlur(
              edges: [
                EdgeBlur(
                  type: EdgeType.topEdge,
                  size: 60,
                  sigma: 30,
                  tintColor: theme.background,
                  controlPoints: [
                    ControlPoint(position: 0.4, type: ControlPointType.visible),
                    ControlPoint(position: 1.0, type: ControlPointType.transparent),
                  ],
                ),
              ],
              child: SizedBox.expand(),
            ).sizedBox(h: 80).clipped,

            // Stack
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const LibraryTabViewHeaderText(),

                // Row
                SizedBox(
                  height: kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: AbsorberWatch(
                      listenable: MainProvider.state.select((s) => s.tabIndex),
                      builder: (context, tabIndex, ref, child) {
                        return child!
                            .animate(target: tabIndex == 1 ? 1 : 0)
                            .scaleXY(begin: 0.9, end: 1.0, duration: 400.inMs, curve: CustomCurves.decelerate)
                            .slideX(begin: 0.5, end: 0.0, duration: 600.inMs, curve: CustomCurves.defaultIosSpring)
                            .fadeIn(duration: 400.inMs, curve: CustomCurves.decelerate);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // const Expanded(child: SizedBox()),
                          LibraryTabViewSearchButton(backgroundColor: theme.adjustBgAndSecondaryWithLerp),
                          ConstantSizing.rowSpacing(8.0),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LibraryTabViewFilterButton(),
                              LibraryTabViewLayoutButton(backgroundColor: Colors.transparent),
                            ],
                          ).decoratedBox(
                            BoxDecoration(
                              color: theme.surface.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(10))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DecoratedBox _bgDecoration(WidgetRef ref) {
    final theme = ref;
    return DecoratedBox(
      decoration: BoxDecoration(
        // color: theme.background.withAlpha(200),
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: Assets.images.zigZagWavy.asImageProvider,
          repeat: ImageRepeat.repeat,
          // fit: BoxFit.cover,
          opacity: ref.isDarkMode ? 0.05 : 0.02,
          colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
