import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_providers/data_providers/course_providers.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_details_controller/course_details_state.dart';

final _watchAllCollectionChanges = StreamProvider.autoDispose<void>((ref) async* {
  yield* (await CourseCollectionRepo.isarData.watchAllForChanges());
});

final _courseWithCollectionsFamilyNotifier = AsyncNotifierProvider.family<CourseWithCollectionsNotifier, Course, int>(
  CourseWithCollectionsNotifier.new,
  isAutoDispose: true,
);

final _courseDetailsStateProvider = Provider<CourseDetailsState>((ref) {
  final cds = CourseDetailsState.of();
  ref.onDispose(cds.dispose);
  return cds;
}, isAutoDispose: true);

class CourseDetailsController {
  static Provider<CourseDetailsState> get courseDetailsStateProvider => _courseDetailsStateProvider;
  static AsyncNotifierProvider<CourseWithCollectionsNotifier, Course> courseWithCollectionProvider(int key) =>
      _courseWithCollectionsFamilyNotifier(key);
}

class CourseWithCollectionsNotifier extends AsyncNotifier<Course> {
  final int _defaultKey;
  CourseWithCollectionsNotifier(this._defaultKey);
  @override
  FutureOr<Course> build() async {
    final course = await CourseRepo.getCourseByDbId(_defaultKey);
    await ref.watch(_watchAllCollectionChanges.future);
    await course?.collections.load();
    return course ?? defaultCourse;
  }
}
