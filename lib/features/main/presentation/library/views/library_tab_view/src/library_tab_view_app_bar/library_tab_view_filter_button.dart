import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/features/main/presentation/library/controllers/courses_view_controller.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_app_theme.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';

import 'package:slidesync/shared/helpers/extensions/src/extension_on_course_sort.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';

class LibraryTabViewFilterButton extends ConsumerWidget {
  const LibraryTabViewFilterButton({super.key});

  ({String title, bool asc}) parseCourseSortOption(CourseSortOption o) {
    final n = o.name;
    final asc = n.endsWith('Asc');
    final core = asc
        ? n.substring(0, n.length - 3)
        : n.endsWith('Desc')
        ? n.substring(0, n.length - 4)
        : n;
    final t = core.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}');
    final title = (t.isEmpty ? n : t)[0].toUpperCase() + (t.isEmpty ? n : t).substring(1);
    return (title: title, asc: asc);
  }

  List<PlainCourseSortOption> plainListFromCourseSortOptions() {
    final seen = <PlainCourseSortOption>{};
    final out = <PlainCourseSortOption>[];
    for (final o in CourseSortOption.values) {
      final p = o.toPlain();
      if (seen.add(p)) out.add(p);
    }
    return out;
  }

  // Find a CourseSortOption for a plain option with the requested direction.
  CourseSortOption _fromPlain(PlainCourseSortOption p, bool asc) {
    for (final o in CourseSortOption.values) {
      if (o.toPlain() == p) {
        final n = o.name;
        if (asc && n.endsWith('Asc')) return o;
        if (!asc && n.endsWith('Desc')) return o;
      }
    }
    return CourseSortOption.dateModifiedDesc;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    final asyncCurrSortOption = ref.watch(CoursesViewController.coursesFilterOption);
    return asyncCurrSortOption.when(
      data: (CourseSortOption currSortOption) {
        final currSortData = parseCourseSortOption(currSortOption);
        final currPlain = currSortOption.toPlain();
        final plainList = plainListFromCourseSortOptions();
        final isSortOptionNone = currSortOption == CourseSortOption.dateModifiedDesc;

        return AppPopupMenuButton(
          icon: isSortOptionNone ? Iconsax.filter : Iconsax.filter_copy,
          iconColor: theme.onPrimary,
          buttonStyle: ButtonStyle(backgroundColor: WidgetStatePropertyAll(theme.primary)),
          actions: [
            for (final item in plainList)
              PopupMenuAction(
                title: parseCourseSortOption(_fromPlain(item, true)).title,
                iconData: Icons.circle_outlined,
                icon: item == currPlain
                    ? Icon(
                        item == PlainCourseSortOption.dateModified
                            ? Icons.check
                            : currSortData.asc
                            ? Iconsax.arrow_circle_up
                            : Iconsax.arrow_circle_down,
                        color: theme.primary,
                      )
                    : null,
                onTap: () async {
                  final newOpt = item == currPlain ? _fromPlain(item, !currSortData.asc) : _fromPlain(item, true);
                  ref.read(CoursesViewController.coursesFilterOption.notifier).set(newOpt);
                  (await ref.read(
                    CoursesViewController.coursesPaginationFutureProvider.future,
                  )).updateSortOption(newOpt, true);
                },
              ),
          ],
        );
      },
      error: (e, st) => Icon(Icons.error_rounded),
      loading: () => CircularLoadingIndicator(),
    );
  }
}
