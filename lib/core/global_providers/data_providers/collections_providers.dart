import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/domain/models/course_model/sub/course_collection.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';

final defaultCollection = CourseCollection.create(parentId: '_', collectionTitle: "_");
final _collectionByDbId = StreamProvider.family<CourseCollection?, int>((ref, arg) {
  return CourseCollectionRepo.watchByDbId(arg);
}, isAutoDispose: true);

class CollectionsProviders {
  static StreamProvider<CourseCollection?> collectionProvider(int dbId) => _collectionByDbId(dbId);
}
