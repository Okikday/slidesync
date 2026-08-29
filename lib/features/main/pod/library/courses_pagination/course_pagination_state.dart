// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:slidesync/core/constants/constants.dart';

class CoursePaginationState extends Equatable {
  final CoursesOrdering coursesOrdering;
  final bool isLoading;

  const CoursePaginationState({
    this.coursesOrdering = CoursesOrdering.dateModifiedAsc,
    this.isLoading = false,
  });

  CoursePaginationState copyWith({
    CoursesOrdering? coursesOrdering,
    bool? isLoading,
  }) {
    return CoursePaginationState(
      coursesOrdering: coursesOrdering ?? this.coursesOrdering,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [coursesOrdering, isLoading];
}
