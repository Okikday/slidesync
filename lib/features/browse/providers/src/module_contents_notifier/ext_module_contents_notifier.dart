part of 'module_contents_notifier.dart';

extension ExtModuleContentsNotifier on ModuleContentsNotifier {
  bool isContentSelected(ModuleContent value) => selectedContents.contains(value);

  // return true only if the id is added
  bool selectContent(ModuleContent content) {
    final add = selectedContents.add(content);
    signalSelection();
    return add;
  }

  bool selectAllContent(List<ModuleContent> contents) {
    selectedContents.addAll(contents);
    signalSelection();
    return true;
  }

  bool unselectContent(ModuleContent content) {
    final removed = selectedContents.remove(content);
    signalSelection();
    return removed;
  }

  void unselectAllContents() {
    selectedContents.clear();
    signalSelection();
  }
}
