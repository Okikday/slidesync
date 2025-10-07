import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/base/leak_prevention.dart';

class CourseDetailsState extends LeakPrevention {
  
  late final ValueNotifier<double> scrollOffsetNotifier;
  late final ValueNotifier<String> searchCollectionTextNotifier;

  CourseDetailsState._() {
    scrollOffsetNotifier = ValueNotifier(0.0);
    searchCollectionTextNotifier = ValueNotifier('');
  }

  static CourseDetailsState of() => CourseDetailsState._();

  @override
  void onDispose() {
    scrollOffsetNotifier.dispose();
    searchCollectionTextNotifier.dispose();
    log("Disposed CourseDetails State");
  }
}
