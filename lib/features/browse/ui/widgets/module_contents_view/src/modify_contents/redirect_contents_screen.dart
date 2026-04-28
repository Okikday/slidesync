import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/ui/screens/course_view.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/add_contents_uc.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_fab.dart';
import 'package:slidesync/features/browse/ui/widgets/module/modules_list/modules_list_with_search_scroll_view.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/empty_library_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container_child.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

/// Mode for the bottom sheet
enum ContentSheetMode {
  move, // Moving existing contents between collections
  copy, // Copying existing contents to another collection
  store, // Storing new files to a collection
}

class RedirectContentsScreen extends ConsumerStatefulWidget {
  /// For moving existing contents
  final List<ModuleContent>? contentsToMove;

  /// For copying existing contents
  final List<ModuleContent>? contentsToCopy;

  /// For storing new files - Map of file path to UUID
  final List<String>? filePaths;
  Module? _selectedCourse;
    : contentsToMove = contents,
      contentsToCopy = null,
      filePaths = null,
      mode = ContentSheetMode.move;
  late final ValueNotifier<List<Course>?> coursesNotifier;
  late final ValueNotifier<List<Module>?> collectionsNotifier;
  late final ValueNotifier<String> searchQueryNotifier;
  bool isLoadingCourses = true;

    final coursePagination = MainProvider.library.link(ref).coursesPagination.link(ref);
    final isSelectingCourse = _selectedCourse == null;
  @override
      ContentSheetMode.move || ContentSheetMode.copy || ContentSheetMode.store =>
        isSelectingCourse ? 'Select a course' : 'Select a collection',
    collectionsNotifier = ValueNotifier(null);
    searchQueryNotifier = ValueNotifier('');
    _loadInitialCourses();
  }

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPressed(context);
      },
      onBackButtonPressed: () => _handleBackPressed(context),
    coursesNotifier.value = courses;
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          context.isDarkMode,
          title: title,
          onBackButtonClicked: isSelectingCourse ? () => _handleBackPressed(context) : () => _clearSelectedCourse(),
        ),
      ),
      floatingActionButton: isSelectingCourse || _selectedCourse == null
          ? null
          : CourseViewFAB(courseId: _selectedCourse!.uid),
      body: AnimatedSwitcher(
        duration: Durations.medium3,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        layoutBuilder: (currentChild, previousChildren) => Stack(
          fit: StackFit.expand,
          children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
        ),
        child: KeyedSubtree(
          key: ValueKey(_selectedCourse?.uid ?? 'courses'),
          child: isSelectingCourse
              ? _CourseSelectionView(
                  coursePagination: coursePagination,
                  onTapCourse: _selectCourse,
                )
              : _ModuleSelectionView(
                  course: _selectedCourse!,
                  mode: widget.mode,
                  onTapModule: _handleCollectionSelection,
                ),
        ),
      ),
    );
  }

  void _handleBackPressed(BuildContext context) {
    if (_selectedCourse == null) {
      Result.tryRun(() => context.pop(false));
      return;
    }
    _clearSelectedCourse();
  }

  void _clearSelectedCourse() {
    if (!mounted) return;
    setState(() => _selectedCourse = null);
  }

  void _selectCourse(Course course) {
    if (!mounted) return;
    setState(() => _selectedCourse = course);
  }

  Future<void> _handleCollectionSelection(BuildContext context, Module collection) async {
    if (widget.mode == ContentSheetMode.move) {
      await _handleMoveContents(context, collection);
    } else if (widget.mode == ContentSheetMode.copy) {
      await _handleCopyContents(context, collection);
    } else {
      await _handleStoreFiles(context, collection);
    }
  }

  /// Handle moving existing contents to a collection
  Future<void> _handleMoveContents(BuildContext context, Module collection) async {
    final contentsToMove = widget.contentsToMove;
    if (contentsToMove == null || contentsToMove.isEmpty) {
      log("No contents to move");
      UiUtils.showFlushBar(context, msg: "No contents to move", vibe: FlushbarVibe.warning);
      return;
    }

    UiUtils.showLoadingDialog(context, message: "Hold on for a moment while we move your materials", canPop: false);

    await ModuleContentRepo.moveContents(widget.contentsToMove!, collection.uid);
    GlobalNav.withContext((c) => c.pop());

    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.moduleContentsView.name, extra: collection));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Successfully moved contents"));
  }

  Future<void> _handleCopyContents(BuildContext context, Module collection) async {
    final contentsToCopy = widget.contentsToCopy;
    if (contentsToCopy == null || contentsToCopy.isEmpty) {
      log("No contents to copy");
      UiUtils.showFlushBar(context, msg: "No contents to copy", vibe: FlushbarVibe.warning);
      return;
    }

    UiUtils.showLoadingDialog(context, message: "Hold on for a moment while we copy your materials", canPop: false);

    final copied = await ModuleContentRepo.copyModuleContents(collection.uid, contentsToCopy);
    GlobalNav.withContext((c) => c.pop());

    if (!copied) {
      GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Unable to copy contents", vibe: FlushbarVibe.warning));
      return;
    }

    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.moduleContentsView.name, extra: collection));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Successfully copied contents"));
  }

  /// Handle storing new files to a collection
  Future<void> _handleStoreFiles(BuildContext context, Module collection) async {
    context.pop(true);
    GlobalNav.withContext(
      (c) => UiUtils.showLoadingDialog(c, message: "Hold on for a moment while we store your files", canPop: false),
    );

    await _storeContentsToCollection(collectionId: collection.uid, filePaths: widget.filePaths!);
    GlobalNav.popGlobal();

    GlobalNav.withContext((c) => c.pushNamed(Routes.moduleContentsView.name, extra: collection));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Successfully stored files"));
  }

  /// Your storage implementation
  Future<void> _storeContentsToCollection({required String collectionId, required List<String> filePaths}) async {
    final collection = await ModuleRepo.getByUid(collectionId);
    if (collection == null) return;

    await AddContentsUc.addToCollectionNoRef(collection: collection, filePaths: filePaths);
  }
}

class _CourseSelectionView extends ConsumerWidget {
  const _CourseSelectionView({required this.coursePagination, required this.onTapCourse});

  final dynamic coursePagination;
  final void Function(Course course) onTapCourse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmoothCustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: TopPadding(withHeight: kToolbarHeight + 4)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: PagingListener(
            controller: coursePagination.pagingController,
            builder: (context, state, fetchNextPage) {
              return PagedSliverList<int, Course>(
                state: state,
                itemExtent: 120,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate(
                  noItemsFoundIndicatorBuilder: (context) => EmptyLibraryView(asSliver: false),
                  firstPageProgressIndicatorBuilder: (context) => const SliverToBoxAdapter(child: LoadingLogo()),
                  newPageProgressIndicatorBuilder: (context) => const SliverToBoxAdapter(child: LoadingLogo()),
                  itemBuilder: (context, item, index) => CourseCard(
                    item,
                    CardViewType.list,
                    onTap: () => onTapCourse(item),
                  ),
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: BottomPadding()),
      ],
    );
  }
}

class _ModuleSelectionView extends StatelessWidget {
  const _ModuleSelectionView({required this.course, required this.mode, required this.onTapModule});

  final Course course;
  final ContentSheetMode mode;
  final Future<void> Function(BuildContext context, Module collection) onTapModule;

  @override
  Widget build(BuildContext context) {
    return ModulesListWithSearchScrollView(
      courseId: course.uid,
      topPadding: kToolbarHeight + 4,
      isPinned: true,
      showMoreOptionsButton: false,
      onTapModuleCard: (module) {
        onTapModule(context, module);
      },
    );
  }
}
}
            ),
          ),
          if (courseId != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CustomElevatedButton(
                pixelHeight: 48,
                pixelWidth: 48,
                backgroundColor: ref.secondary.withAlpha(50),
                shape: CircleBorder(side: BorderSide(color: ref.onBackground.withAlpha(10))),
                onClick: () {
                  if (context.mounted) {
                    CustomDialog.show(
                      context,
                      canPop: true,
                      barrierColor: Colors.black.withAlpha(150),
                      child: CreateCollectionBottomSheet(courseId: courseId!, title: "Create collection"),
                    );
                  }
                },
                child: Icon(Iconsax.add_circle, color: ref.secondary),
              ),
            ),
        ],
      ),
    );
  }
}
