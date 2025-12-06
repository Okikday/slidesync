import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/browse/course/providers/src/course_details_state.dart';

class CourseDetailsProvider {
  static final state = Provider.autoDispose<CourseDetailsState>((ref) {
    final cds = CourseDetailsState();
    ref.onDispose(cds.dispose);
    return cds;
  });
}
