import 'package:flutter/material.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ContentSidebar extends StatelessWidget {
  const ContentSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  BoxDecoration _navBarDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      borderRadius: .only(topRight: .circular(40), bottomRight: .circular(40)),
      border: Border.all(
        color: theme.custom.onBackground.withValues(alpha: 0.15),
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );
  }
}
