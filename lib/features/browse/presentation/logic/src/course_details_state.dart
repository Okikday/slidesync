import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';

class CourseDetailsState extends LeakPrevention with ValueNotifierFactoryMixin {
  ///|
  ///|
  /// ===================================================================================================
  /// VARIABLES
  /// ===================================================================================================

  late final ValueNotifier<double> scrollOffsetNotifier;
  late final ValueNotifier<String> searchCollectionTextNotifier;

  ///|
  ///|
  /// ===================================================================================================
  /// INIT
  /// ===================================================================================================
  CourseDetailsState() {
    scrollOffsetNotifier = useValueNotifier(0.0);
    searchCollectionTextNotifier = useValueNotifier('');
  }

  ///|
  ///|
  /// ===================================================================================================
  /// DISPOSALS
  /// ===================================================================================================
  @override
  void onDispose() {
    disposeNotifiers();
    log("Disposed CourseDetails State");
  }
}
