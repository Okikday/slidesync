import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/features/browse/presentation/views/course_materials/course_material_list_card.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class MaterialsSearchButton extends ConsumerWidget {
  final Color? backgroundColor;
  final String collectionId;
  const MaterialsSearchButton({super.key, this.backgroundColor, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return SearchAnchor(
      viewBackgroundColor: theme.background,
      dividerColor: theme.supportingText.withAlpha(40),

      builder: (context, controller) => BuildButton(
        onTap: () {
          controller.openView();
        },
        iconData: Iconsax.search_normal_copy,
        backgroundColor: backgroundColor,
      ),
      suggestionsBuilder: (context, controller) async {
        if (controller.text.isEmpty) {
          return [
            Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight, left: 16, right: 16),
              child: SizedBox(
                child: Center(
                  child: CustomText("Input a title to search...", color: theme.backgroundSupportingText.withAlpha(150)),
                ),
              ),
            ),
          ];
        }
        final List<CourseContent> searchResults = await (await CourseContentRepo.filter)
            .parentIdEqualTo(collectionId)
            .titleContains(controller.text, caseSensitive: false)
            .findAll();
        return [
          ConstantSizing.columnSpacing(8),
          for (int i = 0; i < searchResults.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CourseMaterialListCard(
                content: searchResults[i],
                onTapCard: () {
                  context.pop();
                  context.pushNamed(Routes.contentGate.name, extra: searchResults[i]);
                },
              ),
            ),

          if (context.mounted) ConstantSizing.columnSpacing(context.viewInsets.bottom),
        ];
      },
    );
  }
}
