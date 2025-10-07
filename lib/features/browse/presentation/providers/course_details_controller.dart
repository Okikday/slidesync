
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/browse/presentation/providers/course_details_controller/course_details_state.dart';

// final _watchAllCollectionChanges = StreamProvider.autoDispose<void>((ref) async* {
//   yield* (await CourseCollectionRepo.isarData.watchAllForChanges());
// });

// final _courseWithCollectionsFamilyNotifier =
//     AsyncNotifierProvider.family<CourseWithCollectionsNotifier, Course, String>(
//       CourseWithCollectionsNotifier.new,
//       isAutoDispose: true,
//     );

final _courseDetailsStateProvider = Provider<CourseDetailsState>((ref) {
  final cds = CourseDetailsState.of();
  ref.onDispose(cds.dispose);
  return cds;
}, isAutoDispose: true);

class CourseDetailsController {
  static Provider<CourseDetailsState> get courseDetailsStateProvider => _courseDetailsStateProvider;
  // static AsyncNotifierProvider<CourseWithCollectionsNotifier, Course> courseWithCollectionProvider(String courseId) =>
  //     _courseWithCollectionsFamilyNotifier(courseId);
}

// class CourseWithCollectionsNotifier extends AsyncNotifier<Course> {
//   final String _defaultKey;
//   CourseWithCollectionsNotifier(this._defaultKey);
//   @override
//   FutureOr<Course> build() async {
//     final course = await CourseRepo.getCourseById(_defaultKey);
//     await ref.watch(_watchAllCollectionChanges.future);
//     await course?.collections.load();
//     return course ?? defaultCourse;
//   }
// }
