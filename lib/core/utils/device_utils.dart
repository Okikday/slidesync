import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/src/enums.dart';

class DeviceUtils {
  static bool isDesktop() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      default:
        return false;
    }
  }

  /// Gets the type of Device
  static DeviceType getDeviceType(BuildContext context) {
    final platform = defaultTargetPlatform;
    final isWeb = kIsWeb;
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    if (isWeb) {
      if (shortestSide < 600) {
        return DeviceType.webMobile;
      } else if (shortestSide < 1024) {
        return DeviceType.webTablet;
      } else {
        return DeviceType.webDesktop;
      }
    }

    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        if (shortestSide < 600) {
          return DeviceType.mobile;
        } else {
          return DeviceType.tablet;
        }
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return DeviceType.desktop;
      default:
        return DeviceType.unknown;
    }
  }
}
