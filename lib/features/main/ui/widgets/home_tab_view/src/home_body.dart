import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/providers/home_provider.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/src/home_body/home_dashboard.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/src/home_body/more_section.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/src/home_body/recents_section/recents_section_body.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/src/home_body/recents_section/recents_section_header.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmoothCustomScrollView(
      // physics: const BouncingScrollPhysics(),
      intensity: ScrollIntensity.slow,
      slivers: [
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        SliverToBoxAdapter(
          child: Consumer(
            child: _CheckCourseDashboard(),
            builder: (context, ref, child) {
              final asyncMostRecent = ref.watch(
                HomeProvider.recentContentsTrackProvider(1).select((s) => s.whenData((v) => v.isEmpty ? null : v.last)),
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
                        if (data.progress == 1.0) {
                          ContentTrack? nextContentTrack = await (await ContentTrackRepo.filter)
                              .parentIdEqualTo(content.parentId)
                              .progressLessThan(1.0)
                              .findFirst();
                          nextContentTrack ??= await (await ContentTrackRepo.filter).progressLessThan(1.0).findFirst();
                          if (nextContentTrack == null) return;
                          final nextContent = await CourseContentRepo.getByContentId(nextContentTrack.contentId);
                          if (nextContent == null) return;
                          if (context.mounted) context.pushNamed(Routes.contentGate.name, extra: nextContent);
                        } else {
                          if (context.mounted) context.pushNamed(Routes.contentGate.name, extra: content);
                        }
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

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingExtraLarge),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CustomText("Quick access", color: ref.onBackground, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),

        const SliverToBoxAdapter(child: MoreSection()),

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingExtraLarge),

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

class _CheckCourseDashboard extends StatefulWidget {
  const _CheckCourseDashboard();

  @override
  State<_CheckCourseDashboard> createState() => _CheckCourseDashboardState();
}

class _CheckCourseDashboardState extends State<_CheckCourseDashboard> {
  bool? hasCourse;

  @override
  void initState() {
    super.initState();
    _checkCourses();
  }

  Future<void> _checkCourses() async {
    final count = await (await CourseRepo.filter).courseIdIsNotEmpty().count();
    if (mounted) {
      setState(() {
        hasCourse = count > 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasCourse == null) {
      return HomeDashboard(
        courseName: "Looking around",
        detail: "...",
        buttonText: "",
        progressValue: 0.0,
        isFirst: true,
        onReadingBtnTapped: () async {},
      );
    }

    if (!hasCourse!) {
      return HomeDashboard(
        courseName: "Add a course",
        detail: "Let's add a course to get you started!",
        buttonText: "Get started!",
        progressValue: 0.0,
        isFirst: true,
        onReadingBtnTapped: () async {
          context.pushNamed(Routes.createCourse.name);
        },
      );
    }

    return HomeDashboard(
      courseName: "Start reading",
      detail: "You haven't started reading, get started!",
      buttonText: "Take me there!",
      progressValue: 0.0,
      isFirst: true,
      onReadingBtnTapped: () async {
        final anyCourse = await (await CourseRepo.filter).collectionsIsNotEmpty().findFirst();
        if (anyCourse == null) {
          final anotherCourse = await (await CourseRepo.filter).courseIdIsNotEmpty().findFirst();
          if (anotherCourse == null) {
            GlobalNav.withContext(
              (context) => UiUtils.showFlushBar(
                context,
                msg: "Try creating a new course from Library.",
                flushbarPosition: FlushbarPosition.TOP,
                duration: 2.inSeconds,
              ),
            );
            return;
          } else {
            GlobalNav.withContext(
              (context) => context.pushNamed(Routes.courseDetails.name, extra: anotherCourse.courseId),
            );
            await Future.delayed(1.inSeconds);
            GlobalNav.withContext(
              (context) => UiUtils.showFlushBar(
                context,
                msg: "Add a new collection",
                flushbarPosition: FlushbarPosition.TOP,
                duration: 2.inSeconds,
              ),
            );
            return;
          }
        } else {
          await anyCourse.collections.load();
          final toCollection = anyCourse.collections.first;
          GlobalNav.withContext((context) => context.pushNamed(Routes.courseMaterials.name, extra: toCollection));
          if (toCollection.contents.isEmpty) {
            await Future.delayed(1.inSeconds);
            log("collection is empty");
            GlobalNav.withContext(
              (context) => UiUtils.showFlushBar(
                context,
                msg: "Add some materials to read...",
                flushbarPosition: FlushbarPosition.TOP,
                duration: 2.inSeconds,
              ),
            );
          }
          return;
        }
      },
    );
  }
}
