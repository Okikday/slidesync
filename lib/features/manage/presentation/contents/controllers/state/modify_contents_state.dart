import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';

class ModifyContentsState extends LeakPrevention {
  late final ValueNotifier<LinkedHashSet<CourseContent>> selectedContentsNotifier;

  ModifyContentsState() {
    selectedContentsNotifier = ValueNotifier(LinkedHashSet<CourseContent>());
  }

  bool get isEmpty => selectedContentsNotifier.value.isEmpty;

  bool lookup(CourseContent value) => selectedContentsNotifier.value.contains(value);

  // return true only if the id is added
  bool selectContent(CourseContent content) {
    final set = selectedContentsNotifier.value;
    final added = set.add(content);
    if (added) selectedContentsNotifier.value = LinkedHashSet.from(set);
    return added;
  }

  bool selectAllContent(List<CourseContent> contents) {
    final set = selectedContentsNotifier.value;
    final added = set.addAll(contents);
    selectedContentsNotifier.value = LinkedHashSet.from(set);
    return true;
  }

  bool removeContent(CourseContent content) {
    final set = selectedContentsNotifier.value;
    final removed = set.remove(content);
    if (removed) selectedContentsNotifier.value = LinkedHashSet.from(set);
    return removed;
  }

  void clearContents() {
    if (selectedContentsNotifier.value.isNotEmpty) {
      selectedContentsNotifier.value.clear();
      selectedContentsNotifier.value = LinkedHashSet();
    }
  }

  @override
  void onDispose() {
    selectedContentsNotifier.dispose();
    log("Disposed $this");
  }
}
