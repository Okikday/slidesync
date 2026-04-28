// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:slidesync/core/constants/constants.dart';

class CoursePaginationState {
  final CoursesOrdering coursesOrdering;
  final bool isLoading;

  const CoursePaginationState({this.coursesOrdering = CoursesOrdering.dateModifiedAsc, this.isLoading = false});

  CoursePaginationState copyWith({CoursesOrdering? coursesOrdering, bool? isLoading}) {
    return CoursePaginationState(
      coursesOrdering: coursesOrdering ?? this.coursesOrdering,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(covariant CoursePaginationState other) {
    if (identical(this, other)) return true;

    return other.coursesOrdering == coursesOrdering && other.isLoading == isLoading;
  }

  @override
  int get hashCode => coursesOrdering.hashCode ^ isLoading.hashCode;
}
