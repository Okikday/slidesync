// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:slidesync/core/constants/constants.dart';

class CoursePaginationState {
  final EntityOrdering sortOption;
  final bool isLoading;

  const CoursePaginationState({this.sortOption = EntityOrdering.dateModifiedAsc, this.isLoading = false});

  CoursePaginationState copyWith({EntityOrdering? sortOption, bool? isLoading}) {
    return CoursePaginationState(sortOption: sortOption ?? this.sortOption, isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(covariant CoursePaginationState other) {
    if (identical(this, other)) return true;

    return other.sortOption == sortOption && other.isLoading == isLoading;
  }

  @override
  int get hashCode => sortOption.hashCode ^ isLoading.hashCode;
}
