import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class BuildButton extends ConsumerWidget {
  const BuildButton({super.key, required this.onTap, this.backgroundColor, required this.iconData});

  final void Function() onTap;
  final IconData iconData;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return CustomElevatedButton(
      contentPadding: EdgeInsets.all(12),
      backgroundColor: backgroundColor ?? theme.altBackgroundPrimary,
      shape: CircleBorder(),
      onClick: onTap,
      child: Icon(iconData, size: 20, color: theme.supportingText),
    );
  }
}
