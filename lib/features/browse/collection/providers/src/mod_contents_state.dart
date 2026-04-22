import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';

class ModContentsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  final selectedContents = LinkedHashSet<ModuleContent>(equals: (a, b) => a == b);

  bool get isEmpty => selectedContents.isEmpty;

  bool lookup(ModuleContent value) => selectedContents.contains(value);

  void _spikeSelectSignal() {
    state = state + 1;
  }

  // return true only if the id is added
  bool selectContent(ModuleContent content) {
    final add = selectedContents.add(content);
    _spikeSelectSignal();
    return add;
  }

  bool selectAllContent(List<ModuleContent> contents) {
    selectedContents.addAll(contents);
    _spikeSelectSignal();
    return true;
  }

  bool removeContent(ModuleContent content) {
    final removed = selectedContents.remove(content);
    _spikeSelectSignal();
    return removed;
  }

  void clearContents() {
    selectedContents.clear();
    _spikeSelectSignal();
  }
}
