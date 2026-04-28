import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/actions/library/courses_view_actions.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card/list_course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/empty_library_view.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';

import 'package:slidesync/shared/widgets/progress_indicator/loading_view.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

import 'courses_view/course_card/grid_course_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CoursesView extends ConsumerStatefulWidget {
  const CoursesView({super.key});

  @override
  ConsumerState<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends ConsumerState<CoursesView> with CoursesViewActions {
  @override
  Widget build(BuildContext context) {
    final cp = MainProvider.library.link(ref).coursesPagination.link(ref);

    return SliverPadding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
      sliver: PagingListener(
        controller: cp.pagingController,
        builder: (context, state, fetchNextPage) {
          return AbsorberWatch(
            listenable: MainProvider.library.select((s) => (cardType: s.cardViewType, loading: s.isLoading)),
            builder: (context, libState, ref, _) {
              if (state.isLoading) return SliverToBoxAdapter(child: LoadingListCourseCardSkeletonizer(count: 2));
              if (libState.cardType == CardViewType.grid) {
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
                    itemBuilder: (context, item, index) => CourseCard(
                      item,
                      libState.cardType,
                      onTap: () => onTapCourseCard(ref, course: item),
                      onLongPress: () => onHoldCourseCard(ref, course: item),
                      onTapDown: (det) => onTapDown(ref, det.globalPosition),
                    ),
                  ),
                );
              }
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
                  itemBuilder: (context, item, index) => CourseCard(
                    item,
                    libState.cardType,
                    onTap: () => onTapCourseCard(ref, course: item),
                    onLongPress: () => onHoldCourseCard(ref, course: item),
                    onTapDown: (det) => onTapDown(ref, det.globalPosition),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void onTapDown(WidgetRef ref, Offset det) => MainProvider.library.act(ref).cardTapPositionDetails = det;
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
