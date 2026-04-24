import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';

final _contentsByParentId = StreamProvider.autoDispose.family<List<ModuleContent>, String>((ref, arg) async* {
  yield* (ModuleContentRepo.filter).parentIdEqualTo(arg).watch(fireImmediately: true);
});

class CollectionsProviders {
  static StreamProvider<List<ModuleContent>> contentsProvider(String parentId) => _contentsByParentId(parentId);
}
