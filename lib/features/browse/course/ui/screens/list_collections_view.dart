import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/browse/collection/providers/modify_collection_provider.dart';
import 'package:slidesync/features/browse/course/providers/course_details_provider.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/browse/collection/ui/widgets/add_collection_action_button.dart';
import '../../../collection/ui/widgets/modify_collections/collections_list_view.dart';
import '../../../collection/ui/widgets/collections_search_bar.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

import '../../../../../core/utils/ui_utils.dart';

class ListCollectionsView extends ConsumerStatefulWidget {
  final String courseId;

  const ListCollectionsView({super.key, required this.courseId});

  @override
  ConsumerState createState() => _ModifyCollectionsViewState();
}

class _ModifyCollectionsViewState extends ConsumerState<ListCollectionsView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ModifyCollectionProvider.state);
    final courseProvider = CourseProviders.courseProvider(widget.courseId);

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(
          child: Consumer(
            builder: (context, ref, child) {
              final both = ref.watch(courseProvider.select((c) => c.whenData((cb) => (cb.courseName, cb.courseCode))));

              return both.when(
                data: (data) =>
                    AppBarContainerChild(context.isDarkMode, title: data.$1, tooltipMessage: "${data.$1}(${data.$2})"),
                error: (_, _) => Icon(Icons.error),
                loading: () =>
                    AppBarContainerChild(context.isDarkMode, title: "...", tooltipMessage: "Loading course..."),
              );
            },
          ),
        ),

        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final both = ref.watch(courseProvider.select((c) => c.whenData((cb) => (cb.id))));
            return both.when(
              data: (data) {
                return ValueListenableBuilder(
                  valueListenable: state.scrollOffsetNotifier,
                  builder: (context, value, child) {
                    return AddCollectionActionButton(
                      courseId: widget.courseId,
                      isScrolled: value > 40,
                      onClickUp: () {
                        state.scrollController.animateTo(
                          0.0,
                          duration: Durations.medium1,
                          curve: CustomCurves.defaultIosSpring,
                        );
                      },
                    );
                  },
                );
              },
              error: (_, _) => Icon(Icons.error),
              loading: () => FloatingActionButton(onPressed: () {}, child: LoadingLogo(size: 10)),
            );
          },
        ),

        body: SmoothCustomScrollView(
          controller: state.scrollController,
          slivers: [
            Consumer(
              builder: (context, ref, child) {
                final dataN = ref.watch(courseProvider.select((c) => c.whenData((cb) => cb.collections)));
                return dataN.when(
                  data: (data) {
                    if (data.isEmpty) return const SliverToBoxAdapter();
                    return PinnedHeaderSliver(
                      child: CollectionsViewSearchBar(courseId: widget.courseId, showTrailing: false, onTap: () {}),
                    );
                  },
                  error: (_, _) => const SliverToBoxAdapter(),
                  loading: () => const SliverToBoxAdapter(),
                );
              },
            ),

            CollectionsListView(
              courseId: widget.courseId,
              searchCollectionTextNotifier: ref.read(
                CourseDetailsProvider.state.select((s) => s.searchCollectionTextNotifier),
              ),
            ),
            SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

            // ),
          ],
        ),
      ),
    );
  }
}
