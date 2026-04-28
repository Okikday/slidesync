import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';

class LibraryTabViewFilterButton extends ConsumerWidget {
  const LibraryTabViewFilterButton({super.key});

  ({String title, bool asc}) parseCourseSortOption(CoursesOrdering o) {
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
    for (final o in CoursesOrdering.values) {
      final p = o.toPlain();
      if (seen.add(p)) out.add(p);
    }
    return out;
  }

  // Find a CourseSortOption for a plain option with the requested direction.
  CoursesOrdering _fromPlain(PlainCourseSortOption p, bool asc) {
    for (final o in CoursesOrdering.values) {
      if (o.toPlain() == p) {
        final n = o.name;
        if (asc && n.endsWith('Asc')) return o;
        if (!asc && n.endsWith('Desc')) return o;
      }
    }
    return CoursesOrdering.dateModifiedDesc;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    final currSortOption = MainProvider.library.link(ref).coursesPagination.select((s) => s.coursesOrdering).watch(ref);
    final currSortData = parseCourseSortOption(currSortOption);
    final currPlain = currSortOption.toPlain();
    final plainList = plainListFromCourseSortOptions();
    final isSortOptionNone = currSortOption == CoursesOrdering.dateModifiedDesc;

    return AppPopupMenuButton(
      icon: isSortOptionNone ? HugeIconsSolid.filter : HugeIconsStroke.filter,
      iconColor: theme.onPrimary,
      iconSize: 20,
      buttonStyle: ButtonStyle(backgroundColor: WidgetStatePropertyAll(theme.primary)),
      actions: [
        for (final item in plainList)
          PopupMenuAction(
            title: parseCourseSortOption(_fromPlain(item, true)).title,
            iconData: Icons.circle_outlined,
            icon: item == currPlain
                ? Icon(
                    item == PlainCourseSortOption.dateModified
                        ? HugeIconsSolid.checkmarkCircle01
                        : currSortData.asc
                        ? HugeIconsSolid.circleArrowUp02
                        : HugeIconsSolid.circleArrowDown02,
                    color: theme.primary,
                  )
                : null,
            onTap: () async {
              final newOpt = item == currPlain ? _fromPlain(item, !currSortData.asc) : _fromPlain(item, true);
              MainProvider.library.act(ref).coursesPagination.act(ref).updateCoursesOrdering(newOpt, refresh: true);
            },
          ),
      ],
    );
  }
}
