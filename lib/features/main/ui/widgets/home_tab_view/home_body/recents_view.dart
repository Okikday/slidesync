import 'dart:convert';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/main/providers/home_provider.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recent_list_tile.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recents_section_body.dart';
import 'package:slidesync/routes/routes.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class RecentsView extends ConsumerWidget {
  const RecentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final AsyncValue<List<ContentTrack>> asyncProgressTrackValues = ref.watch(
      HomeProvider.recentContentsTrackProvider(100),
    );
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(theme.scaffoldBackgroundColor, theme.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(child: AppBarContainerChild(theme.isDarkMode, title: "Recent reads")),
        body: asyncProgressTrackValues.when(
          data: (data) {
            if (data.isEmpty) {
              return Center(child: CustomText("No recent reads", color: ref.onBackground));
            }
            return SmoothListView.builder(
              itemCount: data.length,
              padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + context.bottomPadding / 2),
              itemBuilder: (context, index) {
                final content = data[index];
                final previewPath = jsonDecode(content.metadataJson)['previewPath'];
                return RecentListTile(
                  dataModel: RecentListTileModel(
                    title: content.title ?? "No title",
                    subtitle:
                        content.description?.substring(0, content.description?.length).padRight(3, '.') ??
                        "No subtitle",
                    // extraContent: DummySlides.dummySlides[index]['extraContent'] as String? ?? "",
                    previewPath: previewPath,
                    progressLevel: ProgressLevel.neutral,
                    isStarred: false,
                    progress: content.progress?.clamp(0, 1.0),
                    onTapTile: () async {
                      final toPushContent = await CourseContentRepo.getByContentId(content.contentId);
                      if (toPushContent == null) return;
                      GlobalNav.withContext(
                        (context) => context.pushNamed(Routes.contentGate.name, extra: toPushContent),
                      );
                    },
                    onLongTapTile: () {},
                  ),
                );
              },
            );
          },
          error: (e, st) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Icon(Icons.error_rounded, size: 64, color: theme.primary),
                  CustomText("Oops, we couldn't load up your recent reads", color: theme.onBackground),
                ],
              ),
            );
          },
          loading: () {
            return LoadingRecentsSection();
          },
        ),
      ),
    );
  }
}
