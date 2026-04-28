import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/add_contents_uc.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_fab.dart';
import 'package:slidesync/features/browse/ui/widgets/module/modules_list/modules_list_with_search_scroll_view.dart';
import 'package:slidesync/features/main/providers/src/library_notifier/src/courses_pagination_notifier.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/empty_library_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

enum ContentSheetMode { move, copy, store }

class RedirectContentsScreen extends ConsumerStatefulWidget {
  final List<ModuleContent>? contentsToMove;
  final List<ModuleContent>? contentsToCopy;
  final List<String>? filePaths;
  final ContentSheetMode mode;

  const RedirectContentsScreen.move({super.key, required List<ModuleContent> contents})
    : contentsToMove = contents,
      contentsToCopy = null,
      filePaths = null,
      mode = ContentSheetMode.move;

  const RedirectContentsScreen.copy({super.key, required List<ModuleContent> contents})
    : contentsToCopy = contents,
      contentsToMove = null,
      filePaths = null,
      mode = ContentSheetMode.copy;

  const RedirectContentsScreen.store({super.key, required List<String> files})
    : filePaths = files,
      contentsToMove = null,
      contentsToCopy = null,
      mode = ContentSheetMode.store;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RedirectContentsScreenState();
}

class _RedirectContentsScreenState extends ConsumerState<RedirectContentsScreen> {
  Course? _selectedCourse;

  @override
  Widget build(BuildContext context) {
    final CoursesPaginationNotifier coursePagination = MainProvider.library.link(ref).coursesPagination.link(ref);
    final isCoursePhase = _selectedCourse == null;
    final title = isCoursePhase ? 'Select a course' : 'Select a collection';

    return AppScaffold(
      title: '',
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPressed(context);
      },
      onBackButtonPressed: () => _handleBackPressed(context),
      extendBodyBehindAppBar: true,
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          context.isDarkMode,
          title: title,
          onBackButtonClicked: () => _handleBackPressed(context),
        ),
      ),
      floatingActionButton: isCoursePhase ? null : CourseViewFAB(courseId: _selectedCourse!.uid),
      body: AnimatedSwitcher(
        duration: Durations.medium3,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        layoutBuilder: (currentChild, previousChildren) =>
            Stack(fit: StackFit.expand, children: <Widget>[...previousChildren, ?currentChild]),
        child: KeyedSubtree(
          key: ValueKey(_selectedCourse?.uid ?? 'courses'),
          child: isCoursePhase
              ? _CourseSelectionView(coursePagination: coursePagination, onTapCourse: _selectCourse)
              : _ModuleSelectionView(course: _selectedCourse!, onTapModule: _handleCollectionSelection),
        ),
      ),
    );
  }

  void _handleBackPressed(BuildContext context) {
    if (_selectedCourse == null) {
      Result.tryRun(() => context.pop(false));
      return;
    }

    setState(() {
      _selectedCourse = null;
    });
  }

  void _selectCourse(Course course) {
    if (!mounted) return;
    setState(() {
      _selectedCourse = course;
    });
  }

  Future<void> _handleCollectionSelection(BuildContext context, Module collection) async {
    switch (widget.mode) {
      case ContentSheetMode.move:
        await _handleMoveContents(context, collection);
        break;
      case ContentSheetMode.copy:
        await _handleCopyContents(context, collection);
        break;
      case ContentSheetMode.store:
        await _handleStoreFiles(context, collection);
        break;
    }
  }

  Future<void> _handleMoveContents(BuildContext context, Module collection) async {
    final contentsToMove = widget.contentsToMove;
    if (contentsToMove == null || contentsToMove.isEmpty) {
      UiUtils.showFlushBar(context, msg: 'No contents to move', vibe: FlushbarVibe.warning);
      return;
    }

    UiUtils.showLoadingDialog(context, message: 'Hold on for a moment while we move your materials', canPop: false);

    final moved = await ModuleContentRepo.moveContents(contentsToMove, collection.uid);
    GlobalNav.popGlobal();

    if (!moved) {
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(context, msg: 'Unable to move contents', vibe: FlushbarVibe.warning),
      );
      return;
    }

    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.moduleContentsView.name, extra: collection));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: 'Successfully moved contents'));
  }

  Future<void> _handleCopyContents(BuildContext context, Module collection) async {
    final contentsToCopy = widget.contentsToCopy;
    if (contentsToCopy == null || contentsToCopy.isEmpty) {
      UiUtils.showFlushBar(context, msg: 'No contents to copy', vibe: FlushbarVibe.warning);
      return;
    }

    UiUtils.showLoadingDialog(context, message: 'Hold on for a moment while we copy your materials', canPop: false);

    final copied = await ModuleContentRepo.copyModuleContents(collection.uid, contentsToCopy);
    GlobalNav.popGlobal();

    if (!copied) {
      GlobalNav.withContext(
        (context) => UiUtils.showFlushBar(context, msg: 'Unable to copy contents', vibe: FlushbarVibe.warning),
      );
      return;
    }

    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.moduleContentsView.name, extra: collection));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: 'Successfully copied contents'));
  }

  Future<void> _handleStoreFiles(BuildContext context, Module collection) async {
    final filePaths = widget.filePaths;
    if (filePaths == null || filePaths.isEmpty) {
      UiUtils.showFlushBar(context, msg: 'No files to store', vibe: FlushbarVibe.warning);
      return;
    }

    UiUtils.showLoadingDialog(context, message: 'Hold on for a moment while we store your files', canPop: false);
    await _storeContentsToCollection(collectionId: collection.uid, filePaths: filePaths);
    GlobalNav.popGlobal();

    GlobalNav.withContext((c) => c.pushNamed(Routes.moduleContentsView.name, extra: collection));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: 'Successfully stored files'));
  }

  Future<void> _storeContentsToCollection({required String collectionId, required List<String> filePaths}) async {
    final collection = await ModuleRepo.getByUid(collectionId);
    if (collection == null) return;
    await AddContentsUc.addToCollectionNoRef(collection: collection, filePaths: filePaths);
  }
}

class _CourseSelectionView extends ConsumerWidget {
  const _CourseSelectionView({required this.coursePagination, required this.onTapCourse});

  final CoursesPaginationNotifier coursePagination;
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
                  firstPageProgressIndicatorBuilder: (context) => const Center(child: LoadingLogo()),
                  newPageProgressIndicatorBuilder: (context) => const Center(child: LoadingLogo()),
                  itemBuilder: (context, item, index) =>
                      CourseCard(item, CardViewType.list, onTap: () => onTapCourse(item)),
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
  const _ModuleSelectionView({required this.course, required this.onTapModule});

  final Course course;
  final Future<void> Function(BuildContext context, Module collection) onTapModule;

  @override
  Widget build(BuildContext context) {
    return ModulesListWithSearchScrollView(
      courseId: course.uid,
      topPadding: kToolbarHeight + 4,
      isPinned: true,
      showMoreOptionsButton: false,
      onTapModuleCard: (module) => onTapModule(context, module),
    );
  }
}
