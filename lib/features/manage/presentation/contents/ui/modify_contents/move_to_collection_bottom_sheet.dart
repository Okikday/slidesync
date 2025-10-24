import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_categories_card.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course/empty_courses_view.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/select_to_modify_course/edit_course_tile.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

class MoveToCollectionBottomSheet extends ConsumerStatefulWidget {
  final List<CourseContent> contents;
  const MoveToCollectionBottomSheet({super.key, required this.contents});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MoveToCollectionBottomSheetState();
}

class _MoveToCollectionBottomSheetState extends ConsumerState<MoveToCollectionBottomSheet> {
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

                              onTap: () async {
                                context.pop();
                                UiUtils.showLoadingDialog(
                                  context,
                                  message: "Hold on for a moment while we move your materials",
                                  canPop: false,
                                );
                                await CourseContentRepo.moveContents(widget.contents, collection.collectionId);
                                GlobalNav.withContext((c) => c.pop());

                                GlobalNav.withContext(
                                  (c) => c.pushReplacementNamed(
                                    Routes.modifyContents.name,
                                    extra: collection.collectionId,
                                  ),
                                );
                                GlobalNav.withContext(
                                  (c) => UiUtils.showFlushBar(c, msg: "Successfully moved contents"),
                                );
                              },
                            ),
                            // child: EditCourseTile(
                            //   courseName: collection.collectionTitle,
                            //   courseCode: '',
                            //   categoriesCount: collection.contents.length,
                            //   selectionState: (selected: false, isSelecting: false),
                            //   syncImagePath: collection.imageLocationJson,
                            //   onTap: () async {

                            //   },
                            //   onSelected: () {},
                            // ),
                          );
                        },
                      );
                    }
                    return const SliverToBoxAdapter();
                  },
                ),

                if (streamedCourses != null)
                  StreamBuilder(
                    stream: streamedCourses,
                    builder: (context, rawData) {
                      if (!rawData.hasData || rawData.data == null) const SliverToBoxAdapter(child: LoadingLogo());
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
                              onTap: () async {
                                final holdStreamedCourses = streamedCourses;
                                streamedCourses = null;
                                setState(() {
                                  streamedCourses;
                                });

                                await course.collections.load();
                                if (course.collections.isEmpty) {
                                  if (context.mounted) {
                                    UiUtils.showFlushBar(context, msg: "No collection to add to...");
                                  }
                                  streamedCourses = holdStreamedCourses;
                                  setState(() {
                                    streamedCourses;
                                  });
                                } else {
                                  collectionsNotifier.value = List.from(course.collections.toList());
                                }
                              },
                              onSelected: () {},
                            ),
                          );
                        },
                      );
                    },
                  ),

                SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MoveToCollectionSearchBar extends ConsumerWidget {
  const MoveToCollectionSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: SearchBar(
          hintText: "Search a course",
          leading: Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: Icon(Iconsax.search_normal_1_copy),
          ),
          backgroundColor: WidgetStatePropertyAll(theme.surface),
          elevation: WidgetStatePropertyAll(10),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
    );
  }
}
