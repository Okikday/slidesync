import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';

final _collectionById = StreamNotifierProvider.autoDispose.family<CollectionNotifier, Module, String>(
  (collectionId) => CollectionNotifier(collectionId),
);
final _collectionsByParentId = StreamProvider.autoDispose.family<List<Module>, String>((ref, arg) async* {
  yield* (ModuleRepo.filter).parentIdEqualTo(arg).sortByTitle().watch(fireImmediately: true);
});

class CollectionsProviders {
  static StreamProvider<List<Module>> collectionsProvider(String parentId) => _collectionsByParentId(parentId);

  static StreamNotifierProvider<CollectionNotifier, Module> collectionProvider(String collectionId) =>
      _collectionById(collectionId);
}

class CollectionNotifier extends StreamNotifier<Module> {
  final String collectionId;
  CollectionNotifier(this.collectionId);
  @override
  Stream<Module> build() {
    return ModuleRepo.watchCollectionById(collectionId).map((c) {
      log("detect collection change");
      return c ?? Module.empty();
    });
  }

  @override
  bool updateShouldNotify(AsyncValue<Module> previous, AsyncValue<Module> next) => true;
}
