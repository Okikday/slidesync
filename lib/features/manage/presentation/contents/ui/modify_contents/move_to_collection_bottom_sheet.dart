import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_categories_card.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/add_contents_uc.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course/empty_courses_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course/edit_course_tile.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
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
  Stream<List<Course>>? streamedCourses;
  late final ValueNotifier<List<CourseCollection>?> collectionsNotifier;

  @override
  void initState() {
    super.initState();
    streamedCourses = CourseRepo.watchAllCourses();
    collectionsNotifier = ValueNotifier(null);
  }

  @override
  void dispose() {
    collectionsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    return AnimatedPadding(
      duration: Durations.medium1,
      padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.75,
        builder: (context, scrollController) {
          return ColoredBox(
            color: theme.background,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                PinnedHeaderSliver(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
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
                const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
                const MoveToCollectionSearchBar(),

                // Collections list (when a course is selected)
                ValueListenableBuilder(
                  valueListenable: collectionsNotifier,
                  builder: (context, collections, child) {
                    if (collections != null && collections.isNotEmpty) {
                      return SliverList.builder(
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: CourseCategoriesCard(
                              isDarkMode: ref.isDarkMode,
                              title: collection.collectionTitle,
                              contentCount: collection.contents.length,
                              onTap: () => _handleCollectionSelection(context, collection),
                            ),
                          );
                        },
                      );
                    }
                    return const SliverToBoxAdapter();
                  },
                ),

                // Courses list (initial view)
                if (streamedCourses != null)
                  StreamBuilder(
                    stream: streamedCourses,
                    builder: (context, rawData) {
                      if (!rawData.hasData || rawData.data == null) {
                        return const SliverToBoxAdapter(child: LoadingLogo());
                      }
                      final data = rawData.data ?? [];
                      if (data.isEmpty) {
                        return EmptyCoursesView();
                      }

                      return SliverList.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final course = data[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: EditCourseTile(
                              courseName: course.courseName,
                              courseCode: course.courseCode,
                              categoriesCount: course.collections.length,
                              selectionState: (selected: false, isSelecting: false),
                              syncImagePath: course.imageLocationJson,
                              onTap: () => _handleCourseSelection(context, course),
                              onSelected: () {},
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCourseSelection(BuildContext context, Course course) async {
    final holdStreamedCourses = streamedCourses;
    streamedCourses = null;
    setState(() {});

    await course.collections.load();
    if (course.collections.isEmpty) {
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: "No collection to add to...");
      }
      streamedCourses = holdStreamedCourses;
      setState(() {});
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
    context.pop();
    UiUtils.showLoadingDialog(context, message: "Hold on for a moment while we move your materials", canPop: false);

    await CourseContentRepo.moveContents(widget.contentsToMove!, collection.collectionId);
    GlobalNav.withContext((c) => c.pop());

    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.modifyContents.name, extra: collection.collectionId));
    GlobalNav.withContext((c) => UiUtils.showFlushBar(c, msg: "Successfully moved contents"));
  }

  /// Handle storing new files to a collection
  Future<void> _handleStoreFiles(BuildContext context, CourseCollection collection) async {
    context.pop();
    UiUtils.showLoadingDialog(context, message: "Storing your files...", canPop: false);

    await _storeContentsToCollection(collectionId: collection.collectionId, filePaths: widget.filePaths!);

    GlobalNav.withContext((c) => c.pop());
    GlobalNav.withContext((c) => c.pushReplacementNamed(Routes.modifyContents.name, extra: collection.collectionId));
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
  const MoveToCollectionSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: SearchBar(
          hintText: "Search a course",
          leading: const Padding(
            padding: EdgeInsets.only(left: 8, right: 4),
            child: Icon(Iconsax.search_normal_1_copy),
          ),
          backgroundColor: WidgetStatePropertyAll(theme.surface),
          elevation: const WidgetStatePropertyAll(10),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
    );
  }
}
