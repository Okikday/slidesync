import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/dev/file_manager_page.dart';

class SettingsState extends LeakPrevention with ValueNotifierFactoryMixin {
  int revealFileManagerCount = 0;
  DateTime? prevDateTime;

  void _resetTracking() {
    prevDateTime = DateTime.now();
    revealFileManagerCount = 1;
  }

  void onRevealFileManager(BuildContext context) {
    log("clicked to reveal!");
    if (prevDateTime == null) {
      _resetTracking();
      return;
    } else {
      final currentTime = DateTime.now();
      final timeDiff = prevDateTime?.difference(currentTime);
      if (timeDiff == null || timeDiff.inMilliseconds > 800) {
        _resetTracking();
        return;
      }

      if (revealFileManagerCount >= 7) {
        Navigator.push(context, PageAnimation.pageRouteBuilder(FileManagerPage()));
        return;
      }

      revealFileManagerCount++;
      prevDateTime = DateTime.now();
    }
  }

  @override
  void onDispose() {}
}
