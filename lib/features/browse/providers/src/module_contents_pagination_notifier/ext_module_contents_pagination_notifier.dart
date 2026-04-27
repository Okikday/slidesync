part of 'module_contents_pagination_notifier.dart';

extension ExtModuleContentsPaginationNotifier on ModuleContentsPaginationNotifier {
  Future<void> syncModuleContents() async {
    if (isUpdating) {
      extraCheck = true;
      return;
    }

    isUpdating = true;

    try {
      await _runComparison();

      // If a change came in while we were updating, run once more
      if (extraCheck) {
        extraCheck = false;
        await _runComparison();
      }
    } finally {
      isUpdating = false;
      extraCheck = false;
    }
  }

  Future<void> _runComparison() async {
    final List<List<ModuleContent>>? pages = pagingController.value.pages;
    if (pages == null || pages.isEmpty) return;
    final module = this.module;
    if (module == null) return;
    await module.contents.load();
    final freshContents = module.contents.toList();
    final presentCount = freshContents.length;
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);

    log("DB: $presentCount  Displayed: $displayedCount");

    if (presentCount == displayedCount) {
      _handleModifications(pages, freshContents);
    } else {
      await _handleCountChange(pages, presentCount);
    }
  }

  void _handleModifications(List<List<ModuleContent>> pages, List<ModuleContent> freshContents) {
    final displayedMap = {
      for (final page in pages)
        for (final content in page) content.uid: content,
    };

    final modifiedMap = <String, ModuleContent>{};
    for (final fresh in freshContents) {
      final displayed = displayedMap[fresh.uid];
      if (displayed != null && fresh != displayed) {
        modifiedMap[fresh.uid] = fresh;
      }
    }

    if (modifiedMap.isEmpty) return;

    log("Updating ${modifiedMap.length} modified items");

    pagingController.value = pagingController.value.copyWith(
      pages: pages.map((page) {
        return page.map((c) => modifiedMap[c.uid] ?? c).toList();
      }).toList(),
    );
  }

  Future<void> _handleCountChange(List<List<ModuleContent>> pages, int presentCount) async {
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);
    final difference = presentCount - displayedCount;

    if (difference < 0) {
      // Items removed — full refresh is simplest and correct
      pagingController.refresh();
      return;
    }

    // Items added — refetch existing pages plus at most one new page
    final additionalPages = (difference / limit).ceil();
    final pagesToFetch = pages.length + math.min(additionalPages, 1);

    final newPages = <List<ModuleContent>>[];
    final newKeys = <int>[];

    for (int i = 0; i < pagesToFetch; i++) {
      final pageKey = i + 1;
      final fetched = await fetchPage(pageKey, limit);
      if (fetched.isEmpty) break;
      newPages.add(fetched);
      newKeys.add(pageKey);
    }

    if (newPages.isNotEmpty) {
      pagingController.value = pagingController.value.copyWith(pages: newPages, keys: newKeys);
    }
  }
}
