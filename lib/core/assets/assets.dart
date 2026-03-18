import 'package:flutter/widgets.dart';
export 'assets.gen.dart';

extension AssetsExtension on String {
  AssetImage get asImageProvider => AssetImage(this);
}
