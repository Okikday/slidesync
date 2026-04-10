import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/list_course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/empty_library_view.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';

import 'package:slidesync/shared/widgets/progress_indicator/loading_view.dart';

import 'courses_view/course_card/grid_course_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CoursesView extends ConsumerStatefulWidget {
  const CoursesView({super.key});

  @override
  ConsumerState<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends ConsumerState<CoursesView> {
  @override
  Widget build(BuildContext context) {
    final libraryNotifier = MainProvider.library.link(ref);
    final cp = libraryNotifier.coursesPagination.link(ref);

    return SliverPadding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
      sliver: PagingListener(
        controller: cp.pagingController,
        builder: (context, state, fetchNextPage) {
          return libraryNotifier.cardViewType
              .watch(ref)
              .when(
                data: (data) {
                  final isGrid = data == 0;
                  if (!isGrid) {
                    return PagedSliverList<int, Course>(
                      state: state,
                      itemExtent: 120,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        noItemsFoundIndicatorBuilder: (context) => EmptyLibraryView(asSliver: false),
                        newPageProgressIndicatorBuilder: (context) => LoadingListCourseCardSkeletonizer(count: 1),
                        firstPageProgressIndicatorBuilder: (context) => LoadingListCourseCardSkeletonizer(count: 2),
                        firstPageErrorIndicatorBuilder: (context) =>
                            RotatedBox(quarterTurns: 2, child: Icon(Iconsax.info_circle)),
                        itemBuilder: (context, item, index) => CourseCard(item, isGrid),
                      ),
                    );
                  } else {
                    return PagedSliverGrid<int, Course>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: DeviceUtils.isDesktop()
                            ? ((context.deviceWidth / 3) ~/ 140)
                            : context.deviceWidth ~/ 160,
                        crossAxisSpacing: 12,
                      ),

                      builderDelegate: PagedChildBuilderDelegate(
                        noItemsFoundIndicatorBuilder: (context) => EmptyLibraryView(asSliver: false),
                        newPageProgressIndicatorBuilder: (context) => Center(child: LoadingView(msg: "")),
                        firstPageProgressIndicatorBuilder: (context) => LoadingGridCourseCardSkeletonizer(count: 2),
                        firstPageErrorIndicatorBuilder: (context) =>
                            RotatedBox(quarterTurns: 2, child: Icon(Iconsax.info_circle)),
                        itemBuilder: (context, item, index) => CourseCard(item, isGrid),
                      ),
                    );
                  }
                },
                error: (_, _) => const SliverToBoxAdapter(child: Icon(Icons.error_outline)),
                loading: () => SliverToBoxAdapter(child: LoadingListCourseCardSkeletonizer(count: 2)),
              );
        },
      ),
    );
  }
}

class LoadingGridCourseCardSkeletonizer extends StatelessWidget {
  final int count;
  const LoadingGridCourseCardSkeletonizer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: GridView(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.deviceHeight > context.deviceWidth ? 2 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        children: [
          for (int i = 0; i < count; i++)
            Skeletonizer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GridCourseCard(defaultCourse, onTapIcon: () {}),
              ),
            ),
        ],
      ),
    );
  }
}

class LoadingListCourseCardSkeletonizer extends StatelessWidget {
  final int count;
  const LoadingListCourseCardSkeletonizer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (int i = 0; i < count; i++)
            Skeletonizer(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ListCourseCard(defaultCourse, onTapIcon: () {}),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
