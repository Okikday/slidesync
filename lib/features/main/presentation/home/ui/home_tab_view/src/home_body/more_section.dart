import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/library_search_view/library_search_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

class MoreSection extends ConsumerWidget {
  const MoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = ref;
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 12),
        children: [
          MoreSectionOption(
            title: "Search",
            iconData: Iconsax.search_normal_copy,
            onTap: () async {
              Navigator.push(
                context,
                PageAnimation.pageRouteBuilder(const LibrarySearchView(), type: TransitionType.topLevel),
              );
              // final collection = await CourseCollectionRepo.getById(AppCourseCollections.bookmarks.name);
              // if (collection == null) {
              //   GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "No bookmarks..."));
              //   return;
              // }
              // GlobalNav.withContext((context) => context.pushNamed(Routes.courseMaterials.name, extra: collection));
            },
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16.0),
          //   child: MoreSectionOption(
          //     title: "Quiz",
          //     iconData: Iconsax.menu_copy,
          //     onTap: () {
          //       Navigator.push(context, PageAnimation.pageRouteBuilder(const QuizListing()));
          //     },
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16.0),
          //   child: MoreSectionOption(title: "References", iconData: Iconsax.bookmark, onTap: () {}),
          // ),
        ],
      ),
    );
  }
}

class MoreSectionOption extends ConsumerWidget {
  final String title;
  final IconData iconData;
  final void Function()? onTap;
  const MoreSectionOption({super.key, required this.title, required this.iconData, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ScaleClickWrapper(
      borderRadius: 36,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(36),
          border: Border.fromBorderSide(BorderSide(color: theme.backgroundSupportingText.withAlpha(10))),
          image: DecorationImage(
            image: Assets.images.zigzagWavy.asImageProvider,
            fit: BoxFit.cover,
            opacity: 0.01,
            colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 8.0,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.background,
                child: Icon(iconData, color: theme.supportingText),
              ),
              CustomText(title, color: theme.supportingText, fontSize: 13, fontWeight: FontWeight.bold),
            ],
          ),
        ),
      ),
    );
  }
}
