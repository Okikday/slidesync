import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_app_theme.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_context.dart';

class AppCustomizableDialog extends ConsumerWidget {
  final Widget? leading;
  final Alignment alignment;

  /// Representing vertically aligned actions
  final Widget child;
  final Color? backgroundColor;
  final Offset? blurSigma;
  final void Function()? onPop;
  const AppCustomizableDialog({
    super.key,
    this.blurSigma = const Offset(4, 4),
    this.leading,
    this.alignment = Alignment.center,
    required this.child,
    this.backgroundColor,
    this.onPop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final maxHeight = context.deviceHeight * 0.7;
    final maxWidth = context.deviceWidth * 0.9;
    return Stack(
      alignment: alignment,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (onPop != null) {
                onPop!();
              } else {
                CustomDialog.hide(context);
              }
            },
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: alignment == Alignment.bottomCenter ? context.padding.bottom + 16.0 : null,
          top: alignment == Alignment.topCenter ? context.padding.top + 16.0 : null,
          child: Container(
            clipBehavior: Clip.hardEdge,
            constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.background,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.fromBorderSide(
                BorderSide(color: theme.supportingText.withAlpha(40), strokeAlign: BorderSide.strokeAlignOutside),
              ),
            ),
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: blurSigma != null
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurSigma!.dx, sigmaY: blurSigma!.dy),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leading != null) leading!,
                        Flexible(child: child),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) leading!,
                      Flexible(child: child),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
