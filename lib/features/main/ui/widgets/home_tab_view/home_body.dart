import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/actions/home/home_tab_actions.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/home_dashboard.dart';
// import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/more_section.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recents_section_body.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recents_section_header.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

class HomeBody extends ConsumerStatefulWidget {
  const HomeBody({super.key});

  @override
  ConsumerState<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<HomeBody> with HomeTabActions {
  final hasAnyCourseFuture = CourseRepo.filter.then((filter) => filter.uidIsNotEmpty().count().then((c) => c > 0));

  @override
  Widget build(BuildContext context) {
    final tabIndex = MainProvider.state.select((s) => s.tabIndex).watch(ref);
    return SmoothCustomScrollView(
      physics: const BouncingScrollPhysics(),
      intensity: ScrollIntensity.slow,
      slivers: [
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        SliverToBoxAdapter(
          child: AbsorberWatch(
            listenable: MainProvider.home
                .link(ref)
                .recentContentsTrack(1)
                .select((s) => s.whenData((v) => v.isEmpty ? null : v.last)),

            builder: (context, recentContentTrack, ref, child) {
              return recentContentTrack.when(
                data: (data) {
                  if (data != null) {
                    return HomeDashboard(
                          data: data,
                          isFirst: true,
                          onReadingBtnTapped: () => onReadingButtonTapped(ref, data: data),
                        )
                        .animate(target: tabIndex == 0 ? 1 : 0)
                        .scaleXY(begin: 0.95, end: 1.0, duration: 400.inMs, curve: CustomCurves.decelerate)
                        .fadeIn(duration: 400.inMs, curve: CustomCurves.decelerate);
                  }
                  return child!;
                },
                loading: () => const SizedBox(),
                error: (e, st) => const Center(child: Icon(Icons.error)),
              );
            },
            child: FutureBuilder(
              future: hasAnyCourseFuture,
              builder: (context, hasAnyCourseSnap) =>
                  HomeDashboard.defaultConfig(hasAnyCourseSnap.data, onEmptyReadingButtonTapped),
            ),
          ),
        ),

        // const SliverToBoxAdapter(child: ConstantSizing.columnSpacingExtraLarge),

        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.only(left: 12),
        //     child: CustomText("Quick access", color: ref.onBackground, fontSize: 16, fontWeight: FontWeight.bold),
        //   ),
        // ),
        // // const SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),

        // // const SliverToBoxAdapter(child: MoreSection()),
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingExtraLarge),

        // Recents Section Header
        // Won't show up if the recent courses is empty
        const RecentsSectionHeader(),

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingSmall),

        // Recents Section Body
        const RecentsSectionBody(),

        const SliverToBoxAdapter(child: BottomPadding(withHeight: 84)),
      ],
    );
  }
}
