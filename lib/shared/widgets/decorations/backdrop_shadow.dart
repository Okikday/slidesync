import 'package:flutter/material.dart';
import 'package:kickin_utilities/kickin_utilities.dart';

class BackdropShadow extends StatelessWidget {
  final double height;
  final double width;
  final (Alignment from, Alignment to) shadowDirection;
  final bool applyBlur;
  final Color? color;
  const BackdropShadow({
    super.key,
    required this.height,
    this.width = .infinity,
    this.shadowDirection = const (Alignment.bottomCenter, Alignment.topCenter),
    this.applyBlur = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: .blur(sigmaX: 2, sigmaY: 2, tileMode: TileMode.decal),
        enabled: applyBlur,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: shadowDirection.$1,
              end: shadowDirection.$2,
              colors: color == null
                  ? [
                      Colors.black, // 100% opacity at source
                      Color(0xB3000000), // ~70%
                      Color(0x66000000), // ~40%
                      Color(0x26000000), // ~15%
                      Color(0x08000000), // ~3%
                      Colors.transparent, // 0% at tail
                    ]
                  : [
                      color!.withAlpha(255), // 100% opacity at source
                      color!.withAlpha(179), // ~70%
                      color!.withAlpha(102), // ~40%
                      color!.withAlpha(38), // ~15%
                      color!.withAlpha(8), // ~3%
                      Colors.transparent, // 0% at tail
                    ],
              stops: [0.0, 0.4, 0.6, 0.8, 0.95, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: height,
            width: width,
            color: context.theme.scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
