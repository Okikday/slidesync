import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/controllers/home_tab_controller.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_body/home_dashboard.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_body/more_section.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_body/recents_section/recents_section_body.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/views/home_tab_view/home_body/recents_section/recents_section_header.dart';

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        SliverToBoxAdapter(
          child: Consumer(
            child: HomeDashboard(
              courseName: "Add a course material",
              detail: '',
              progressValue: 0.0,
              isFirst: true,
              onReadingBtnTapped: () async {
                context.pushNamed(Routes.createCourse.name);
              },
            ),
            builder: (context, ref, child) {
              final asyncMostRecent = ref.watch(
                HomeTabController.recentContentsTrackProvider.select(
                  (s) => s.whenData((v) => v.isEmpty ? null : v.last),
                ),
              );
              return asyncMostRecent.when(
                data: (data) {
                  if (data != null) {
                    return HomeDashboard(
                      courseName: data.title ?? "Unknown material",
                      detail: '',
                      progressValue: data.progress ?? 0.0,
                      completed: data.progress == 1.0,
                      isFirst: true,
                      onReadingBtnTapped: () async {
                        final content = await CourseContentRepo.getByContentId(data.contentId);
                        if (content == null) {
                          if (context.mounted) {
                            UiUtils.showFlushBar(context, msg: "Unable to open material");
                          }
                          return;
                        }
                        if (context.mounted) context.pushNamed(Routes.contentGate.name, extra: content);
                      },
                    );
                  }
                  return child!;
                },
                loading: () {
                  return const SizedBox();
                },
                error: (e, st) {
                  return const Center(child: Icon(Icons.error));
                },
              );
            },
          ),
        ),

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),

        const SliverToBoxAdapter(child: MoreSection()),

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),

        // Recents Section Header
        // Won't show up if the recent courses is empty
        const RecentsSectionHeader(),

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingSmall),

        // Recents Section Body
        const RecentsSectionBody(),
      ],
    );
  }
}
