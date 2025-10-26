import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_categories_card.dart';
import 'package:slidesync/features/browse/presentation/ui/course_materials/course_material_list_card.dart';
import 'package:slidesync/features/main/presentation/library/actions/course_card_actions.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/courses_view/course_card.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

final _searchTypeProvider = NotifierProvider.autoDispose(IntNotifier.new);
const strCategories = ['Courses', 'Collections', 'Materials'];

class LibraryTabViewSearchButton extends ConsumerWidget {
  final Color? backgroundColor;
  const LibraryTabViewSearchButton({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final isDarkMode = ref.isDarkMode;
    final bottomPadding = context.bottomPadding;
    final bottomInsets = context.viewInsets.bottom;

    return SearchAnchor(
      viewBackgroundColor: theme.background,
      dividerColor: theme.supportingText.withAlpha(40),
      viewTrailing: [
        Consumer(
          builder: (context, ref, child) {
            final selectedIndex = ref.watch(_searchTypeProvider);
            return AppPopupMenuButton(
              actions: List.generate(strCategories.length, (index) {
                return PopupMenuAction(
                  title: strCategories[index],
                  iconData: selectedIndex == index ? Icons.check_rounded : Icons.check_box_outline_blank,
                  onTap: () {
                    ref.read(_searchTypeProvider.notifier).set(index);
                  },
                );
              }),
            );
          },
        ),
      ],
      builder: (context, controller) => BuildButton(
        onTap: () {
          controller.openView();
        },
        iconData: Iconsax.search_normal_copy,
        backgroundColor: backgroundColor,
        shape: CircleBorder(side: BorderSide(color: theme.onBackground.withAlpha(10))),
      ),
      suggestionsBuilder: (context, controller) async {
        if (controller.text.isEmpty) {
          return [
            Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight, left: 16, right: 16),
              child: SizedBox(
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final selectedIndex = ref.watch(_searchTypeProvider);
                      return CustomText(
                        "Input a title to search in ${strCategories[selectedIndex]}",
                        color: theme.backgroundSupportingText.withAlpha(150),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        }
        final List searchResults;
        searchResults = switch (ref.watch(_searchTypeProvider)) {
          0 => await (await CourseRepo.filter).courseTitleContains(controller.text, caseSensitive: false).findAll(),
          1 =>
            await (await CourseCollectionRepo.filter)
                .collectionTitleContains(controller.text, caseSensitive: false)
                .findAll(),
          2 => await (await CourseContentRepo.filter).titleContains(controller.text, caseSensitive: false).findAll(),
          _ => [],
        };

        return [
          ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            padding: EdgeInsets.only(top: 12, bottom: bottomPadding + bottomInsets + 12),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final value = searchResults[i];
                    return switch (ref.watch((_searchTypeProvider))) {
                      0 => CourseCard(
                        value as Course,
                        false,
                        onTap: (course) {
                          controller.closeView("");
                          CourseCardActions.of(ref).onTapCourseCard(course);
                        },
                      ),
                      1 => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CourseCategoriesCard(
                          isDarkMode: isDarkMode,
                          title: (value as CourseCollection).collectionTitle,
                          contentCount: (value).contents.length,
                          onTap: () async {
                            controller.closeView("");
                            final curr = value;
                            final parent = await CourseRepo.getCourseById(curr.parentId);
                            if (parent == null) return;
                            CourseCardActions.of(ref).onTapCourseCard(parent);
                          },
                        ),
                      ),
                      2 => CourseMaterialListCard(content: value as CourseContent),
                      _ => const SizedBox(),
                    };
                  },
                ),
              );
            },
          ),
        ];
      },
    );
  }
}
