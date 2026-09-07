import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/src/enums/enums.dart';

class DeviceUtils {
  static bool isDesktopSize([BuildContext? context]) {
    final mediaQuery = context != null ? MediaQuery.maybeOf(context) : null;
    final logicalSize = mediaQuery?.size ?? _logicalSizeFromView();
    if (logicalSize == null) {
      return isDesktop();
    }

    final shortestSide = logicalSize.shortestSide;
    final longestSide = logicalSize.longestSide;

    // Treat only phone-like layouts as non-desktop; tablet and larger are desktop-sized.
    final isPhoneLike = shortestSide < 600 && longestSide < 1000;
    return !isPhoneLike;
  }

  static Size? _logicalSizeFromView() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return null;

    final view = views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

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
