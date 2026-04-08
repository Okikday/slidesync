import 'package:flutter/material.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class BackSoftEdgeBlur extends StatelessWidget {
  final Color? color;
  final EdgeType edgeType;
  final double height;
  final bool applyHeightToSize;
  final Widget child;
  const BackSoftEdgeBlur({
    super.key,
    this.color,
    this.edgeType = EdgeType.topEdge,
    this.applyHeightToSize = false,
    this.height = 72,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          child: SizedBox(
            height: height,
            child: SoftEdgeBlur(
              edges: [
                EdgeBlur(
                  type: edgeType,
                  size: applyHeightToSize ? height : 72,
                  sigma: 30,
                  tintColor: color ?? context.scaffoldBackgroundColor,
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
    );
  }
}
