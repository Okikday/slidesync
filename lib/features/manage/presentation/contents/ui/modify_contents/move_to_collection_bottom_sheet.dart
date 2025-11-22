import 'dart:async';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_categories_card.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/add_contents_uc.dart';
import 'package:slidesync/features/manage/presentation/collections/ui/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/manage/presentation/contents/logic/modify_content_provider.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course/empty_courses_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course/edit_course_tile.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

/// Mode for the bottom sheet
enum ContentSheetMode {
  move, // Moving existing contents between collections
  store, // Storing new files to a collection
}

class MoveOrStoreContentBottomSheet extends ConsumerStatefulWidget {
  /// For moving existing contents
  final List<CourseContent>? contentsToMove;

  /// For storing new files - Map of file path to UUID
  final List<String>? filePaths;

  /// Determines the mode
  final ContentSheetMode mode;

  const MoveOrStoreContentBottomSheet.move({super.key, required List<CourseContent> contents})
    : contentsToMove = contents,
      filePaths = null,
      mode = ContentSheetMode.move;

  const MoveOrStoreContentBottomSheet.store({super.key, required List<String> files})
    : filePaths = files,
      contentsToMove = null,
      mode = ContentSheetMode.store;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MoveOrStoreContentBottomSheetState();
}

class _MoveOrStoreContentBottomSheetState extends ConsumerState<MoveOrStoreContentBottomSheet> {
  Timer? _searchDebounceTimer;
  late final ValueNotifier<List<Course>?> coursesNotifier;
  late final ValueNotifier<List<CourseCollection>?> collectionsNotifier;
  late final ValueNotifier<String> searchQueryNotifier;
  bool isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    coursesNotifier = ValueNotifier(null);
    collectionsNotifier = ValueNotifier(null);
    searchQueryNotifier = ValueNotifier('');
    _loadInitialCourses();
  }

  Future<void> _loadInitialCourses() async {
    final courses = await CourseRepo.getAllCourses();
    coursesNotifier.value = courses;
    isLoadingCourses = false;
  }

  @override
  void dispose() {
    coursesNotifier.dispose();
    collectionsNotifier.dispose();
    searchQueryNotifier.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.pop(false);
      },
      child: Scaffold(
        appBar: AppBarContainer(child: AppBarContainerChild(context.isDarkMode, title: "Save file")),
        body: AnimatedPadding(
          duration: Durations.medium1,
          padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
          child: CustomScrollView(
            slivers: [
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: theme.background,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12),
                    child: ValueListenableBuilder(
                      valueListenable: collectionsNotifier,
                      builder: (context, collections, child) {
                        return CustomText(
                          collections == null ? "Select a course.." : "Select a collection",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ref.theme.onBackground,
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ColoredBox(color: theme.background, child: ConstantSizing.columnSpacingMedium),
              ),
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: theme.background,
                  child: ValueListenableBuilder(
                    valueListenable: collectionsNotifier,
                    builder: (context, collections, child) {
                      return MoveToCollectionSearchBar(
                        onBackButtonPressed: collections == null
                            ? null
                            : () async {
                                collectionsNotifier.value = null;

                                final courses = await CourseRepo.getAllCourses();
                                coursesNotifier.value = courses;
                              },
                        courseId: collections?.first.parentId,
                        onSearchChanged: (query) {
                          // Cancel previous timer
                          _searchDebounceTimer?.cancel();

                          // Start new timer
                          _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
                            // Update courses based on search
                            if (collectionsNotifier.value == null) {
                              // Searching courses - use findAll()
                              if (query.isEmpty) {
                                final courses = await CourseRepo.getAllCourses();
                                coursesNotifier.value = courses;
                              } else {
                                final filter = await CourseRepo.filter;
                                final courses = await filter.courseTitleContains(query, caseSensitive: false).findAll();
                                coursesNotifier.value = courses;
                              }
                            } else {
                              // Searching collections
                              searchQueryNotifier.value = query;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

              // Collections list (when a course is selected)
              ValueListenableBuilder(
                valueListenable: collectionsNotifier,
                builder: (context, collections, child) {
                  if (collections != null && collections.isNotEmpty) {
                    return ValueListenableBuilder(
                      valueListenable: searchQueryNotifier,
                      builder: (context, searchQuery, child) {
                        final filteredCollections = searchQuery.isEmpty
                            ? collections
                            : collections
                                  .where((c) => c.collectionTitle.toLowerCase().contains(searchQuery.toLowerCase()))
                                  .toList();
                        return SliverList.builder(
                          itemCount: filteredCollections.length,
                          itemBuilder: (context, index) {
                            final collection = filteredCollections[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                              child:
                                  CourseCategoriesCard(
                                        isDarkMode: ref.isDarkMode,
                                        title: collection.collectionTitle,
                                        contentCount: collection.contents.length,
                                        onTap: () => _handleCollectionSelection(context, collection),
                                      )
                                      .animate()
                                      .slideY(
                                        begin: 0.1 * ((index + 1) / filteredCollections.length),
                                        end: 0,
                                        duration: Durations.extralong1,
                                        curve: CustomCurves.defaultIosSpring,
                                      )
                                      .fadeIn(),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SliverToBoxAdapter();
                },
              ),

              ValueListenableBuilder(
                valueListenable: collectionsNotifier,
                builder: (context, collections, child) {
                  if (collections == null) {
                    return ValueListenableBuilder(
                      valueListenable: coursesNotifier,
                      builder: (context, courses, child) {
                        if (courses == null) {
                          return const SliverToBoxAdapter(child: LoadingLogo());
                        }

                        if (courses.isEmpty) {
                          return EmptyCoursesView();
                        }

                        return SliverList.builder(
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                              child:
                                  EditCourseTile(
                                        courseName: course.courseName,
                                        courseCode: course.courseCode,
                                        categoriesCount: course.collections.length,
                                        selectionState: (selected: false, isSelecting: false),
                                        syncImagePath: course.imageLocationJson,
                                        onTap: () => _handleCourseSelection(context, course),
                                        onSelected: () {},
                                      )
                                      .animate()
                                      .slideY(
                                        begin: 0.1 * ((index + 1) / courses.length),
                                        end: 0,
                                        duration: Durations.extralong1,
                                        curve: CustomCurves.defaultIosSpring,
                                      )
                                      .fadeIn(),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SliverToBoxAdapter();
                },
              ),

              const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCourseSelection(BuildContext context, Course course) async {
    final holdCourses = coursesNotifier.value;
    coursesNotifier.value = null;

    await course.collections.load();
    if (course.collections.isEmpty) {
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: "No collection to add to...");
      }
      coursesNotifier.value = holdCourses;
    } else {
      collectionsNotifier.value = List.from(course.collections.toList());
    }
  }

  Future<void> _handleCollectionSelection(BuildContext context, CourseCollection collection) async {
    if (widget.mode == ContentSheetMode.move) {
      await _handleMoveContents(context, collection);
    } else {
      await _handleStoreFiles(context, collection);
    }
  }

  /// Handle moving existing contents to a collection
  Future<void> _handleMoveContents(BuildContext context, CourseCollection collection) async {
    context.pop(true);
    ref.read(ModifyContentsProvider.state).clearContents();
    if (widget.contentsToMove!.isNotEmpty && collection.collectionId == widget.contentsToMove!.first.parentId) {
      return;
    }

    UiUtils.showLoadingDialog(context, message: "Hold on for a moment while we move your materials", canPop: false);

    await CourseContentRepo.moveContents(widget.contentsToMove!, collection.collectionId);
    GlobalNav.withContext((c) => c.pop());

    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.modifyContents.name, extra: collection.collectionId));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Successfully moved contents"));
  }

  /// Handle storing new files to a collection
  Future<void> _handleStoreFiles(BuildContext context, CourseCollection collection) async {
    context.pop(true);
    UiUtils.showLoadingDialog(context, message: "Storing your files...", canPop: false);

    await _storeContentsToCollection(collectionId: collection.collectionId, filePaths: widget.filePaths!);

    // GlobalNav.withContext((c) => c.pop());
    GlobalNav.withContext((c) => c.pushNamed(Routes.modifyContents.name, extra: collection.collectionId));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Successfully stored files"));
  }

  /// Your storage implementation
  Future<void> _storeContentsToCollection({required String collectionId, required List<String> filePaths}) async {
    final collection = await CourseCollectionRepo.getById(collectionId);
    if (collection == null) return;

    await AddContentsUc.addToCollectionNoRef(collection: collection, filePaths: filePaths);
  }
}

class MoveToCollectionSearchBar extends ConsumerWidget {
  final void Function(String) onSearchChanged;
  final void Function()? onBackButtonPressed;
  final String? courseId;
  const MoveToCollectionSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onBackButtonPressed,
    this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return SliverPadding(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: 12, left: onBackButtonPressed == null ? 12 : 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            if (onBackButtonPressed != null) BackButton(onPressed: onBackButtonPressed),
            Expanded(
              child: SearchBar(
                hintText: "Search a course",
                onChanged: onSearchChanged,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 4),
                  child: Icon(Iconsax.search_normal_1_copy),
                ),
                backgroundColor: WidgetStatePropertyAll(theme.surface),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
      ),
    );
  }
}
