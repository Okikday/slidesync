import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';

final defaultCollection = CourseCollection.create(parentId: '_', collectionTitle: "_");
final _collectionById = StreamProvider.autoDispose.family<CourseCollection, String>((ref, collectionId) async* {
  await Future.delayed(Durations.medium2);
  yield* CourseCollectionRepo.watchCollectionById(collectionId).map((c) => c ?? defaultCollection);
});
final _collectionsByParentId = StreamProvider.autoDispose.family<List<CourseCollection>, String>((ref, arg) async* {
  await Future.delayed(Durations.medium2);
  yield* (await CourseCollectionRepo.filter).parentIdEqualTo(arg).watch(fireImmediately: true);
});

class CollectionsProviders {
  static StreamProvider<List<CourseCollection>> collectionsProvider(String parentId) =>
      _collectionsByParentId(parentId);

  static StreamProvider<CourseCollection> collectionProvider(String collectionId) => _collectionById(collectionId);
}
