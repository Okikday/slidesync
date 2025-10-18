import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/presentation/library/controllers/courses_view_controller.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar/library_tab_view_filter_button.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar/library_tab_view_header_text.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar/library_tab_view_layout_button.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar/library_tab_view_search_button.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

const double libraryAppBarMaxHeight = 220;
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
        background: DecoratedBox(
          decoration: BoxDecoration(
            // color: theme.background.withAlpha(200),
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: Assets.images.zigzagWavy.asImageProvider,
              repeat: ImageRepeat.repeat,
              // fit: BoxFit.cover,
              opacity: ref.isDarkMode ? 0.02 : 0.01,
              colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
            ),
          ),
        ),
        title: ClipRRect(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              const LibraryTabViewHeaderText(),
              SizedBox(
                height: kToolbarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    spacing: 8.0,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // const Expanded(child: SizedBox()),
                      LibraryTabViewSearchButton(backgroundColor: theme.adjustBgAndSecondaryWithLerp),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.surface.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(10))),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LibraryTabViewFilterButton(),
                            LibraryTabViewLayoutButton(
                              layoutProvider: CoursesViewController.cardViewTypeProvider,
                              backgroundColor: Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
