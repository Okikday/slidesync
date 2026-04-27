import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recent_list_tile.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recents_section_body.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class RecentsView extends ConsumerWidget {
  const RecentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final asyncProgressTrackValues = MainProvider.home.link(ref).recentContentsTrack(100).watch(ref);

    return AppScaffold(
      title: "",
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
              return RecentListTile(
                dataModel: RecentListTileModel(
                  title: content.title.isEmpty ? "No title" : content.title,
                  subtitle: () {
                    final description = content.description;
                    return description.isNotEmpty
                        ? description.substring(0, description.length).padRight(3, '.')
                        : "No subtitle";
                  }(),
                  // extraContent: DummySlides.dummySlides[index]['extraContent'] as String? ?? "",
                  previewPath: content.thumbnail,
                  progressLevel: ProgressLevel.neutral,
                  isStarred: false,
                  progress: content.progress.clamp(0, 1.0),
                  onTapTile: () async {
                    final toPushContent = await ModuleContentRepo.getByUid(content.uid);
                    if (toPushContent == null) return;
                    GlobalNav.withContext((context) => ContentViewGateActions.redirectToViewer(ref, toPushContent));
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
    );
  }
}
