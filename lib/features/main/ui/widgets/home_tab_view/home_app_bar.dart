import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key, required this.onClickHamburger, required this.title, required this.onClickNotification});

  final void Function() onClickHamburger;

  final String title;
  final void Function() onClickNotification;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final appBarHeight = kToolbarHeight + (context.topPadding / 2);

    return Consumer(
      builder: (context, ref, child) {
        // final bool isScrolled = ref.watch(MainProvider.isHomeScrolledProvider);
        return SliverAppBar(
          elevation: 64,
          pinned: true,
          automaticallyImplyLeading: false,
          centerTitle: false,
          leadingWidth: 0,
          expandedHeight: appBarHeight,
          collapsedHeight: appBarHeight,
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.background.withValues(alpha: 0.6),
            statusBarBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarIconBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
          ),
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.0,
            background: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                child: SizedBox(
                  height: 80,

                  child: SoftEdgeBlur(
                    edges: [
                      EdgeBlur(
                        type: EdgeType.topEdge,
                        size: 80,
                        sigma: 30,
                        tintColor: theme.background,
                        controlPoints: [
                          ControlPoint(position: 0.4, type: ControlPointType.visible),
                          ControlPoint(position: 1.0, type: ControlPointType.transparent),
                        ],
                      ),
                    ],
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
            // collapseMode: CollapseMode.pin,
            titlePadding: EdgeInsets.zero,
            title: Align(
              alignment: Alignment(0, 0.75),
              child: GestureDetector(
                onTap: () {
                  PrimaryScrollController.of(
                    context,
                  ).animateTo(0, duration: Durations.extralong1, curve: CustomCurves.defaultIosSpring);
                },
                child: AnimatedSize(
                  duration: Durations.medium3,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: CustomElevatedButton(
                              onClick: onClickHamburger,
                              pixelHeight: 48,
                              pixelWidth: 48,
                              contentPadding: EdgeInsets.zero,
                              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                              shape: CircleBorder(side: BorderSide(color: theme.onSurface.withValues(alpha: .1))),
                              child: Icon(Iconsax.menu_1_copy, color: theme.onBackground, size: 48 * 0.5),
                            ),
                          ),
                        ),

                        ConstantSizing.rowSpacingMedium,
                        Expanded(
                          child: CustomText(
                            title,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.onBackground,
                          ),
                        ),

                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: CustomElevatedButton(
                              onClick: onClickNotification,
                              pixelWidth: 44,
                              pixelHeight: 44,
                              overlayColor: ref.secondary.withAlpha(40),
                              contentPadding: EdgeInsets.zero,
                              shape: CircleBorder(
                                side: BorderSide(color: theme.altBackgroundSecondary.withValues(alpha: 0.4)),
                              ),
                              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                              child: Badge(
                                backgroundColor: Colors.transparent,
                                offset: Offset(-1, -1),
                                child: Icon(HugeIconsSolid.focusPoint, color: theme.supportingText, size: 24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
