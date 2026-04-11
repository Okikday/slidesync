import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';

class ModContentsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  final selectedContents = LinkedHashSet<CourseContent>(equals: (a, b) => a == b);

  bool get isEmpty => selectedContents.isEmpty;

  bool lookup(CourseContent value) => selectedContents.contains(value);

  void _spikeSelectSignal() {
    state = state + 1;
  }

  // return true only if the id is added
  bool selectContent(CourseContent content) {
    final add = selectedContents.add(content);
    _spikeSelectSignal();
    return add;
  }

  bool selectAllContent(List<CourseContent> contents) {
    selectedContents.addAll(contents);
    _spikeSelectSignal();
    return true;
  }

  bool removeContent(CourseContent content) {
    final removed = selectedContents.remove(content);
    _spikeSelectSignal();
    return removed;
  }

  void clearContents() {
    selectedContents.clear();
    _spikeSelectSignal();
  }
}
