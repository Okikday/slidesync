import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/add_contents_uc.dart';
import 'package:slidesync/features/browse/ui/widgets/course/course_view/course_view_fab.dart';
import 'package:slidesync/features/browse/ui/widgets/module/modules_list/modules_list_with_search_scroll_view.dart';
import 'package:slidesync/features/main/providers/src/library_notifier/src/courses_pagination_notifier.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/create_course_f_a_b.dart';
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

enum RedirectMode { move, copy, store }

class RedirectContentsScreen extends ConsumerStatefulWidget {
  final List<ModuleContent>? contentsToMove;
  final List<ModuleContent>? contentsToCopy;
  final List<String>? filePaths;
  final List<String> linkUrls;
  final RedirectMode mode;

  const RedirectContentsScreen.move({super.key, required List<ModuleContent> contents})
    : contentsToMove = contents,
      contentsToCopy = null,
      filePaths = null,
      linkUrls = const [],
      mode = RedirectMode.move;

  const RedirectContentsScreen.copy({super.key, required List<ModuleContent> contents})
    : contentsToCopy = contents,
      contentsToMove = null,
      filePaths = null,
      linkUrls = const [],
      mode = RedirectMode.copy;

  const RedirectContentsScreen.store({super.key, required List<String> files, this.linkUrls = const []})
    : filePaths = files,
      contentsToMove = null,
      contentsToCopy = null,
      mode = RedirectMode.store;

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
          subtitle: _selectedCourse?.title,
          onBackButtonClicked: () => _handleBackPressed(context),
        ),
      ),
      floatingActionButton: isCoursePhase
          ? const CreateCourseFAB(pushToCreated: false)
          : CourseViewFAB(courseId: _selectedCourse!.uid),
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
              : _ModuleSelectionView(
                  course: _selectedCourse!,
                  onTapModule: (module) => _handleCollectionSelection(context, module: module),
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
    setState(() => _selectedCourse = null);
  }

  void _selectCourse(Course course) {
    if (!mounted) return;
    setState(() => _selectedCourse = course);
  }

  Future<void> _handleCollectionSelection(BuildContext context, {required Module module}) async {
    context.pop();

    final mode = widget.mode;
    final redirList = switch (mode) {
      RedirectMode.copy => widget.contentsToCopy,
      RedirectMode.move => widget.contentsToMove,
      RedirectMode.store => widget.filePaths,
    };

    final hasFiles = redirList != null && redirList.isNotEmpty;
    final hasLinks = widget.linkUrls.isNotEmpty;

    if (!hasFiles && !hasLinks) {
      final msg = switch (mode) {
        RedirectMode.copy => 'No contents was selected for copy',
        RedirectMode.move => 'No contents was selected for move',
        RedirectMode.store => 'No files was received!',
      };
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: msg, vibe: FlushbarVibe.warning));
      return;
    }

    await 200.inMs.delay();

    GlobalNav.withContext(
      (context) => UiUtils.showLoadingDialog(context, message: "Processing your materials", canPop: false),
    );

    final String? errorMsg = await switch (widget.mode) {
      RedirectMode.move => _handleMoveContents(module, redirList as List<ModuleContent>),
      RedirectMode.copy => _handleCopyContents(module, redirList as List<ModuleContent>),
      RedirectMode.store => _handleStoreFiles(module, redirList as List<String>? ?? []),
    };

    GlobalNav.popGlobal();
    await 200.inMs.delay();

    if (errorMsg != null) {
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: errorMsg, vibe: FlushbarVibe.error));
      return;
    }

    final pushTo = Routes.moduleContentsView.name;
    GlobalNav.withContext((context) => context.pushNamed(pushTo, extra: module));

    await 200.inMs.delay();

    GlobalNav.withContext(
      (context) => UiUtils.showFlushBar(
        context,
        msg: switch (mode) {
          RedirectMode.move => 'Successfully moved contents!',
          RedirectMode.copy => 'Successfully copied contents!',
          RedirectMode.store => 'Successfully stored files!',
        },
        vibe: FlushbarVibe.success,
      ),
    );
  }

  Future<String?> _handleMoveContents(Module collection, List<ModuleContent> redirList) async {
    try {
      final moved = await ModuleContentRepo.moveContents(redirList, collection.uid);
      if (!moved) return "Failed to move contents to another module";
      return null;
    } catch (e, st) {
      log('move contents failed: $e\n$st');
      return "An error occurred while moving contents to another module";
    }
  }

  Future<String?> _handleCopyContents(Module collection, List<ModuleContent> redirList) async {
    try {
      final copied = await ModuleContentRepo.copyModuleContents(collection.uid, redirList);
      if (!copied) return "Failed to copy contents to another module";
      return null;
    } catch (e, st) {
      log('copy contents failed: $e\n$st');
      return "An error occured while copying contents to another module";
    }
  }

  /// Handles storing files and/or links into [collection].
  /// Files are processed first (heavier), then links are batch-inserted.
  Future<String?> _handleStoreFiles(Module collection, List<String> filePaths) async {
    try {
      // Files first
      if (filePaths.isNotEmpty) {
        await AddContentsUc.addToCollectionNoRef(collection: collection, filePaths: filePaths);
      }

      // Links — single batch write
      if (widget.linkUrls.isNotEmpty) {
        await _addMultipleLinks(collection, widget.linkUrls);
      }

      return null;
    } catch (e, st) {
      log('store contents failed: $e\n$st');
      return "An error occured while storing files";
    }
  }
}

/// Builds [ModuleContent] records for each URL and writes them in one batch.
/// Deduplicates within the incoming list by hash before writing.
/// Skips URLs that already exist in the collection.
Future<void> _addMultipleLinks(Module collection, List<String> urls) async {
  final contents = <ModuleContent>[];
  final seenHashes = <String>{};

  for (final url in urls) {
    final hash = CryptoUtils.calculateStringHash(url);
    if (seenHashes.contains(hash)) continue;
    seenHashes.add(hash);

    // Skip if this exact link already lives in this collection
    final duplicate = await ModuleContentRepo.findFirstDuplicateContentByHash(collection, hash);
    if (duplicate != null && duplicate.path.url == url) continue;

    contents.add(
      ModuleContent.create(
        xxh3Hash: hash,
        parentId: collection.uid,
        title: url,
        type: ModuleContentType.link,
        path: FilePath(url: url),
        metadata: ModuleContentMetadata.create(contentOrigin: ContentOrigin.server),
      ),
    );
  }

  if (contents.isEmpty) return;
  await ModuleContentRepo.addMultipleContents(collection.uid, contents);
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
  final Future<void> Function(Module module) onTapModule;

  @override
  Widget build(BuildContext context) {
    return ModulesListWithSearchScrollView(
      courseId: course.uid,
      topPadding: kToolbarHeight + 4,
      isPinned: true,
      showMoreOptionsButton: false,
      onTapModuleCard: onTapModule,
    );
  }
}
