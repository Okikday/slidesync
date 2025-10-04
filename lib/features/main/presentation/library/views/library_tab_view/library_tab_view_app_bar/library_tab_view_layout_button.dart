import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/library_tab_view_app_bar/build_button.dart';

class LibraryTabViewLayoutButton extends ConsumerWidget {
  final AsyncNotifierProvider<CardViewTypeNotifier, int> layoutProvider;
  final Color? backgroundColor;

  const LibraryTabViewLayoutButton({super.key, required this.layoutProvider, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> asyncIsListView = ref.watch(layoutProvider);

    return asyncIsListView.when(
      data: (data) {
        final isGrid = data == 0;
        return BuildButton(
          onTap: () {
            ref.read(layoutProvider.notifier).toggle();
          },
          backgroundColor: backgroundColor,
          iconData: isGrid ? Iconsax.menu : Icons.list_rounded,
        );
      },
      error: (e, st) => Icon(Icons.error_rounded),
      loading: () =>
          ConstrainedBox(constraints: BoxConstraints(maxHeight: 20, maxWidth: 20), child: CircularProgressIndicator()),
    );
  }
}
