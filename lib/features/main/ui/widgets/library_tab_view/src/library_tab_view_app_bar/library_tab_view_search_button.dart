import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/ui/widgets/module/module_card.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/material_list_card.dart';
import 'package:slidesync/features/main/ui/actions/library/courses_view_actions.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/courses_view/course_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/routes/routes.dart';

final _searchTypeProvider = NotifierProvider.autoDispose(IntNotifier.new);
const strCategories = ['Courses', 'Collections', 'Materials'];

class LibraryTabViewSearchButton extends ConsumerWidget with CoursesViewActions {
  final Color? backgroundColor;
  const LibraryTabViewSearchButton({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    // final isDarkMode = ref.isDarkMode;
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
        final searchType = ref.watch(_searchTypeProvider);

        if (controller.text.isEmpty) {
          return [
            Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight, left: 16, right: 16),
              child: SizedBox(
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) {
                      return CustomText(
                        "Input a title to search in ${strCategories.elementAt(searchType.clamp(0, strCategories.length - 1))}",
                        color: theme.backgroundSupportingText.withAlpha(150),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        }
        final List searchResults = switch (searchType) {
          0 => await (CourseRepo.filter).titleContains(controller.text, caseSensitive: false).findAll(),
          1 => await (ModuleRepo.filter).titleContains(controller.text, caseSensitive: false).findAll(),
          2 => await (ModuleContentRepo.filter).titleContains(controller.text, caseSensitive: false).findAll(),
          _ => [],
        };

        return [
          SmoothListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            padding: EdgeInsets.only(top: 12, bottom: bottomPadding + bottomInsets + kToolbarHeight + 12),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final value = searchResults[i];
                    return switch (searchType) {
                      0 => CourseCard(
                        value as Course,
                        CardViewType.list,
                        onTap: () {
                          // controller.closeView("");
                          onTapCourseCard(ref, course: value);
                        },
                      ),
                      1 => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ModuleCard(
                          module: value as Module,
                          subtitleText: "${value.contents.length} items",
                          onTap: () {
                            context.pop();
                            context.pushNamed(Routes.moduleContentsView.name, extra: value);
                          },
                        ),
                      ),
                      2 => MaterialListCard(content: value as ModuleContent, showGoToCollection: true),
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
