import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/global_providers/data_providers/course_providers.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/add_collection_action_button.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/collections_list_view.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/collections_view_search_bar.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/empty_collections_view.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

import '../../../../../core/utils/ui_utils.dart';
import '../../../../../shared/components/app_bar_container.dart';

class ModifyCollectionsView extends ConsumerStatefulWidget {
  final String courseId;

  const ModifyCollectionsView({super.key, required this.courseId});

  @override
  ConsumerState createState() => _ModifyCollectionsViewState();
}

class _ModifyCollectionsViewState extends ConsumerState<ModifyCollectionsView> {
  late final ScrollController scrollController;
  late final NotifierProvider<DoubleNotifier, double> scrollOffsetProvider;
  late final TextEditingController searchCollectionController;
  late final ValueNotifier<String> searchCollectionTextNotifier;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollOffsetProvider = NotifierProvider<DoubleNotifier, double>(DoubleNotifier.new, isAutoDispose: true);
    searchCollectionController = TextEditingController();
    searchCollectionTextNotifier = ValueNotifier("");
    scrollController.addListener(listenToscrollOffsetProvider);
    searchCollectionController.addListener(searchCollectionTextListener);
  }

  void listenToscrollOffsetProvider() {
    if (scrollController.positions.isNotEmpty && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(scrollOffsetProvider.notifier).update((cb) => scrollController.offset);
      });
    }
  }

  void searchCollectionTextListener() {
    if (searchCollectionTextNotifier.value == searchCollectionController.text) return;
    searchCollectionTextNotifier.value = searchCollectionController.text;
  }

  @override
  void dispose() {
    searchCollectionController.removeListener(searchCollectionTextListener);
    searchCollectionController.dispose();
    searchCollectionTextNotifier.dispose();
    scrollController.removeListener(listenToscrollOffsetProvider);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourseValue = ref.watch(CourseProviders.courseProvider(widget.courseId));
    final Course course = asyncCourseValue.value ?? defaultCourse;

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(
          child: AppBarContainerChild(
            context.isDarkMode,
            title: course.courseName,
            tooltipMessage: "${course.courseName}(${course.courseCode})",
          ),
        ),

        floatingActionButton: course.collections.isNotEmpty
            ? AddCollectionActionButton(
                courseDbId: course.id,
                isScrolled: ref.watch(scrollOffsetProvider) > 40,
                onClickUp: () {
                  scrollController.animateTo(0.0, duration: Durations.medium1, curve: CustomCurves.defaultIosSpring);
                },
              )
            : null,

        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            if (course.collections.isNotEmpty)
              PinnedHeaderSliver(
                child: CollectionsViewSearchBar(
                  searchCollectionTextNotifier: searchCollectionTextNotifier,
                  onTap: () {
                    // scrollController.animateTo(
                    //   appBarHeight + 8,
                    //   duration: Durations.medium4,
                    //   curve: CustomCurves.defaultIosSpring,
                    // );
                  },
                ),
              ),

            if (course.collections.isNotEmpty)
              CollectionsListView(
                courseDbId: course.id,
                asyncCourseValue: asyncCourseValue,
                searchCollectionTextNotifier: searchCollectionTextNotifier,
              )
            else
              EmptyCollectionsView(
                onClickAddCollection: () {
                  CustomDialog.show(
                    context,
                    canPop: true,
                    barrierColor: Colors.black.withAlpha(150),
                    child: CreateCollectionBottomSheet(courseDbId: course.id),
                  );
                },
              ),
            SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

            // ),
          ],
        ),
      ),
    );
  }
}
