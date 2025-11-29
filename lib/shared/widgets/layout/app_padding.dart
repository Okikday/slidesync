import 'package:flutter/material.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class TopPadding extends StatelessWidget {
  final double? withHeight;
  final Widget? child;
  const TopPadding({super.key, this.withHeight, this.child});

  @override
  Widget build(BuildContext context) {
    final topPadding = context.topPadding;
    return child != null
        ? Padding(
            padding: EdgeInsetsGeometry.only(top: topPadding + (withHeight ?? 0.0)),
            child: child,
          )
        : SizedBox(height: topPadding + (withHeight ?? 0.0));
  }
}

class BottomPadding extends StatelessWidget {
  final double? withHeight;
  final bool useKeyboardPadding;
  final Widget? child;
  const BottomPadding({super.key, this.withHeight, this.useKeyboardPadding = false, this.child});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = context.bottomPadding;
    return child != null
        ? Padding(
            padding: EdgeInsetsGeometry.only(
              bottom: bottomPadding + (withHeight ?? 0.0) + (useKeyboardPadding ? context.viewInsets.bottom : 0.0),
            ),
            child: child,
          )
        : SizedBox(height: bottomPadding + (withHeight ?? 0.0));
  }
}
