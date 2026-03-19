import 'dart:ui';

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
    this.size,
    this.iconColor,
  });

  final void Function() onTap;
  final IconData? iconData;
  final Widget? child;
  final Color? backgroundColor;
  final OutlinedBorder? shape;
  final Size? size;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: CustomElevatedButton(
          contentPadding: EdgeInsets.zero,
          pixelHeight: size?.height ?? (DeviceUtils.isDesktop() ? 44 : 48),
          pixelWidth: size?.width ?? (DeviceUtils.isDesktop() ? 44 : 48),
          backgroundColor: theme.altBackgroundPrimary.withValues(alpha: 0.8),
          shape:
              shape ??
              CircleBorder(
                side: BorderSide(color: theme.onSurface.withValues(alpha: .1)),
              ), //backgroundColor?.withValues(alpha: 0.8) ??
          onClick: onTap,
          child: child ?? Icon(iconData, size: 20, color: iconColor ?? theme.supportingText),
        ),
      ),
    );
  }
}
