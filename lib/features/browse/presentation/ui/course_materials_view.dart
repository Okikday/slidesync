import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/browse/presentation/logic/course_materials_provider.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials/course_materials_view_app_bar.dart';
import 'package:slidesync/features/manage/presentation/contents/ui/add_contents/add_content_fab.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials/materials_view.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class CourseMaterialsView extends ConsumerStatefulWidget {
  final CourseCollection collection;
  final bool isFullScreen;
  const CourseMaterialsView({super.key, required this.collection, required this.isFullScreen});

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
    final scrollOffsetNotifier = ref.read(CourseMaterialsProvider.scrollOffsetProvider.notifier);
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
    // final theme = ref;
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
            trailing: CourseMaterialsViewAppBar(collectionId: widget.collection.collectionId, isFullScreen: widget.isFullScreen,),
          ),
        ),

        floatingActionButton: AddContentFAB(
          collection: widget.collection,
          scrollOffsetProvider: CourseMaterialsProvider.scrollOffsetProvider,
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            (await ref.read(
              CourseMaterialsProvider.contentPaginationProvider(widget.collection.collectionId).future,
            )).pagingController.refresh();
          },
          child: SmoothCustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              MaterialsView(collectionId: widget.collection.collectionId, isFullScreen: widget.isFullScreen),
              SliverToBoxAdapter(child: BottomPadding(withHeight: 64)),
            ],
          ),
        ),
      ),
    );
  }
}
