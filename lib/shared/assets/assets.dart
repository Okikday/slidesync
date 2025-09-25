import 'package:flutter/widgets.dart';
import 'package:slidesync/shared/assets/strings/icon_strings.dart';
import 'package:slidesync/shared/assets/strings/image_strings.dart';

class Assets {
  static ImageStrings images = ImageStrings.instance;
  static IconStrings icons = IconStrings.instance;
}

extension AssetsExtension on String {
  AssetImage get asImageProvider => AssetImage(this);
}
