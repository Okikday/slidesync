import 'dart:collection';
import 'dart:developer';
import 'package:slidesync/core/base/leak_prevention.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';

class ModContentsState extends LeakPrevention with ValueNotifierFactoryMixin {
  late final selectSignal = useValueNotifier<bool>(false);
  final selectedContents = LinkedHashSet<CourseContent>(equals: (a, b) => a == b);

  bool get isEmpty => selectedContents.isEmpty;

  bool lookup(CourseContent value) => selectedContents.contains(value);

  void spikeselectSignal() {
    selectSignal.value = !selectSignal.value;
  }

  // return true only if the id is added
  bool selectContent(CourseContent content) {
    final add = selectedContents.add(content);
    spikeselectSignal();
    return add;
  }

  bool selectAllContent(List<CourseContent> contents) {
    selectedContents.addAll(contents);
    spikeselectSignal();
    return true;
  }

  bool removeContent(CourseContent content) {
    final removed = selectedContents.remove(content);
    spikeselectSignal();
    return removed;
  }

  void clearContents() {
    selectedContents.clear();
    spikeselectSignal();
  }

  @override
  void onDispose() {
    disposeNotifiers();
    log("Disposed $this");
  }
}
