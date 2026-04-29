import 'dart:developer';

import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _collectionById = StreamNotifierProvider.autoDispose.family<CollectionNotifier, Module, String>(
  (collectionId) => CollectionNotifier(collectionId),
);
final _watchCollectionsInCourse = StreamNotifierProvider.autoDispose.family(
  (String courseId) => StreamedNotifier<List<Module>>(() async* {
    final course = await CourseRepo.getByUid(courseId);
    if (course == null) {
      yield* Stream.empty();
      return;
    }
    yield* course.modules.filter().watch(fireImmediately: true);
  }),
);

class CollectionsProviders {
  static StreamNotifierProvider<StreamedNotifier<List<Module>>, List<Module>> watchCollectionsInCourseProvider(
    String courseId,
  ) => _watchCollectionsInCourse(courseId);

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
