import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';

class LibraryTabViewLayoutButton extends ConsumerWidget {
  final Color? backgroundColor;

  const LibraryTabViewLayoutButton({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateValue = MainProvider.library
        .select((s) => (cardViewType: s.cardViewType, isLoading: s.isLoading))
        .watch(ref);

    if (stateValue.isLoading) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 20, maxWidth: 20),
        child: CircularProgressIndicator(),
      );
    }

    return BuildButton(
      onTap: () => MainProvider.library.act(ref).toggleCardViewType(),
      backgroundColor: backgroundColor,
      iconData: IconHelper.getCardViewTypeIconData(stateValue.cardViewType),
    );
  }
}
