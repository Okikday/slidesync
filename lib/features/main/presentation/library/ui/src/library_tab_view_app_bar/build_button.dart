import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class BuildButton extends ConsumerWidget {
  const BuildButton({
    super.key,
    required this.onTap,
    this.backgroundColor,
    required this.iconData,
    this.child,
    this.shape,
  });

  final void Function() onTap;
  final IconData? iconData;
  final Widget? child;
  final Color? backgroundColor;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return CustomElevatedButton(
      contentPadding: EdgeInsets.all(12),
      pixelHeight: DeviceUtils.isDesktop() ? 48 : null,
      pixelWidth: DeviceUtils.isDesktop() ? 48 : null,
      backgroundColor: backgroundColor ?? theme.altBackgroundPrimary,
      shape: shape ?? const CircleBorder(),
      onClick: onTap,
      child: child ?? Icon(iconData, size: 20, color: theme.supportingText),
    );
  }
}
