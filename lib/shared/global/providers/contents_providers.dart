import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';

final _contentsByParentId = StreamProvider.autoDispose.family<List<CourseContent>, String>((ref, arg) async* {
  yield* (await CourseContentRepo.filter).parentIdEqualTo(arg).watch(fireImmediately: true);
});

class CollectionsProviders {
  static StreamProvider<List<CourseContent>> contentsProvider(String parentId) => _contentsByParentId(parentId);
}
