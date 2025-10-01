import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_materials_controller.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/course_materials_view_app_bar.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/materials_search_button.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/add_contents/add_content_fab.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/materials_view.dart';
import 'package:slidesync/shared/common_widgets/app_popup_menu_button.dart';
import 'package:slidesync/shared/components/app_bar_container.dart';
import 'package:slidesync/shared/components/circular_loading_indicator.dart';
import 'package:slidesync/shared/components/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class CourseMaterialsView extends ConsumerStatefulWidget {
  final CourseCollection collection;
  const CourseMaterialsView({super.key, required this.collection});

  @override
  ConsumerState<CourseMaterialsView> createState() => _CourseMaterialsViewState();
}

class _CourseMaterialsViewState extends ConsumerState<CourseMaterialsView> {
  late final ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Result.tryRunAsync(() async {});
    });
  }

  void scrollListener() {
    final scrollOffsetNotifier = ref.read(CourseMaterialsController.scrollOffsetProvider.notifier);
    scrollOffsetNotifier.update((cb) => scrollController.offset); //
    // final prevOffset = scrollOffsetNotifier.state;
    // final currOffset = scrollController.offset;
    // if (currOffset != prevOffset) {
    //   scrollOffsetNotifier.update((cb) => currOffset);
    // }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    // ref.watch(
    //   CourseMaterialsController.contentPaginationProvider(widget.collection.collectionId),
    // );
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(
          child: AppBarContainerChild(
            context.isDarkMode,
            title: widget.collection.collectionTitle,
            trailing: CourseMaterialsViewAppBar(collectionId: widget.collection.collectionId),
          ),
        ),

        floatingActionButton: AddContentFAB(
          collection: widget.collection,
          scrollOffsetProvider: CourseMaterialsController.scrollOffsetProvider,
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            (await ref.read(
              CourseMaterialsController.contentPaginationProvider(widget.collection.collectionId).future,
            )).pagingController.refresh();
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [MaterialsView(collection: widget.collection)],
          ),
        ),
      ),
    );
  }
}
