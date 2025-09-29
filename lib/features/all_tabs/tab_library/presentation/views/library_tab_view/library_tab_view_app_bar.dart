import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/library_tab_controller.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar/library_tab_view_filter_button.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar/library_tab_view_header_text.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar/library_tab_view_layout_button.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar/library_tab_view_search_button.dart';
import 'package:slidesync/shared/assets/assets.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

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
      backgroundColor: theme.background.withAlpha(200),

      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        titlePadding: EdgeInsets.all(0),
        background: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.background.withAlpha(200),
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: Assets.images.eduElements.asImageProvider,
              repeat: ImageRepeat.repeat,
              // fit: BoxFit.cover,
              opacity: 0.02,
              colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
            ),
          ),
        ),
        title: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Stack(
              // fit: StackFit.expand,
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
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const LibraryTabViewFilterButton(),
                              LibraryTabViewLayoutButton(layoutProvider: CoursesViewController.cardViewTypeProvider),
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
      ),
    );
  }
}
