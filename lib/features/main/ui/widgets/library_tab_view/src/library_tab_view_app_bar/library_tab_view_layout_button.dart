import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/main/providers/discarded/library/library_tab_provider.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class LibraryTabViewLayoutButton extends ConsumerWidget {
  final Color? backgroundColor;

  const LibraryTabViewLayoutButton({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainProvider = MainProvider.of(ref);
    final AsyncValue<int> asyncIsListView = mainProvider.library.link(ref).cardViewType.watch(ref);

    return asyncIsListView.when(
      data: (data) {
        final isGrid = data == 0;
        return BuildButton(
          onTap: () {
            mainProvider.library.act(ref).cardViewType.act(ref).toggle();
          },
          backgroundColor: backgroundColor,
          iconData: isGrid ? HugeIconsStroke.grid02 : HugeIconsStroke.menu02,
        );
      },
      error: (e, st) => Icon(Icons.error_rounded),
      loading: () =>
          ConstrainedBox(constraints: BoxConstraints(maxHeight: 20, maxWidth: 20), child: CircularProgressIndicator()),
    );
  }
}
