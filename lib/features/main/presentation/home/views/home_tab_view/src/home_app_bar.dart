
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/presentation/main/controllers/main_view_controller.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key, required this.onClickUserIcon, required this.title, required this.onClickNotification});

  final void Function() onClickUserIcon;

  final String title;
  final void Function() onClickNotification;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final appBarHeight = kToolbarHeight + (context.topPadding / 2);

    return Consumer(
      builder: (context, ref, child) {
        final bool isScrolled = ref.watch(MainViewController.isMainScrolledProvider);
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
            statusBarColor: isScrolled
                ? theme.background.lightenColor(theme.isDarkMode ? .1 : .9)
                : context.scaffoldBackgroundColor,
            statusBarBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarIconBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
          ),
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.0,
            background: GestureDetector(
              onTap: () {},
              child: Material(
                type: MaterialType.transparency,
                shape: isScrolled
                    ? LinearBorder(
                        bottom: LinearBorderEdge(),
                        side: BorderSide(color: theme.altBackgroundSecondary.withValues(alpha: 0.4)),
                      )
                    : null,
                child: AnimatedContainer(
                  duration: Durations.medium3,
                  clipBehavior: Clip.hardEdge,
                  color: isScrolled ? theme.surface.withValues(alpha: 0.9) : theme.background,
                  child: isScrolled ? const SizedBox.expand() : null,
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
                        CustomElevatedButton(
                          onClick: onClickUserIcon,
                          pixelHeight: 48,
                          pixelWidth: 48,
                          contentPadding: EdgeInsets.zero,
                          backgroundColor: theme.adjustBgAndPrimaryWithLerp,
                          shape: CircleBorder(side: BorderSide(color: theme.onSurface.withValues(alpha: .05))),
                          child: Icon(Iconsax.menu_1_copy, color: theme.onBackground, size: 48 * 0.5),
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

                        CustomElevatedButton(
                          onClick: onClickNotification,
                          overlayColor: ref.secondary.withAlpha(40),
                          shape: CircleBorder(
                            side: BorderSide(color: theme.altBackgroundSecondary.withValues(alpha: 0.4)),
                          ),
                          backgroundColor: theme.adjustBgAndSecondaryWithLerp,
                          child: Badge(
                            backgroundColor: Colors.transparent,
                            offset: Offset(-1, -1),
                            child: Icon(Iconsax.crop, color: theme.supportingText, size: 24),
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
