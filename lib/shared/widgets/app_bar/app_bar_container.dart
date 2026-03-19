import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

export 'app_bar_container_child.dart';

class AppBarContainer extends ConsumerWidget {
  final Color? scaffoldBgColor;
  final EdgeInsets? padding;
  final Widget child;
  final double? deviceWidth;
  final double? appBarHeight;
  final double? deviceHeight;

  const AppBarContainer({
    super.key,
    this.scaffoldBgColor,
    this.deviceHeight,
    this.deviceWidth,
    this.padding,
    required this.child,
    this.appBarHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = context.screenSize;
    return _AppBarContainerWidget(
      key: key,
      deviceWidth: screenSize.width,
      deviceHeight: screenSize.height,
      appBarHeight: appBarHeight,
      scaffoldBgColor: scaffoldBgColor,
      padding: padding,
      child: child,
    );
  }
}

class _AppBarContainerWidget extends ConsumerWidget {
  final double deviceWidth;
  final double deviceHeight;
  final double? appBarHeight;
  final Widget child;
  final EdgeInsets? padding;
  final Color? scaffoldBgColor;
  const _AppBarContainerWidget({
    super.key,
    required this.deviceWidth,
    required this.deviceHeight,
    this.appBarHeight,
    required this.child,
    this.padding,
    this.scaffoldBgColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = context.topPadding;
    return Column(
      children: [
        SizedBox(
          height: topPadding,
          child: ColoredBox(color: scaffoldBgColor ?? context.scaffoldBackgroundColor, child: SizedBox.expand()),
        ),
        Stack(
          children: [
            ClipRRect(
              child: SizedBox(
                height: 72,

                child: SoftEdgeBlur(
                  edges: [
                    EdgeBlur(
                      type: EdgeType.topEdge,
                      size: 72,
                      sigma: 30,
                      tintColor: scaffoldBgColor ?? context.scaffoldBackgroundColor,
                      controlPoints: [
                        ControlPoint(position: 0.4, type: ControlPointType.visible),
                        ControlPoint(position: 1.0, type: ControlPointType.transparent),
                      ],
                    ),
                  ],
                  child: SizedBox.expand(),
                ),
              ),
            ),

            child,
          ],
        ),
      ],
    );
  }
}
