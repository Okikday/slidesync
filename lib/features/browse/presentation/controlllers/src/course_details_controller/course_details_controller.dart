
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/browse/presentation/controlllers/state/course_details_state.dart';


final _courseDetailsStateProvider = Provider<CourseDetailsState>((ref) {
  final cds = CourseDetailsState();
  ref.onDispose(cds.dispose);
  return cds;
}, isAutoDispose: true);

class CourseDetailsController {
  static Provider<CourseDetailsState> get courseDetailsStateProvider => _courseDetailsStateProvider;
 
}

