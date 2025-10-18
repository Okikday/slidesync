import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/presentation/courses/views/select_to_modify_course/empty_courses_view.dart';
import 'package:slidesync/features/manage/presentation/courses/views/select_to_modify_course/edit_course_tile.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_view.dart';
import 'package:slidesync/shared/widgets/z_rand/selected_items_count_popup.dart';

class SelectToModifyCourseOuterSection extends ConsumerStatefulWidget {
  const SelectToModifyCourseOuterSection({
    super.key,
    required this.isSelecting,
    required this.selectedCoursesIdProvider,
    required this.selectedCoursesIdMap,
  });

  final bool isSelecting;
  final NotifierProvider<ImpliedNotifier<Map<int, bool>>, Map<int, bool>> selectedCoursesIdProvider;
  final Map<int, bool> selectedCoursesIdMap;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectToModifyCourseOuterSectionState();
}

class _SelectToModifyCourseOuterSectionState extends ConsumerState<SelectToModifyCourseOuterSection> {
  late final StreamProvider<List<Course>> streamedCoursesProvider;
  @override
  void initState() {
    super.initState();
    streamedCoursesProvider = StreamProvider((ref) => CourseRepo.watchAllCourses());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Course>> asyncStreamedCourses = ref.watch(streamedCoursesProvider);
    final selectedCoursesIdMap = widget.selectedCoursesIdMap;

    return CustomScrollView(
      slivers: [
        if (selectedCoursesIdMap.isNotEmpty && selectedCoursesIdMap.containsValue(true))
          PinnedHeaderSliver(
            child: SelectedItemsCountPopUp(selectedItemsCount: selectedCoursesIdMap.values.where((v) => v).length),
          ),
        asyncStreamedCourses.when(
          data: (data) {
            if (data.isEmpty) {
              return EmptyCoursesView();
            }

            return SliverList.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final course = data[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: EditCourseTile(
                    courseName: course.courseName,
                    courseCode: course.courseCode,
                    categoriesCount: course.collections.length,
                    selectionState: (
                      selected: selectedCoursesIdMap.isNotEmpty && selectedCoursesIdMap[course.id] == true,
                      isSelecting: widget.isSelecting,
                    ),
                    syncImagePath: course.imageLocationJson,
                    onTap: () {
                      if (widget.isSelecting) {
                        final selectedCoursesId = ref.read(widget.selectedCoursesIdProvider);
                        if (selectedCoursesId[course.id] == null) {
                          ref
                              .read(widget.selectedCoursesIdProvider.notifier)
                              .update((cb) => {...selectedCoursesIdMap, course.id: true});
                        } else {
                          ref
                              .read(widget.selectedCoursesIdProvider.notifier)
                              .update((cb) => {...selectedCoursesIdMap, course.id: !selectedCoursesId[course.id]!});
                        }
                        if (!selectedCoursesId.containsValue(true)) {
                          ref.read(widget.selectedCoursesIdProvider.notifier).update((cb) => <int, bool>{});
                        }
                        return;
                      }
                      Navigator.of(context).pop();

                      // ref.read(CourseProviders.courseProvider.notifier).update(course);
                      context.pushNamed(Routes.modifyCourse.name, extra: course.courseId);
                    },
                    onSelected: () {
                      log("Selection");
                      final selectedCoursesId = ref.read(widget.selectedCoursesIdProvider);
                      if (selectedCoursesId[course.id] == null) {
                        ref
                            .read(widget.selectedCoursesIdProvider.notifier)
                            .update((cb) => {...selectedCoursesIdMap, course.id: true});
                      } else {
                        ref
                            .read(widget.selectedCoursesIdProvider.notifier)
                            .update((cb) => {...selectedCoursesIdMap, course.id: !selectedCoursesId[course.id]!});
                      }
                      if (!selectedCoursesId.containsValue(true)) {
                        ref.read(widget.selectedCoursesIdProvider.notifier).update((cb) => <int, bool>{});
                      }
                    },
                  ),
                );
              },
            );
          },
          error: (_, _) => SliverToBoxAdapter(
            child: SizedBox(
              height: context.deviceHeight / 2 - 24,
              child: Center(child: const Icon(Icons.error_rounded)),
            ),
          ),
          loading: () => SliverToBoxAdapter(
            child: SizedBox(
              height: context.deviceHeight / 2 - 48,
              child: Center(child: LoadingView(msg: "Loading Courses...")),
            ),
          ),
        ),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
      ],
    );
  }
}
