part of 'module_contents_pagination_notifier.dart';

extension ExtModuleContentsPaginationNotifier on ModuleContentsPaginationNotifier {
  ///
  ///
  /// ===================================================================================================
  /// FLAT SYNC  (list / grid)
  /// ===================================================================================================

  Future<void> syncModuleContents() async {
    final pages = pagingController.value.pages;
    // Guard: nothing displayed yet — nothing to sync.
    if (pages == null || pages.isEmpty) return;

    if (isUpdating) {
      extraCheck = true;
      return;
    }

    isUpdating = true;
    try {
      await _runFlatComparison(pages);
      if (extraCheck) {
        extraCheck = false;
        final refreshedPages = pagingController.value.pages;
        if (refreshedPages != null && refreshedPages.isNotEmpty) {
          await _runFlatComparison(refreshedPages);
        }
      }
    } finally {
      isUpdating = false;
      extraCheck = false;
    }
  }

  Future<void> _runFlatComparison(List<List<ModuleContent>> pages) async {
    final module = this.module;
    if (module == null) return;

    await module.contents.load();
    final freshContents = module.contents.toList();
    final presentCount = freshContents.length;
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);

    log('Flat sync — DB: $presentCount  Displayed: $displayedCount');

    if (presentCount == displayedCount) {
      _handleFlatModifications(pages, freshContents);
    } else {
      await _handleFlatCountChange(pages, presentCount);
    }
  }

  void _handleFlatModifications(List<List<ModuleContent>> pages, List<ModuleContent> freshContents) {
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

    log('Flat sync — updating ${modifiedMap.length} modified items');

    pagingController.value = pagingController.value.copyWith(
      pages: pages.map((page) => page.map((c) => modifiedMap[c.uid] ?? c).toList()).toList(),
    );
  }

  Future<void> _handleFlatCountChange(List<List<ModuleContent>> pages, int presentCount) async {
    final displayedCount = pages.fold(0, (sum, page) => sum + page.length);
    final difference = presentCount - displayedCount;

    if (difference < 0) {
      log('Flat sync — items removed, full refresh');
      pagingController.refresh();
      return;
    }

    final additionalPages = (difference / limit).ceil();
    final pagesToFetch = pages.length + math.min(additionalPages, 1);

    log('Flat sync — items added, refetching $pagesToFetch pages');

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

  ///
  ///
  /// ===================================================================================================
  /// ORGANIZED SYNC  (masonry grouped view)
  /// ===================================================================================================

  Future<void> syncOrganizedContents() async {
    final pages = organizedPagingController.value.pages;
    // Guard: organized controller idle — nothing to sync.
    if (pages == null || pages.isEmpty) return;

    // Re-use the same isUpdating gate — only one sync runs at a time since
    // both are triggered by the same DB event and operate sequentially.
    if (isUpdating) {
      extraCheck = true;
      return;
    }

    isUpdating = true;
    try {
      await _runOrganizedComparison(pages);
      if (extraCheck) {
        extraCheck = false;
        final refreshedPages = organizedPagingController.value.pages;
        if (refreshedPages != null && refreshedPages.isNotEmpty) {
          await _runOrganizedComparison(refreshedPages);
        }
      }
    } finally {
      isUpdating = false;
      extraCheck = false;
    }
  }

  Future<void> _runOrganizedComparison(List<List<Object>> pages) async {
    final module = this.module;
    if (module == null) return;

    await module.contents.load();
    final freshContents = module.contents.toList();
    final presentCount = freshContents.length;

    // Unwrap pages to a flat ModuleContent count for comparison.
    // GroupedModuleContent.items holds page-local members; solo items are
    // ModuleContent directly.
    final displayedCount = pages.fold(0, (sum, page) {
      return sum +
          page.fold(0, (pageSum, item) {
            return pageSum +
                switch (item) {
                  GroupedModuleContent g => g.count,
                  ModuleContent() => 1,
                  _ => 0,
                };
          });
    });

    log('Organized sync — DB: $presentCount  Displayed: $displayedCount');

    if (presentCount == displayedCount) {
      _handleOrganizedModifications(pages, freshContents);
    } else {
      await _handleOrganizedCountChange(pages, presentCount);
    }
  }

  /// Patches modified [ModuleContent] instances inside each page's items
  /// (both inside [GroupedModuleContent.items] and solo entries), then
  /// re-groups the patched flat list so group metadata stays accurate.
  void _handleOrganizedModifications(List<List<Object>> pages, List<ModuleContent> freshContents) {
    // Build a uid → fresh content lookup once.
    final freshMap = {for (final c in freshContents) c.uid: c};

    // Check whether anything actually changed before rebuilding.
    bool anyModified = false;
    for (final page in pages) {
      for (final item in page) {
        final changed = switch (item) {
          GroupedModuleContent g => g.items.any((c) {
            final fresh = freshMap[c.uid];
            return fresh != null && fresh != c;
          }),
          ModuleContent c => () {
            final fresh = freshMap[c.uid];
            return fresh != null && fresh != c;
          }(),
          _ => false,
        };
        if (changed) {
          anyModified = true;
          break;
        }
      }
      if (anyModified) break;
    }

    if (!anyModified) return;

    log('Organized sync — patching modified items and re-grouping');

    organizedPagingController.value = organizedPagingController.value.copyWith(
      pages: pages.map((page) {
        // Reconstruct the raw flat list for this page, patching stale items.
        final patchedFlat = <ModuleContent>[];
        for (final item in page) {
          switch (item) {
            case GroupedModuleContent g:
              for (final c in g.items) {
                patchedFlat.add(freshMap[c.uid] ?? c);
              }
            case ModuleContent c:
              patchedFlat.add(freshMap[c.uid] ?? c);
          }
        }
        // Re-group so GroupedModuleContent metadata (latestModified, totalSize,
        // previewThumbnails) reflects the patched state.
        return groupModuleContents(patchedFlat);
      }).toList(),
    );
  }

  Future<void> _handleOrganizedCountChange(List<List<Object>> pages, int presentCount) async {
    final displayedCount = pages.fold(0, (sum, page) {
      return sum +
          page.fold(0, (pageSum, item) {
            return pageSum +
                switch (item) {
                  GroupedModuleContent g => g.count,
                  ModuleContent() => 1,
                  _ => 0,
                };
          });
    });

    final difference = presentCount - displayedCount;

    if (difference < 0) {
      log('Organized sync — items removed, full refresh');
      organizedPagingController.refresh();
      return;
    }

    final additionalPages = (difference / limit).ceil();
    final pagesToFetch = pages.length + math.min(additionalPages, 1);

    log('Organized sync — items added, refetching $pagesToFetch pages');

    final newPages = <List<Object>>[];
    final newKeys = <int>[];

    for (int i = 0; i < pagesToFetch; i++) {
      final pageKey = i + 1;
      // Fetch flat then re-group — same path as the paging controller uses.
      final flat = await fetchPage(pageKey, limit);
      if (flat.isEmpty) break;
      newPages.add(groupModuleContents(flat));
      newKeys.add(pageKey);
    }

    if (newPages.isNotEmpty) {
      organizedPagingController.value = organizedPagingController.value.copyWith(pages: newPages, keys: newKeys);
    }
  }
}
