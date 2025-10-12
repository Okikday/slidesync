import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';

final defaultCollection = CourseCollection.create(parentId: '_', collectionTitle: "_");
final _collectionById = StreamNotifierProvider.autoDispose.family<CollectionNotifier, CourseCollection, String>(
  (collectionId) => CollectionNotifier(collectionId),
);
final _collectionsByParentId = StreamProvider.autoDispose.family<List<CourseCollection>, String>((ref, arg) async* {
  await Future.delayed(const Duration(milliseconds: 200));
  yield* (await CourseCollectionRepo.filter).parentIdEqualTo(arg).watch(fireImmediately: true);
});

class CollectionsProviders {
  static StreamProvider<List<CourseCollection>> collectionsProvider(String parentId) =>
      _collectionsByParentId(parentId);

  static StreamNotifierProvider<CollectionNotifier, CourseCollection> collectionProvider(String collectionId) =>
      _collectionById(collectionId);
}

class CollectionNotifier extends StreamNotifier<CourseCollection> {
  final String collectionId;
  CollectionNotifier(this.collectionId);
  @override
  Stream<CourseCollection> build() async* {
    await Future.delayed(const Duration(milliseconds: 200));
    yield* CourseCollectionRepo.watchCollectionById(collectionId).map((c) {
      log("detect collection change");
      return c ?? defaultCollection;
    });
  }

  @override
  bool updateShouldNotify(AsyncValue<CourseCollection> previous, AsyncValue<CourseCollection> next) => true;
}
