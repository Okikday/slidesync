import 'package:flutter/material.dart';
import 'package:kickin_utilities/kickin_utilities.dart';

class BackdropShadow extends StatelessWidget {
  final double height;
  final (Alignment from, Alignment to) shadowDirection;
  final bool applyBlur;
  const BackdropShadow({
    super.key,
    required this.height,
    this.shadowDirection = const (Alignment.bottomCenter, Alignment.topCenter),
    this.applyBlur = false,
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
              colors: [
                Colors.black, // 100% opacity at source
                Color(0xB3000000), // ~70%
                Color(0x66000000), // ~40%
                Color(0x26000000), // ~15%
                Color(0x08000000), // ~3%
                Colors.transparent, // 0% at tail
              ],
              stops: [0.0, 0.4, 0.6, 0.8, 0.95, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: height,
            color: context.theme.scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
